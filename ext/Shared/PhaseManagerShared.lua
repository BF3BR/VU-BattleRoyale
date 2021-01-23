class 'PhaseManagerShared'

require ('__shared/Helpers/SubphaseTypes')

function PhaseManagerShared:__init(p_InnerCircle, p_OuterCircle)
    self.m_Phases = phases
    self.m_PhaseIndex = 1
    self.m_SubphaseIndex = SubphaseType.InitialDelay
    self.m_Completed = false

    self.m_InnerCircle = p_InnerCircle
    self.m_OuterCircle = p_OuterCircle

    self.m_PrevOuterCircle = Circle2d()
end

function PhaseManagerShared:GetCurrentPhase()
    return self.m_Phases[self.m_PhaseIndex]
end

function PhaseManagerShared:GetCurrentDelay()
    if self.m_SubphaseIndex == SubphaseType.InitialDelay then
        return 1 -- TODO
    end

    local l_phase = self:GetCurrentPhase()
    if self.m_SubphaseIndex == SubphaseType.Waiting then
        return l_phase.StartsAt
    elseif self.m_SubphaseIndex == SubphaseType.Moving then
        return l_phase.MoveDuration
    end
end

function PhaseManagerShared:IsIdle()
    return self.m_PhaseIndex == 1 and self.m_SubphaseIndex == 1
end

function PhaseManagerShared:MoveOuterCircle(p_Timer)
    local l_Prc = math.min(p_Timer:Elapsed() / self:GetCurrentDelay(), 1.0)

    -- new radius
    local l_RadiusDiff = self.prevOuterCircle.radius - self.innerCircle.radius
    local l_NewRadius = self.innerCircle.radius + l_RadiusDiff * (1 - l_Prc)

    -- new center
    local l_Dx = self.innerCircle.center.x - self.prevOuterCircle.center.x
    local l_Dz = self.innerCircle.center.z - self.prevOuterCircle.center.z
    local l_NewCenter = self.prevOuterCircle.center + Vec3(l_Prc * l_Dx, 0, l_Prc * l_Dz)

    -- update outer circle
    self.outerCircle:Update(l_NewCenter, l_NewRadius)
end

return PhaseManagerShared
