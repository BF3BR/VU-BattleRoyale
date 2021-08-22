class "IOCVision"

function IOCVision:OnPlayerRespawn(p_Player)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= p_Player or p_Player.soldier == nil then
		return
	end

	self:FixedVisionUpdates()
end

function IOCVision:OnPhaseManagerUpdate(p_State)
	if CircleConfig.UseFog then
		self:UpdateFog(p_State.OuterCircle.Radius * 2)
	end
end

function IOCVision:OnOuterCircleMove(p_OuterCircle)
	if CircleConfig.UseFog then
		self:UpdateFog(p_OuterCircle.Radius * 2)
	end
end

function IOCVision:FixedVisionUpdates()
	local s_State = VisualEnvironmentManager:GetStates()[2]

	-- update fog
	local s_Fog = FogData(s_State.fog)
	s_Fog.start = 0
	s_Fog.endValue = 2700
	s_Fog.curve = Vec4(0.7, -0.72, 1.75, -0.65)

	VisualEnvironmentManager:SetDirty(true)
end

function IOCVision:UpdateFog(p_Diameter)
	local s_State = VisualEnvironmentManager:GetStates()[2]

	if s_State == nil then
		return
	end

	-- update fog
	local s_Fog = FogData(s_State.fog)
	s_Fog.endValue = math.min(p_Diameter * 3.2, 2700)

	VisualEnvironmentManager:SetDirty(true)
end

if g_IOCVision == nil then
	g_IOCVision = IOCVision()
end

return g_IOCVision
