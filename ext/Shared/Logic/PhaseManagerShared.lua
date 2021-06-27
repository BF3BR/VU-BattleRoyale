require "__shared/Configs/MapsConfig"
require "__shared/Enums/CustomEvents"
require "__shared/Enums/SubphaseTypes"
require "__shared/Utils/LevelNameHelper"
require "__shared/Mixins/TimersMixin"

class ("PhaseManagerShared", TimersMixin)

local m_Logger = Logger("PhaseManagerShared", true)

function PhaseManagerShared:__init()
    TimersMixin.__init(self)

    self:RegisterVars()
    self:RegisterEvents()
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
end

function PhaseManagerShared:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Destroy", self, self.Destroy)
    Events:Subscribe("Extension:Unloading", self, self.Destroy)
end

function PhaseManagerShared:OnLevelLoaded()
    -- get and check config for the current map
    local l_MapConfig = MapsConfig[LevelNameHelper:GetLevelName()]

    if l_MapConfig == nil then
        m_Logger:Error("invalid level name")
        return
    end

    self.m_Phases = l_MapConfig.Phases
    self.m_InitialDelay = l_MapConfig.BeforeFirstCircleDelay
end

function PhaseManagerShared:GetCurrentPhase()
    return self.m_Phases[self.m_PhaseIndex]
end

function PhaseManagerShared:GetCurrentDelay()
    if self.m_Completed then
        return -1
    elseif self.m_SubphaseIndex == SubphaseType.InitialDelay then
        return self.m_InitialDelay
    end

    local l_phase = self:GetCurrentPhase()

    if self.m_SubphaseIndex == SubphaseType.Waiting then
        return l_phase.StartsAt
    elseif self.m_SubphaseIndex == SubphaseType.Moving then
        return l_phase.MoveDuration
    end
end

-- Checks if the PhaseManager is in the initial delay phase
function PhaseManagerShared:IsIdle()
    return self.m_PhaseIndex == 1 and self.m_SubphaseIndex == SubphaseType.InitialDelay
end

-- Moves the outer circle (danger zone)
function PhaseManagerShared:MoveOuterCircle(p_Timer)
    local l_Prc = math.min(p_Timer:Elapsed() / self:GetCurrentDelay(), 1.0)

    -- new radius
    local l_RadiusDiff = self.m_PrevOuterCircle.m_Radius - self.m_InnerCircle.m_Radius
    local l_NewRadius = self.m_InnerCircle.m_Radius + l_RadiusDiff * (1 - l_Prc)

    -- new center
    local l_Dx = self.m_InnerCircle.m_Center.x - self.m_PrevOuterCircle.m_Center.x
    local l_Dz = self.m_InnerCircle.m_Center.z - self.m_PrevOuterCircle.m_Center.z
    local l_NewCenter = self.m_PrevOuterCircle.m_Center + Vec3(l_Prc * l_Dx, 0, l_Prc * l_Dz)

    -- update outer circle
    self.m_OuterCircle:Update(l_NewCenter, l_NewRadius)

    Events:DispatchLocal(PhaseManagerEvent.CircleMove, self.m_OuterCircle:AsTable())
end

function PhaseManagerShared:Destroy()
    self:RemoveTimers()
    self:RegisterVars()
end

function PhaseManagerShared:__gc()
    self:Destroy()
end
