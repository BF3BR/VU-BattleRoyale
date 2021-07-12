require "__shared/Configs/CircleConfig"
require "__shared/Enums/CustomEvents"
require "__shared/Utils/Timers"
require "__shared/Utils/EventRouter"
require "__shared/Types/Circle"
require "__shared/Logic/PhaseManagerShared"
require "Visuals/CircleRenderers"
require "RenderableCircle"

class("PhaseManagerClient", PhaseManagerShared)

local m_IOCVision = require "Visuals/IOCVision"
local m_OOCVision = require "Visuals/OOCVision"

function PhaseManagerClient:RegisterVars()
	PhaseManagerShared.RegisterVars(self)

	self.m_InnerCircle = RenderableCircle()
	self.m_OuterCircle = RenderableCircle()

	self.m_RenderInnerCircle = CircleConfig.RenderInnerCircle

	-- events/hooks
	self.m_LevelLoadedEvent = nil
end

function PhaseManagerClient:RegisterEvents()
	PhaseManagerShared.RegisterEvents(self)

	if self.m_LevelLoadedEvent == nil then
		self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.RequestInitialState)
	end

	Events:Subscribe("UpdatePass_PreSim", self, self.OnPreSim)
	Events:Subscribe(SpectatorEvent.PlayerChanged, self, self.OnSpectatingPlayer)
	Events:Subscribe(EventRouterEvents.UIDrawHudCustom, self, self.OnRender)
	NetEvents:Subscribe(PhaseManagerNetEvent.UpdateState, self, self.OnUpdateState)
end

-- Requests initial state update
function PhaseManagerClient:RequestInitialState()
	NetEvents:SendLocal(PhaseManagerNetEvent.InitialState)

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
		self.m_PrevOuterCircle = Circle(self.m_OuterCircle.m_Center, self.m_OuterCircle.m_Radius)
		self:SetTimer("MovingCircle",
					g_Timers:Sequence(CircleConfig.ClientUpdateMs,
										math.floor(p_State.Duration / CircleConfig.ClientUpdateMs) + 1, self,
										self.MoveOuterCircle))
	end

	-- update inner circle data
	self.m_InnerCircle:Update(p_State.InnerCircle.Center, p_State.InnerCircle.Radius, self.m_PhaseIndex)

	-- update outer circle data
	self.m_OuterCircle:Update(p_State.OuterCircle.Center, p_State.OuterCircle.Radius, self.m_PhaseIndex)

	-- custom event to inform the rest of the client scripts about the state update
	Events:DispatchLocal(PhaseManagerEvent.Update, p_State)
end

-- Returns the position of the local or the spectated player
function PhaseManagerClient:GetActivePlayerPosition()
	local s_Player = PlayerManager:GetLocalPlayer()

	if SpectatorManager:GetSpectating() then
		s_Player = SpectatorManager:GetSpectatedPlayer()
	end

	-- ensure soldier exists
	if s_Player == nil or s_Player.soldier == nil then
		local s_ClientCamera = ClientUtils:GetCameraTransform()

		if s_ClientCamera == nil then
			return nil
		else
			return s_ClientCamera.trans
		end
	end

	-- return the position
	return s_Player.soldier.transform.trans
end

function PhaseManagerClient:OnPreSim(p_DeltaTime)
	if self:IsIdle() then
		return
	end

	-- get active player position
	local s_PlayerPos = self:GetActivePlayerPosition()

	if s_PlayerPos == nil then
		return
	end

	-- toggle OOB vision
	if self.m_OuterCircle:IsInnerPoint(s_PlayerPos) then
		m_OOCVision:Disable()
	else
		m_OOCVision:Enable()
	end

	-- calculate render points for both circles
	self.m_OuterCircle:CalculateRenderPoints(s_PlayerPos)
	if self.m_RenderInnerCircle and not self.m_Completed then
		self.m_InnerCircle:CalculateRenderPoints(s_PlayerPos)
	end
end

-- Renders the two circles
function PhaseManagerClient:OnRender()
	if self:IsIdle() then
		return
	end

	-- get active player position
	local s_PlayerPos = self:GetActivePlayerPosition()

	if s_PlayerPos == nil then
		return
	end

	-- render circles
	self.m_OuterCircle:Render(OuterCircleRenderer, s_PlayerPos)

	if self.m_RenderInnerCircle and not self.m_Completed then
		self.m_InnerCircle:Render(InnerCircleRenderer, s_PlayerPos)
	end
end

-- Moves the outer circle (danger zone)
-- function PhaseManagerClient:MoveOuterCircle(p_Timer)
-- 	PhaseManagerShared.MoveOuterCircle(self, p_Timer)
-- 	Events:DispatchLocal(PhaseManagerEvent.CircleMove, self.m_OuterCircle:AsTable())
-- end
