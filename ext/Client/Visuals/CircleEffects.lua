class "CircleEffects"

local m_Logger = Logger("CircleEffects", true)
-- local m_SoundAsset = DC(Guid("5145EFCF-3AC5-11E0-865E-E2CC2A8011A4"), Guid("DB3F3E26-BE08-D88B-32AE-27E70F5D4A56")) -- radar
local m_SoundAsset = DC(Guid("65D41786-02F6-11E0-9C91-BF94ADC99AAE"), Guid("7B7F76E6-2648-62AE-608B-9A81CBF8CAB4")) -- fire medium

function CircleEffects:__init()
	self:ResetVars()
end

function CircleEffects:ResetVars()
	self.m_Circle = Circle()
	self.m_SoundEntity = nil
	self.m_LastCameraPosition = nil
end

function CircleEffects:CreateSoundEntity()
	if self.m_SoundEntity ~= nil then
		return
	end

	local s_SoundAsset = m_SoundAsset:GetInstance()
	if s_SoundAsset == nil then
		return
	end

	-- update sound properties
	s_SoundAsset = SoundPatchAsset(s_SoundAsset):Clone()
	s_SoundAsset:MakeWritable()
	s_SoundAsset.loudness = 70
	s_SoundAsset.radius = 2
	s_SoundAsset.isLooping = true

	-- create sound effect data
	local s_EntityData = SoundEffectEntityData()
	s_EntityData.sound = s_SoundAsset

	-- create sound effect entity
	if s_EntityData ~= nil then
		local s_EntityPos = LinearTransform()
		s_EntityPos.trans = Vec3(0.0, 500, 0.0)

		local s_Entity = EntityManager:CreateEntity(s_EntityData, s_EntityPos)
		if s_Entity ~= nil then
			s_Entity:Init(Realm.Realm_Client, true)
			self.m_SoundEntity = SpatialEntity(s_Entity)

			s_Entity:FireEvent("Start")
		end
	end
end

function CircleEffects:GetSoundEntity()
	if self.m_SoundEntity == nil then
		self:CreateSoundEntity()
	end

	return self.m_SoundEntity
end

function CircleEffects:UpdateSoundPosition(p_Forced)
	if not CircleConfig.EnableCircleSound then
		return
	end

	local s_Camera = ClientUtils:GetCameraTransform()
	if s_Camera == nil then
		return
	end

	-- skip moving if it's at the same position as before
	local s_CameraPosition = s_Camera.trans
	if not p_Forced and s_CameraPosition == self.m_LastCameraPosition then
		return
	end
	self.m_LastCameraPosition = s_CameraPosition

	local s_SoundEntity = self:GetSoundEntity()
	if s_SoundEntity == nil then
		return
	end

	-- calculate closest circle point
	local s_CameraAngle = MathHelper:VectorAngle(self.m_Circle.m_Center, s_CameraPosition)
	local s_ClosestCircumferencePoint = self.m_Circle:CircumferencePoint(s_CameraAngle, s_CameraPosition.y)

	-- skip moving if camera is away from circle edge
	if s_ClosestCircumferencePoint:Distance(s_CameraPosition) > 15 then
		return
	end

	-- reset .transform, cause just updating .trans doesnt move the sound
	local s_Transform = s_SoundEntity.transform
	s_Transform.trans = s_ClosestCircumferencePoint

	s_SoundEntity.transform = s_Transform
end

function CircleEffects:GetVEState()
	return VisualEnvironmentManager:GetStates()[2]
end

function CircleEffects:FixedVisionUpdates()
	if not CircleConfig.EnableFog then
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

function CircleEffects:UpdateFog()
	if not CircleConfig.EnableFog then
		return
	end

	local s_State = self:GetVEState()
	if s_State == nil then
		return
	end

	-- update fog
	local s_Fog = FogData(s_State.fog)
	s_Fog.endValue = math.min(self.m_Circle:Diameter() * 3.2, 2700)

	VisualEnvironmentManager:SetDirty(true)
end

function CircleEffects:Destroy()
	if self.m_SoundEntity ~= nil then
		self.m_SoundEntity:Destroy()
		self.m_SoundEntity = nil
	end

	self:ResetVars()
end

-- =============================================
-- Events
-- =============================================

function CircleEffects:OnPhaseManagerUpdate(p_State)
	self.m_Circle:Update(p_State.OuterCircle.Center, p_State.OuterCircle.Radius)
	self:UpdateSoundPosition(true)
	self:UpdateFog()
end

function CircleEffects:OnOuterCircleMove(p_OuterCircle)
	self.m_Circle:Update(p_OuterCircle.Center, p_OuterCircle.Radius)
	self:UpdateSoundPosition(true)
	self:UpdateFog()
end

function CircleEffects:OnPlayerRespawn()
	self:FixedVisionUpdates()
end

function CircleEffects:OnUIDrawHud()
	self:UpdateSoundPosition()
end

function CircleEffects:OnLevelDestroy()
	self:Destroy()
end

function CircleEffects:OnExtensionUnloading()
	self:Destroy()
end

return CircleEffects()
