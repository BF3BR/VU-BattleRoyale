---@class GunshipCamera
GunshipCamera = class "GunshipCamera"

---@type Logger
local m_Logger = Logger("GunshipCamera", false)

---@type VuBattleRoyaleHud
local m_Hud = require "UI/Hud"

function GunshipCamera:__init()
	self.m_Distance = 50.0
	self.m_Height = 5.5

	self.m_TwoPi = math.pi * 2

	---@type number
	self.m_LockedCameraYaw = 0.0
	---@type number
	self.m_LockedCameraPitch = -0.9

	---@type number
	self.m_MaxPitch = 85.0 * (math.pi / 180.0)
	---@type number
	self.m_MinPitch = -70.0 * (math.pi / 180.0)

	self.m_Data = nil
	self.m_Entity = nil
	self.m_Active = false
	self.m_LookAtPos = nil
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Level:Destroy Event
function GunshipCamera:OnLevelDestroy()
	self:Disable()
end

---Called from GunshipClient
---UpdatePass.UpdatePass_PostFrame
---@param p_DeltaTime number
---@param p_GunshipEntity SpatialEntity|nil
function GunshipCamera:OnUpdatePassPostFrame(p_DeltaTime, p_GunshipEntity)
	if not self.m_Active then
		return
	end

	if p_GunshipEntity == nil then
		return
	end

	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	local s_Yaw = math.atan(p_GunshipEntity.transform.forward.z, p_GunshipEntity.transform.forward.x) + self.m_LockedCameraYaw
	local s_Pitch = self.m_LockedCameraPitch

	s_Yaw = s_Yaw - math.pi
	s_Pitch = s_Pitch + math.pi / 2

	m_Hud:OnGunshipPlayerYaw(s_Yaw)

	self.m_LookAtPos = p_GunshipEntity.transform.trans:Clone()
	self.m_LookAtPos.y = self.m_LookAtPos.y + self.m_Height

	---@type number
	local s_Cosfi = math.cos(s_Yaw)
	local s_Sinfi = math.sin(s_Yaw)

	---@type number
	local s_Costheta = math.cos(s_Pitch)
	local s_Sintheta = math.sin(s_Pitch)

	---@type number
	local s_Cx = self.m_LookAtPos.x + (self.m_Distance * s_Sintheta * s_Cosfi)
	---@type number
	local s_Cy = self.m_LookAtPos.y + (self.m_Distance * s_Costheta)
	---@type number
	local s_Cz = self.m_LookAtPos.z + (self.m_Distance * s_Sintheta * s_Sinfi)
	local s_CameraLocation = Vec3(s_Cx, s_Cy, s_Cz)

	self.m_Data.transform:LookAtTransform(s_CameraLocation, self.m_LookAtPos)
	self.m_Data.transform.left = self.m_Data.transform.left * -1
	self.m_Data.transform.forward = self.m_Data.transform.forward * -1
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Client Input:PreUpdate Hook
---@param p_HookCtx HookContext
---@param p_Cache ConceptCache
---@param p_DeltaTime number
function GunshipCamera:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
	if not self.m_Active then
		return
	end

	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	---@type number
	local s_RotateYaw = p_Cache[InputConceptIdentifiers.ConceptYaw] * 240.0 * p_DeltaTime
	---@type number
	local s_RotatePitch = p_Cache[InputConceptIdentifiers.ConceptPitch] * 240.0 * p_DeltaTime

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

---Creates the CameraEntityData
function GunshipCamera:CreateCameraData()
	if self.m_Data ~= nil then
		return
	end

	self.m_Data = CameraEntityData()
	self.m_Data.fov = 90.0
	self.m_Data.enabled = true
	self.m_Data.priority = 1
	self.m_Data.nameId = "gunship-cam"
	self.m_Data.transform = LinearTransform()
end

---Creates the CameraEntity (Entity)
function GunshipCamera:CreateCamera()
	if self.m_Entity ~= nil then
		return
	end

	self:CreateCameraData()

	local s_Entity = EntityManager:CreateEntity(self.m_Data, self.m_Data.transform)

	if s_Entity ~= nil then
		s_Entity:Init(Realm.Realm_Client, true)
		self.m_Entity = s_Entity
	else
		m_Logger:Write("Creating CameraEntity failed. The player is probably still loading the game. Activating Spectator.")
		SpectatorManager:SetSpectating(true)
	end
end

---Destroys the CameraEntity (Entity)
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

---Fires event "TakeControl" at the entity
function GunshipCamera:TakeControl()
	if self.m_Entity ~= nil then
		self.m_Active = true
		self.m_Entity:FireEvent("TakeControl")
	end
end

---Fires event "ReleaseControl" at the entity
function GunshipCamera:ReleaseControl()
	self.m_Active = false

	if self.m_Entity ~= nil then
		self.m_Entity:FireEvent("ReleaseControl")
	end
end

-- =============================================
-- Enable / Disable Camera
-- =============================================

---Enables the Camera (Create & TakeControl)
function GunshipCamera:Enable()
	self:CreateCamera()
	self:TakeControl()
end

---Disables the Camera (ReleaseControl & Destroy)
function GunshipCamera:Disable()
	self:ReleaseControl()
	self:DestroyCamera()
end

---Returns the current instance transform or nil
---@return LinearTransform|nil
function GunshipCamera:GetTransform()
	return self.m_Data ~= nil and self.m_Data.transform
end

return GunshipCamera()
