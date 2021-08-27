class "CircleEffects"

function CircleEffects:GetVEState()
	return VisualEnvironmentManager:GetStates()[2]
end

function CircleEffects:FixedVisionUpdates()
	if not CircleConfig.UseFog then
		return
	end

	local s_State = self:GetVEState()
	if s_State == nil then
		return
	end

	-- update fog
	local s_Fog = FogData(s_State.fog)
	s_Fog.start = 0
	s_Fog.endValue = 2700
	s_Fog.curve = Vec4(0.7, -0.72, 1.75, -0.65)

	VisualEnvironmentManager:SetDirty(true)
end

function CircleEffects:UpdateFog(p_Diameter)
	if not CircleConfig.UseFog then
		return
	end

	local s_State = self:GetVEState()
	if s_State == nil then
		return
	end

	-- update fog
	local s_Fog = FogData(s_State.fog)
	s_Fog.endValue = math.min(p_Diameter * 3.2, 2700)

	VisualEnvironmentManager:SetDirty(true)
end

-- =============================================
-- Events
-- =============================================

function CircleEffects:OnPhaseManagerUpdate(p_State)
	self:UpdateFog(p_State.OuterCircle.Radius * 2)
end

function CircleEffects:OnOuterCircleMove(p_OuterCircle)
	self:UpdateFog(p_OuterCircle.Radius * 2)
end

function CircleEffects:OnPlayerRespawn()
	self:FixedVisionUpdates()
end

if g_CircleEffects == nil then
	g_CircleEffects = CircleEffects()
end

return g_CircleEffects
