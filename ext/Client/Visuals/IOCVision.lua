require "__shared/Enums/CustomEvents"
require "__shared/Configs/CircleConfig"

class "IOCVision"

function IOCVision:__init()
    self:RegisterEvents()
end

function IOCVision:RegisterEvents()
    if CircleConfig.UseFog then
        -- should move to initial data mod
        Events:Subscribe("Player:Respawn", self, self.FixedVisionUpdates)

        Events:Subscribe(PhaseManagerCustomEvents.Update, self, self.OnUpdate)
        Events:Subscribe(PhaseManagerCustomEvents.CircleMove, self, self.OnCircleMove)
    end
end

function IOCVision:FixedVisionUpdates()
    local l_State = VisualEnvironmentManager:GetStates()[2]

    -- update fog
    local l_Fog = FogData(l_State.fog)
    l_Fog.start = 0
    l_Fog.endValue = 2700
    l_Fog.curve = Vec4(0.7, -0.72, 1.75, -0.65)

    VisualEnvironmentManager:SetDirty(true)
end

function IOCVision:UpdateFog(p_Diameter)
    local l_State = VisualEnvironmentManager:GetStates()[2]

    -- update fog
    local l_Fog = FogData(l_State.fog)
    l_Fog.endValue = math.min(p_Diameter * 3.2, 2700)

    VisualEnvironmentManager:SetDirty(true)
end

function IOCVision:OnUpdate(p_State)
    self:UpdateFog(p_State.OuterCircle.Radius * 2)
end

function IOCVision:OnCircleMove(p_OuterCircle)
    self:UpdateFog(p_OuterCircle.Radius * 2)
end

-- define global
if g_IOCVision == nil then
    g_IOCVision = IOCVision()
end

return g_IOCVision
