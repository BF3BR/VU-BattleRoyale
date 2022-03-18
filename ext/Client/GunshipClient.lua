---@class GunshipClient
GunshipClient = class "GunshipClient"

---@type Logger
local m_Logger = Logger("GunshipClient", false)

---@type VuBattleRoyaleHud
local m_Hud = require "UI/Hud"
---@type GunshipCamera
local m_GunshipCamera = require "GunshipCamera"

function GunshipClient:__init()
	-- TODO: switch to enum type
	---@type string|nil
	self.m_Type = nil
	self.m_IsInFreeFall = false
	self.m_CumulatedTime = 0.0
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Level:Destroy Event
function GunshipClient:OnLevelDestroy()
	self.m_IsInFreeFall = false
	m_GunshipCamera:OnLevelDestroy()
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PostFrame
---@param p_DeltaTime number
function GunshipClient:OnUpdatePassPostFrame(p_DeltaTime)
	if self.m_Type == nil then
		return
	end

	local s_GunshipEntity = self:GetGunshipEntity()

	if s_GunshipEntity ~= nil then
		m_Hud:OnGunshipPosition(s_GunshipEntity.transform)
		m_Hud:OnGunshipYaw(s_GunshipEntity.transform)
		m_GunshipCamera:OnUpdatePassPostFrame(p_DeltaTime, s_GunshipEntity)
	else
		m_Hud:OnGunshipDisable()
	end
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreSim
---@param p_DeltaTime number
function GunshipClient:OnUpdatePassPreSim(p_DeltaTime)
	if not self.m_IsInFreeFall then
		return
	end

	self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime

	if self.m_CumulatedTime < ServerConfig.RaycastUpdateRate then
		return
	end

	self.m_CumulatedTime = 0.0
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil or s_LocalPlayer.soldier == nil then
		return
	end

	local s_LocalPlayerPos = s_LocalPlayer.soldier.transform.trans
	---@type Vec3
	local s_GroundPosToCheck = s_LocalPlayerPos - Vec3(0.0, ServerConfig.ForceParachuteHeight, 0.0)
	local s_ForceParachute = RaycastManager:Raycast(s_LocalPlayerPos, s_GroundPosToCheck, RayCastFlags.CheckDetailMesh | RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

	if s_ForceParachute ~= nil then
		m_Logger:Write("Open parachute now")
		NetEvents:SendLocal(GunshipEvents.OpenParachute)
		self.m_IsInFreeFall = false
	end
end

---VEXT Client Client:UpdateInput Event
function GunshipClient:OnClientUpdateInput()
	if self.m_Type ~= "Paradrop" then
		return
	end

	if SpectatorManager:GetSpectating() then
		return
	end

	if self.m_IsInFreeFall then
		return
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_E) then
		NetEvents:SendLocal(GunshipEvents.JumpOut, m_GunshipCamera:GetTransform())
		self.m_IsInFreeFall = true
		m_GunshipCamera:Disable()
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

-- TODO: switch to enum
---Custom Client GunshipEvents.Enable NetEvent
---@param p_Type string
function GunshipClient:OnGunshipEnable(p_Type)
	self.m_Type = p_Type
	m_GunshipCamera:Enable()
end

---Custom Client GunshipEvents.Disable NetEvent
function GunshipClient:OnGunshipDisable()
	self.m_Type = nil
	m_Hud:OnGunshipPosition(nil)
	m_Hud:OnGunshipYaw(nil)
	m_GunshipCamera:Disable()
end

---Custom Client GunshipEvents.JumpOut NetEvent
function GunshipClient:OnJumpOutOfGunship()
	m_GunshipCamera:Disable()
end

---Custom Client GunshipEvents.ForceJumpOut NetEvent
function GunshipClient:OnForceJumpOufOfGunship()
	if SpectatorManager:GetSpectating() then
		return
	end

	if self.m_Type == "Paradrop" then
		NetEvents:SendLocal(GunshipEvents.JumpOut, m_GunshipCamera:GetTransform())
		self.m_IsInFreeFall = true
	end
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Client Input:PreUpdate Hook
---@param p_HookCtx HookContext
---@param p_Cache ConceptCache
---@param p_DeltaTime number
function GunshipClient:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
	m_GunshipCamera:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)

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

---Returns the VehicleEntity (SpatialEntity) or nil
---@return SpatialEntity|nil
function GunshipClient:GetGunshipEntity()
	local s_VehicleEntityIterator = EntityManager:GetIterator("ClientVehicleEntity")
	local s_VehicleEntity = s_VehicleEntityIterator:Next()

	while s_VehicleEntity ~= nil do
		if s_VehicleEntity.data.partition.name == "vehicles/xp5/c130/c130" then
			return SpatialEntity(s_VehicleEntity)
		end

		s_VehicleEntity = s_VehicleEntityIterator:Next()
	end

	return nil
end

return GunshipClient()
