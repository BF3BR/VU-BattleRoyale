class ("PhaseManagerShared", TimersMixin)

local m_Logger = Logger("PhaseManagerShared", true)

function PhaseManagerShared:__init()
	TimersMixin.__init(self)

	self:RegisterVars()
end

function PhaseManagerShared:RegisterVars()
	self.m_InnerCircle = Circle()
	self.m_OuterCircle = Circle()
	self.m_PrevOuterCircle = Circle()

	self.m_InitialDelay = 0
	self.m_Phases = {}

	self.m_PhaseIndex = 1
	self.m_SubphaseIndex = SubphaseType.InitialDelay
	self.m_Completed = false

	-- self:LoadPhases()
end

function PhaseManagerShared:LoadPhases()
	-- get and check config for the current map
	local s_MapConfig = MapsConfig[LevelNameHelper:GetLevelName()]

	if s_MapConfig == nil then
		m_Logger:Error("invalid level name")
		return
	end

	self.m_Phases = s_MapConfig.Phases
	self.m_InitialDelay = s_MapConfig.BeforeFirstCircleDelay
end

-- =============================================
-- Events
-- =============================================

function PhaseManagerShared:OnExtensionUnloading()
	self:Destroy()
end

function PhaseManagerShared:OnLevelLoaded()
	self:LoadPhases()
end

function PhaseManagerShared:OnLoadResources()
	self:LoadPhases()
end


function PhaseManagerShared:OnLevelDestroy()
	self:Destroy()
end

-- =============================================
-- Functions
-- =============================================

function PhaseManagerShared:GetCurrentPhase()
	return self.m_Phases[self.m_PhaseIndex]
end

function PhaseManagerShared:GetCurrentDelay()
	if self.m_Completed then
		return -1
	elseif self.m_SubphaseIndex == SubphaseType.InitialDelay then
		return self.m_InitialDelay
	end

	local s_Phase = self:GetCurrentPhase()

	if self.m_SubphaseIndex == SubphaseType.Waiting then
		return s_Phase.StartsAt
	elseif self.m_SubphaseIndex == SubphaseType.Moving then
		return s_Phase.MoveDuration
	end
end

-- Checks if the PhaseManager is in the initial delay phase
function PhaseManagerShared:IsIdle()
	return self.m_PhaseIndex == 1 and self.m_SubphaseIndex == SubphaseType.InitialDelay
end

-- Moves the outer circle (danger zone)
function PhaseManagerShared:MoveOuterCircle(p_Timer)
	local s_Prc = math.min(p_Timer:Elapsed() / self:GetCurrentDelay(), 1.0)

	-- new radius
	local s_RadiusDiff = self.m_PrevOuterCircle.m_Radius - self.m_InnerCircle.m_Radius
	local s_NewRadius = self.m_InnerCircle.m_Radius + s_RadiusDiff * (1 - s_Prc)

	-- new center
	local s_Dx = self.m_InnerCircle.m_Center.x - self.m_PrevOuterCircle.m_Center.x
	local s_Dz = self.m_InnerCircle.m_Center.z - self.m_PrevOuterCircle.m_Center.z
	local s_NewCenter = self.m_PrevOuterCircle.m_Center + Vec3(s_Prc * s_Dx, 0, s_Prc * s_Dz)

	-- update outer circle
	self.m_OuterCircle:Update(s_NewCenter, s_NewRadius)

	Events:DispatchLocal(PhaseManagerEvent.CircleMove, self.m_OuterCircle:AsTable())
end

function PhaseManagerShared:Destroy()
	self:RemoveTimers()
	self:RegisterVars()
end
