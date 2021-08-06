class "GunshipCamera"

local m_Hud = require "Hud"

function GunshipCamera:__init()
	self.m_Distance = 50.0
	self.m_Height = 5.5

	self.m_TwoPi = math.pi * 2

	self.m_LockedCameraYaw = 0.0
	self.m_LockedCameraPitch = -0.9

	self.m_MaxPitch = 85.0 * (math.pi / 180.0)
	self.m_MinPitch = -70.0 * (math.pi / 180.0)

	self.m_Data = nil
	self.m_Entity = nil
	self.m_Active = false
	self.m_LookAtPos = nil
end

-- =============================================
-- Events
-- =============================================

function GunshipCamera:OnLevelDestroy()
	self:Disable()
end

function GunshipCamera:OnUpdatePassPostFrame(p_DeltaTime, p_GunshipEntity)
	if not self.m_Active then
		return
	end

	if p_GunshipEntity == nil then
		return
	end

	if not p_GunshipEntity:Is("SpatialEntity") then
		self:Disable()
		return
	end

	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	local s_Entity = SpatialEntity(p_GunshipEntity)
	local s_Yaw = math.atan(s_Entity.transform.forward.z, s_Entity.transform.forward.x) + self.m_LockedCameraYaw
	local s_Pitch = self.m_LockedCameraPitch

	s_Yaw = s_Yaw - math.pi
	s_Pitch = s_Pitch + math.pi / 2

	m_Hud:OnGunshipPlayerYaw(s_Yaw)

	self.m_LookAtPos = s_Entity.transform.trans:Clone()
	self.m_LookAtPos.y = self.m_LookAtPos.y + self.m_Height

	local s_Cosfi = math.cos(s_Yaw)
	local s_Sinfi = math.sin(s_Yaw)

	local s_Costheta = math.cos(s_Pitch)
	local s_Sintheta = math.sin(s_Pitch)

	local s_Cx = self.m_LookAtPos.x + (self.m_Distance * s_Sintheta * s_Cosfi)
	local s_Cy = self.m_LookAtPos.y + (self.m_Distance * s_Costheta)
	local s_Cz = self.m_LookAtPos.z + (self.m_Distance * s_Sintheta * s_Sinfi)
	local s_CameraLocation = Vec3(s_Cx, s_Cy, s_Cz)

	self.m_Data.transform:LookAtTransform(s_CameraLocation, self.m_LookAtPos)
	self.m_Data.transform.left = self.m_Data.transform.left * -1
	self.m_Data.transform.forward = self.m_Data.transform.forward * -1
end

-- =============================================
-- Hooks
-- =============================================

function GunshipCamera:OnInputPreUpdate(p_Hook, p_Cache, p_DeltaTime)
	if not self.m_Active then
		return
	end

	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	local s_RotateYaw = p_Cache[InputConceptIdentifiers.ConceptYaw] * 2.016686
	local s_RotatePitch = p_Cache[InputConceptIdentifiers.ConceptPitch] * 2.016686

	self.m_LockedCameraYaw = self.m_LockedCameraYaw + s_RotateYaw
	self.m_LockedCameraPitch = self.m_LockedCameraPitch + s_RotatePitch

	if self.m_LockedCameraPitch > self.m_MaxPitch then
		self.m_LockedCameraPitch = self.m_MaxPitch
	end

	if self.m_LockedCameraPitch < self.m_MinPitch then
		self.m_LockedCameraPitch = self.m_MinPitch
	end

	while self.m_LockedCameraYaw < 0 do
		self.m_LockedCameraYaw = self.m_TwoPi + self.m_LockedCameraYaw
	end

	while self.m_LockedCameraYaw > self.m_TwoPi do
		self.m_LockedCameraYaw = self.m_LockedCameraYaw - self.m_TwoPi
	end
end

-- =============================================
-- Functions
-- =============================================

-- =============================================
	-- Create / Destroy Camera
-- =============================================

function GunshipCamera:CreateCameraData()
	if self.m_Data ~= nil then
		return
	end

	self.m_Data = CameraEntityData()
	self.m_Data.fov = 90
	self.m_Data.enabled = true
	self.m_Data.priority = 99999
	self.m_Data.nameId = "gunship-cam"
	self.m_Data.transform = LinearTransform()
end

function GunshipCamera:CreateCamera()
	if self.m_Entity ~= nil then
		return
	end

	self:CreateCameraData()

	local s_Entity = EntityManager:CreateEntity(self.m_Data, self.m_Data.transform)

	if s_Entity ~= nil then
		s_Entity:Init(Realm.Realm_Client, true)
		self.m_Entity = s_Entity
	end
end

function GunshipCamera:DestroyCamera()
	if self.m_Entity == nil then
		return
	end

	self.m_Entity:Destroy()
	self.m_Entity = nil
	self.m_LookAtPos = nil
	self.m_LockedCameraYaw = 0.0
	self.m_LockedCameraPitch = -0.9
end

-- =============================================
	-- Take- / ReleaseControl Camera
-- =============================================

function GunshipCamera:TakeControl()
	self.m_Active = true
	self.m_Entity:FireEvent("TakeControl")
end

function GunshipCamera:ReleaseControl()
	self.m_Active = false

	if self.m_Entity ~= nil then
		self.m_Entity:FireEvent("ReleaseControl")
	end
end

-- =============================================
	-- Enable / Disable Camera
-- =============================================

function GunshipCamera:Enable()
	self:CreateCamera()
	self:TakeControl()
end

function GunshipCamera:Disable()
	self:ReleaseControl()
	self:DestroyCamera()
end

if g_GunshipCamera == nil then
	g_GunshipCamera = GunshipCamera()
end

return g_GunshipCamera
