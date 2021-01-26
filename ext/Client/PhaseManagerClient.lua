require('__shared/Configs/CircleConfig')
require('__shared/Utils/Timers')
require('__shared/PhaseManagerShared')
require('__shared/Circle')
require('RenderableCircle')
require('Visuals/OOBVision')
require('Visuals/CircleRenderers')

class('PhaseManagerClient', PhaseManagerShared)

function PhaseManagerClient:__init()
    PhaseManagerShared.__init(self)
    self:RegisterEvents()
end

function PhaseManagerClient:RegisterVars()
    PhaseManagerShared.RegisterVars(self)

    self.m_InnerCircle = RenderableCircle()
    self.m_OuterCircle = RenderableCircle()

    self.m_OOBVision = OOBVision
    self.m_RenderInnerCircle = CircleConfig.RenderInnerCircle
end

function PhaseManagerClient:RegisterEvents()
    Events:Subscribe('UpdateManager:Update', self, self.OnPreSim)
    Events:Subscribe('UI:DrawHud', self, self.OnRender)
    Events:Subscribe('Level:Destroy', self, self.Destroy)
    Events:Subscribe('Extension:Unloading', self, self.Destroy)
    NetEvents:Subscribe(PhaseManagerNetEvents.UpdateState, self, self.OnUpdateState)
end

-- Updates the state of the PhaseManager from the server
function PhaseManagerClient:OnUpdateState(p_State)
    -- destroy moving circle update timer
    self:ClearTimer('MovingCircle')

    -- update indices
    self.m_PhaseIndex = p_State.PhaseIndex
    self.m_SubphaseIndex = p_State.SubphaseIndex

    -- check if all phases are completed
    if p_State.Duration < 0 then
        self.m_Completed = true
    elseif self.m_SubphaseIndex == SubphaseType.Moving then
        -- start moving the outer circle
        local l_RenderDelay = 0.3
        self.m_PrevOuterCircle = Circle(self.m_OuterCircle.m_Center, self.m_OuterCircle.m_Radius)
        self:SetTimer('MovingCircle', g_Timers:Sequence(l_RenderDelay, math.floor(phaseDuration / l_RenderDelay) + 1,
                                                        self, self.MoveOuterCircle))
    end

    -- update inner circle data
    self.m_InnerCircle:Update(p_State.InnerCircle.m_Center, p_State.InnerCircle.m_Radius)

    -- update outer circle data
    self.m_OuterCircle:Update(p_State.OuterCircle.m_Center, p_State.OuterCircle.m_Radius)
end

-- 
function PhaseManagerClient:OnPreSim(p_DeltaTime, p_UpdatePass)
    if p_UpdatePass ~= UpdatePass.UpdatePass_PreSim or self:IsIdle() then return end

    -- get local player position
    local p_Player = PlayerManager:GetLocalPlayer()
    if p_Player == nil or p_Player.soldier == nil then return end
    local l_PlayerPos = player.soldier.transform.trans

    -- toggle OOB vision
    if self.m_OuterCircle:IsInnerPoint(l_PlayerPos) then
        self.m_OOBVision:Disable()
    else
        self.m_OOBVision:Enable()
    end

    -- TODO
    -- calculate render points for both circles
    -- self.m_OuterCircle:CalculateRenderPoints(l_PlayerPos)
    -- if self.m_RenderInnerCircle and not self.m_Completed then
    --     self.m_InnerCircle:CalculateRenderPoints(l_PlayerPos)
    -- end
end

-- Renders the two circles
function PhaseManagerClient:OnRender()
    if self:IsIdle() then return end

    -- get local player position
    local l_Player = PlayerManager:GetLocalPlayer()
    if l_Player == nil or l_Player.soldier == nil then return end
    local l_PlayerPos = l_Player.soldier.transform.trans

    -- render circles
    self.m_OuterCircle:Render(OuterCircleRenderer, l_PlayerPos)
    if self.m_RenderInnerCircle and not self.m_Completed then
        self.m_InnerCircle:Render(InnerCircleRenderer, l_PlayerPos)
    end
end

return PhaseManagerClient
