require "__shared/Configs/CircleConfig"
require "__shared/Enums/PhaseManagerEvents"
require "__shared/Utils/Timers"
require "__shared/Utils/EventRouter"
require "__shared/PhaseManagerShared"
require "__shared/Types/Circle"
require "Visuals/IOCVision"
require "Visuals/OOCVision"
require "Visuals/CircleRenderers"
require "RenderableCircle"

class("PhaseManagerClient", PhaseManagerShared)

function PhaseManagerClient:RegisterVars()
    PhaseManagerShared.RegisterVars(self)

    self.m_InnerCircle = RenderableCircle()
    self.m_OuterCircle = RenderableCircle()

    self.m_IOCVision = g_IOCVision
    self.m_OOCVision = g_OOCVision
    self.m_RenderInnerCircle = CircleConfig.RenderInnerCircle

    -- events/hooks
    self.m_LevelLoadedEvent = nil
end

function PhaseManagerClient:RegisterEvents()
    PhaseManagerShared.RegisterEvents(self)

    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.RequestInitialState)
    Events:Subscribe("UpdatePass_PreSim", self, self.OnPreSim)
    Events:Subscribe(EventRouterEvents.UIDrawHudCustom, self, self.OnRender)
    NetEvents:Subscribe(PhaseManagerNetEvents.UpdateState, self, self.OnUpdateState)
end

-- Requests initial state update
function PhaseManagerClient:RequestInitialState()
    NetEvents:SendLocal(PhaseManagerNetEvents.InitialState)

    if self.m_LevelLoadedEvent then
        self.m_LevelLoadedEvent:Unsubscribe()
        self.m_LevelLoadedEvent = nil
    end
end

-- Updates the state of the PhaseManager from the server
function PhaseManagerClient:OnUpdateState(p_State)
    -- destroy moving circle update timer
    self:RemoveTimer("MovingCircle")

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
        self:SetTimer("MovingCircle", g_Timers:Sequence(l_RenderDelay, math.floor(p_State.Duration / l_RenderDelay) + 1,
                                                        self, self.MoveOuterCircle))
    end

    -- update inner circle data
    self.m_InnerCircle:Update(p_State.InnerCircle.Center, p_State.InnerCircle.Radius, self.m_PhaseIndex)

    -- update outer circle data
    self.m_OuterCircle:Update(p_State.OuterCircle.Center, p_State.OuterCircle.Radius, self.m_PhaseIndex)

    -- custom event to inform the rest of the client scripts about the state update
    Events:DispatchLocal(PhaseManagerCustomEvents.Update, p_State)
end

-- 
function PhaseManagerClient:OnPreSim(p_DeltaTime)
    if self:IsIdle() then
        return
    end

    -- get local player position
    local p_Player = PlayerManager:GetLocalPlayer()
    if p_Player == nil or p_Player.soldier == nil then
        return
    end
    local l_PlayerPos = p_Player.soldier.transform.trans

    -- toggle OOB vision
    if self.m_OuterCircle:IsInnerPoint(l_PlayerPos) then
        self.m_OOCVision:Disable()
    else
        self.m_OOCVision:Enable()
    end

    -- calculate render points for both circles
    self.m_OuterCircle:CalculateRenderPoints(l_PlayerPos)
    if self.m_RenderInnerCircle and not self.m_Completed then
        self.m_InnerCircle:CalculateRenderPoints(l_PlayerPos)
    end
end

-- Renders the two circles
function PhaseManagerClient:OnRender()
    if self:IsIdle() then
        return
    end

    -- get local player position
    local l_Player = PlayerManager:GetLocalPlayer()
    if l_Player == nil or l_Player.soldier == nil then
        return
    end
    local l_PlayerPos = l_Player.soldier.transform.trans

    -- render circles
    self.m_OuterCircle:Render(OuterCircleRenderer, l_PlayerPos)
    if self.m_RenderInnerCircle and not self.m_Completed then
        self.m_InnerCircle:Render(InnerCircleRenderer, l_PlayerPos)
    end
end

-- Moves the outer circle (danger zone)
function PhaseManagerClient:MoveOuterCircle(p_Timer)
    PhaseManagerShared.MoveOuterCircle(self, p_Timer)
    Events:DispatchLocal(PhaseManagerCustomEvents.CircleMove, self.m_OuterCircle:AsTable())
end
