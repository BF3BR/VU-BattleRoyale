---@class GunshipServer
GunshipServer = class "GunshipServer"

---@type BRTeamManagerServer
local m_TeamManagerServer = require "BRTeamManagerServer"
---@type Logger
local m_Logger = Logger("GunshipServer", true)

function GunshipServer:__init()
	self:RegisterVars()
end

function GunshipServer:RegisterVars()
	---@type Vec3|nil
	self.m_StartPos = nil
	---@type Vec3|nil
	self.m_EndPos = nil
	---@type number
	self.m_TimeToFly = nil

	self.m_Enabled = false
	---@type string|nil
	self.m_Type = nil
	self.m_CalculatedTime = 0.0

	---@type integer[] @playerIds
	self.m_OpenParachuteList = {}

	self.m_RemoveOnEnd = false
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function GunshipServer:OnExtensionUnloading()
	self:Disable()
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreSim
---@param p_DeltaTime number
function GunshipServer:OnUpdatePassPreSim(p_DeltaTime)
	if not self.m_Enabled then
		return
	end

	if self.m_StartPos == nil or self.m_EndPos == nil or self.m_TimeToFly == nil then
		return
	end

	local s_Transform = LinearTransform()
	s_Transform:LookAtTransform(self.m_StartPos, self.m_EndPos)
	s_Transform.trans = self:GetCurrentPosition()

	if self.m_CalculatedTime == 0.0 then
		self:SetVehicleEntityTransform(s_Transform)
	end

	self:SetLocatorEntityTransform(s_Transform)
	self.m_CalculatedTime = self.m_CalculatedTime + p_DeltaTime / self.m_TimeToFly

	if self.m_RemoveOnEnd and self.m_CalculatedTime >= 1.0 then
		self:Disable()
	end
end

---VEXT Server Player:UpdateInput Event
---@param p_Player Player
function GunshipServer:OnPlayerUpdateInput(p_Player)
	-- if disabled or wrong type
	if not self.m_Enabled or self.m_Type ~= "Paradrop" then
		return
	end

	if #self.m_OpenParachuteList == 0 then
		return
	end

	for l_Index, l_PlayerId in pairs(self.m_OpenParachuteList) do
		local s_Player = PlayerManager:GetPlayerById(l_PlayerId)

		if s_Player ~= nil and s_Player == p_Player then
			m_Logger:Write("Open Parachute for player: " .. s_Player.name)
			s_Player.input:SetLevel(EntryInputActionEnum.EIAToggleParachute, 1.0)
			table.remove(self.m_OpenParachuteList, l_Index)
			return
		end
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

---Custom Server GunshipEvents.JumpOut NetEvent
---@param p_Player Player
---@param p_Transform LinearTransform|nil
function GunshipServer:OnJumpOutOfGunship(p_Player, p_Transform)
	local s_Transform = self:GetDropPosition()

	if p_Transform ~= nil then
		s_Transform.left = p_Transform.left * - 1
		s_Transform.forward = p_Transform.forward * - 1
	end

	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

	if s_BrPlayer == nil then
		m_Logger:Warning("BrPlayer for " .. p_Player.name .. " not found. Create it now.")
		s_BrPlayer = m_TeamManagerServer:CreatePlayer(p_Player)
	end

	s_BrPlayer:Spawn(s_Transform, true)
	NetEvents:SendToLocal(GunshipEvents.JumpOut, p_Player)
end

---Custom Server GunshipEvents.OpenParachute NetEvent
---@param p_Player Player
function GunshipServer:OnOpenParachute(p_Player)
	if p_Player == nil then
		return
	end

	table.insert(self.m_OpenParachuteList, p_Player.id)
end

-- =============================================
-- Functions
-- =============================================

-- =============================================
	-- Enable / Disable Gunship
-- =============================================

---@param p_StartPos Vec3
---@param p_EndPos Vec3
---@param p_TimeToFly number
---@param p_Type string
---@param p_RemoveOnEnd boolean
function GunshipServer:Enable(p_StartPos, p_EndPos, p_TimeToFly, p_Type, p_RemoveOnEnd)
	if p_StartPos == nil or p_EndPos == nil or p_TimeToFly == nil or p_Type == nil then
		return
	end

	if self.m_Enabled then
		self:Disable()
	end

	self.m_CalculatedTime = 0.0
	self.m_StartPos = p_StartPos
	self.m_EndPos = p_EndPos
	self.m_TimeToFly = p_TimeToFly
	self.m_Enabled = true
	self.m_Type = p_Type
	self.m_RemoveOnEnd = p_RemoveOnEnd or false

	self:Spawn()
	NetEvents:BroadcastLocal(GunshipEvents.Enable, p_Type)
end

function GunshipServer:Disable()
	if not self.m_Enabled then
		return
	end

	self:RegisterVars()

	self:Destroy()
	NetEvents:BroadcastLocal(GunshipEvents.Disable)
end

-- =============================================
	-- Spawn / Unspawn Gunship
-- =============================================

function GunshipServer:Spawn()
	local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleSpawnEntity")
	local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()

	while s_VehicleSpawnEntity do
		if s_VehicleSpawnEntity.data.instanceGuid == Guid("5449C054-7A18-4696-8AA9-416A8B9A9CD0") then
			s_VehicleSpawnEntity = Entity(s_VehicleSpawnEntity)
			s_VehicleSpawnEntity:FireEvent("Spawn")
			return
		end

		s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	end
