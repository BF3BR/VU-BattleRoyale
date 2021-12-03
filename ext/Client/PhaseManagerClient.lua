class("PhaseManagerClient", PhaseManagerShared)

local m_OOCVision = require "Visuals/OOCVision"

function PhaseManagerClient:RegisterVars()
	PhaseManagerShared.RegisterVars(self)

	self.m_InnerCircle = RenderableCircle()
	self.m_OuterCircle = RenderableCircle()

	-- we want to get the state only once
	self.m_RequestedInitialState = false
end

-- =============================================
-- Events
-- =============================================

function PhaseManagerClient:OnLevelLoaded()
	PhaseManagerShared.OnLevelLoaded(self)

	self:RequestInitialState()
end

function PhaseManagerClient:OnUpdatePassPreSim(p_DeltaTime)
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
	if CircleConfig.RenderInnerCircle and not self.m_Completed then
		self.m_InnerCircle:CalculateRenderPoints(s_PlayerPos)
	end
end

-- Renders the two circles
function PhaseManagerClient:OnUIDrawHud()
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
	if CircleConfig.RenderInnerCircle and not self.m_Completed then
		self.m_InnerCircle:Render(InnerCircleRenderer, s_PlayerPos)
	end
end

-- =============================================
-- Custom (Net-) Events
-- =============================================

-- Updates the state of the PhaseManager from the server
function PhaseManagerClient:OnPhaseManagerUpdateState(p_State)
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
	self.m_InnerCircle:Update(p_State.InnerCircle.Center, p_State.InnerCircle.Radius)

	-- update outer circle data
	self.m_OuterCircle:Update(p_State.OuterCircle.Center, p_State.OuterCircle.Radius)

	-- update render parameters for circle
	self.m_OuterCircle:UpdateRenderParameters()

	-- custom event to inform the rest of the client scripts about the state update
	Events:DispatchLocal(PhaseManagerEvent.Update, p_State)
end

-- =============================================
-- Functions
-- =============================================

-- Requests initial state update
function PhaseManagerClient:RequestInitialState()
	if not self.m_RequestedInitialState then
		self.m_RequestedInitialState = true
		NetEvents:SendLocal(PhaseManagerNetEvent.InitialState)
	end
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

return PhaseManagerClient()
