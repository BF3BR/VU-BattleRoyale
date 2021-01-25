require ('__shared/Helpers/SubphaseTypes')
require ('__shared/Mixins/TimersMixin')

class ('PhaseManagerShared', TimersMixin)

PhaseManagerNetEvents = {
    UpdateState = 1
}

function PhaseManagerShared:__init(p_InnerCircle, p_OuterCircle, p_InitialDelay)
    TimersMixin.__init(self)
    self:RegisterVars(p_InnerCircle, p_OuterCircle, p_InitialDelay)
end

function PhaseManagerShared:RegisterVars(p_InnerCircle, p_OuterCircle, p_InitialDelay)
    self.m_InnerCircle = p_InnerCircle
    self.m_OuterCircle = p_OuterCircle
    self.m_InitialDelay = p_InitialDelay

    self.m_PrevOuterCircle = Circle()
    self.m_Phases = nil
    self.m_PhaseIndex = 1
    self.m_SubphaseIndex = SubphaseType.InitialDelay
    self.m_Completed = false
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

function PhaseManagerShared:IsIdle()
    return self.m_PhaseIndex == 1 and self.m_SubphaseIndex == SubphaseType.InitialDelay
end

function PhaseManagerShared:MoveOuterCircle(p_Timer)
    local l_Prc = math.min(p_Timer:Elapsed() / self:GetCurrentDelay(), 1.0)

    -- new radius
    local l_RadiusDiff = self.m_PrevOuterCircle.radius - self.m_InnerCircle.radius
    local l_NewRadius = self.m_InnerCircle.radius + l_RadiusDiff * (1 - l_Prc)

    -- new center
    local l_Dx = self.m_InnerCircle.center.x - self.m_PrevOuterCircle.center.x
    local l_Dz = self.m_InnerCircle.center.z - self.m_PrevOuterCircle.center.z
    local l_NewCenter = self.m_PrevOuterCircle.center + Vec3(l_Prc * l_Dx, 0, l_Prc * l_Dz)

    -- update outer circle
    self.outerCircle:Update(l_NewCenter, l_NewRadius)
end

function PhaseManagerShared:Destroy()
    self:ClearAllTimers()
end

return PhaseManagerShared
