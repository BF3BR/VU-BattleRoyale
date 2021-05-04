class "Gunship"

require "__shared/Enums/CustomEvents"

local m_Hud = require "Hud"
local m_Logger = Logger("Gunship", true)
local m_GunshipCamera = require "GunshipCamera"

function Gunship:__init()
	self.m_Type = nil
	self.m_IsInFreeFall = false
	self.m_CumulatedTime = 0.0
end

function Gunship:RegisterCallbacks()
	-- CameraEntityUs
	ResourceManager:RegisterInstanceLoadHandler(
		Guid("694A231C-4439-461D-A7FF-764915FC3E7C"),
		Guid("6B728CD3-EBD2-4D48-BF49-50A7CFAB0A30"),
		self, self.OnCameraEntityData
	)

	-- CameraEntityRu
	ResourceManager:RegisterInstanceLoadHandler(
		Guid("5D4B1096-3089-45A7-9E3A-422E15E0D8F6"),
		Guid("A4281E60-7557-4BFF-ADD4-18D7E8780873"),
		self, self.OnCameraEntityData
	)
end

-- =============================================
-- Callbacks
-- =============================================

function Gunship:OnCameraEntityData(p_Instance)
	p_Instance = CameraEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.enabled = false
end

-- =============================================
-- Events
-- =============================================

function Gunship:OnLevelDestroy()
	m_GunshipCamera:OnLevelDestroy()
end

function Gunship:OnEngineUpdate(p_DeltaTime)
	local s_GunshipEntity = self:GetGunshipEntity()

	if s_GunshipEntity ~= nil then
		local s_Entity = SpatialEntity(s_GunshipEntity)
		m_Hud:OnGunshipPosition(s_Entity.transform)
		m_Hud:OnGunshipYaw(s_Entity.transform)
		m_GunshipCamera:OnEngineUpdate(p_DeltaTime, s_GunshipEntity)
	end
end

function Gunship:OnUpdatePassPreSim(p_DeltaTime)
	if not self.m_IsInFreeFall then
		return
	end

	self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
	if self.m_CumulatedTime < 0.2 then
		return
	end
	self.m_CumulatedTime = 0

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil or s_LocalPlayer.soldier == nil then
		return
	end

	local s_LocalPlayerPos = s_LocalPlayer.soldier.transform.trans
	local s_GroundPosToCheck = s_LocalPlayerPos - Vec3(0, ServerConfig.ForceParachuteHeight, 0)
	local s_ForceParachute = RaycastManager:Raycast(s_LocalPlayerPos, s_GroundPosToCheck, RayCastFlags.CheckDetailMesh | RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	if s_ForceParachute ~= nil then
		m_Logger:Write("Open parachute now")
		NetEvents:SendLocal(GunshipEvents.OpenParachute)
		self.m_IsInFreeFall = false
	end
end

function Gunship:OnClientUpdateInput()
	if self.m_Type ~= "Paradrop" then
		return
	end

	if InputManager:IsKeyDown(InputDeviceKeys.IDK_E) then
		NetEvents:SendLocal(GunshipEvents.JumpOut)
		self.m_IsInFreeFall = true
		m_GunshipCamera:Disable()
	end
end

-- =============================================
-- Custom Events
-- =============================================

function Gunship:OnGunshipEnable(p_Type)
	self.m_Type = p_Type
	m_GunshipCamera:Enable()
end

function Gunship:OnGunshipDisable()
	self.m_Type = nil
	m_Hud:OnGunshipPosition(nil)
	m_Hud:OnGunshipYaw(nil)
	m_GunshipCamera:Disable()
end

function Gunship:OnForceJumpOufOfGunship()
	if self.m_Type == "Paradrop" then
		NetEvents:SendLocal(GunshipEvents.JumpOut)
		self.m_IsInFreeFall = true
		-- self:OnGunshipDisable()
	end
end

-- =============================================
-- Hooks
-- =============================================

function Gunship:OnInputPreUpdate(p_Hook, p_Cache, p_Dt)
	m_GunshipCamera:OnInputPreUpdate(p_Hook, p_Cache, p_Dt)

	if not self.m_IsInFreeFall then
		return
	end

	local s_Player = PlayerManager:GetLocalPlayer()

	if s_Player == nil then
		return
	end

	if p_Cache[InputConceptIdentifiers.ConceptParachute] == 1.0 then
		self.m_IsInFreeFall = false
	end
end

-- =============================================
-- Functions
-- =============================================

function Gunship:GetGunshipEntity()
	local s_VehicleEntityIterator = EntityManager:GetIterator("ClientVehicleEntity")
	local s_VehicleEntity = s_VehicleEntityIterator:Next()

	while s_VehicleEntity ~= nil do
		if s_VehicleEntity.data.partition.name == "vehicles/xp5/c130/c130" then
			return s_VehicleEntity
		end

		s_VehicleEntity = s_VehicleEntityIterator:Next()
	end

	return nil
end

if g_Gunship == nil then
	g_Gunship = Gunship()
end

return g_Gunship