end

function GunshipServer:Destroy()
	local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleSpawnEntity")
	local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()

	while s_VehicleSpawnEntity do
		if s_VehicleSpawnEntity.data.instanceGuid == Guid("5449C054-7A18-4696-8AA9-416A8B9A9CD0") then
			s_VehicleSpawnEntity = Entity(s_VehicleSpawnEntity)
			s_VehicleSpawnEntity:FireEvent("Unspawn")
			return
		end

		s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
	end
end

-- =============================================
	-- Set Functions
-- =============================================

---@param p_Transform LinearTransform
function GunshipServer:SetVehicleEntityTransform(p_Transform)
	local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
	---@type SpatialEntity|nil
	local s_VehicleEntity = s_VehicleEntityIterator:Next()

	while s_VehicleEntity do
		if s_VehicleEntity.data.instanceGuid == Guid("81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778") then
			s_VehicleEntity = SpatialEntity(s_VehicleEntity)
			s_VehicleEntity.transform = p_Transform
			break
		end

		s_VehicleEntity = s_VehicleEntityIterator:Next()
	end
end

---@param p_Transform LinearTransform
function GunshipServer:SetLocatorEntityTransform(p_Transform)
	local s_LocatorEntityIterator = EntityManager:GetIterator("LocatorEntity")
	---@type SpatialEntity|nil
	local s_LocatorEntity = s_LocatorEntityIterator:Next()

	while s_LocatorEntity do
		if s_LocatorEntity.data.instanceGuid == Guid("B7C9767E-4154-49F9-B934-F80923BB82C0") then
			s_LocatorEntity = SpatialEntity(s_LocatorEntity)
			s_LocatorEntity.transform = p_Transform
			return
		end

		s_LocatorEntity = s_LocatorEntityIterator:Next()
	end
end

-- =============================================
	-- Get Functions
-- =============================================

---@return LinearTransform|nil
function GunshipServer:GetVehicleEntityTransform()
	local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
	---@type SpatialEntity|nil
	local s_VehicleEntity = s_VehicleEntityIterator:Next()

	while s_VehicleEntity do
		if s_VehicleEntity.data.instanceGuid == Guid("81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778") then
			s_VehicleEntity = SpatialEntity(s_VehicleEntity)
			return s_VehicleEntity.transform
		end

		s_VehicleEntity = s_VehicleEntityIterator:Next()
	end

	return nil
end

---@return Vec3
function GunshipServer:GetCurrentPosition()
	return Vec3(
		MathUtils:Lerp(self.m_StartPos.x, self.m_EndPos.x, self.m_CalculatedTime),
		self.m_StartPos.y,
		MathUtils:Lerp(self.m_StartPos.z, self.m_EndPos.z, self.m_CalculatedTime)
	)
end

---@return LinearTransform|nil
function GunshipServer:GetDropPosition()
	local s_Transform = self:GetVehicleEntityTransform()

	if s_Transform ~= nil then
		s_Transform.trans = Vec3(s_Transform.trans.x, s_Transform.trans.y - 20, s_Transform.trans.z)
	end

	return s_Transform
end

---@return table
function GunshipServer:GetRandomGunshipPath()
	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return nil
	end

	local s_Return = nil

	local s_Side = math.random(1, 2)

	if s_Side == 1 then
		-- Left to right
		s_Return = {
			StartPos = Vec3(
				MapsConfig[s_LevelName].MapTopLeftPos.x,
				MapsConfig[s_LevelName].PlaneFlyHeight,
				MapsConfig[s_LevelName].MapTopLeftPos.z - math.random(0, MapsConfig[s_LevelName].MapWidthHeight)
			),
			EndPos = Vec3(
				MapsConfig[s_LevelName].MapTopLeftPos.x - MapsConfig[s_LevelName].MapWidthHeight,
				MapsConfig[s_LevelName].PlaneFlyHeight,
				MapsConfig[s_LevelName].MapTopLeftPos.z - math.random(0, MapsConfig[s_LevelName].MapWidthHeight)
			)
		}
	else
		-- Top to bottom
		s_Return = {
			StartPos = Vec3(
				MapsConfig[s_LevelName].MapTopLeftPos.x - math.random(0, MapsConfig[s_LevelName].MapWidthHeight),
				MapsConfig[s_LevelName].PlaneFlyHeight,
				MapsConfig[s_LevelName].MapTopLeftPos.z
			),
			EndPos = Vec3(
				MapsConfig[s_LevelName].MapTopLeftPos.x - math.random(0, MapsConfig[s_LevelName].MapWidthHeight),
				MapsConfig[s_LevelName].PlaneFlyHeight,
				MapsConfig[s_LevelName].MapTopLeftPos.z - MapsConfig[s_LevelName].MapWidthHeight
			)
		}
	end

	local s_Invert = math.random(1, 2)

	if s_Invert == 2 then
		return {
			StartPos = s_Return.EndPos,
			EndPos = s_Return.StartPos
		}
	end

	return s_Return
end

---@return string|nil
function GunshipServer:GetType()
	return self.m_Type
end

---@return boolean
function GunshipServer:IsEnabled()
	return self.m_Enabled
end

return GunshipServer()
