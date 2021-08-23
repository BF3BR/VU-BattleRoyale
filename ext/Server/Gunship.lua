class "Gunship"

require "__shared/Utils/MathHelper"
require "__shared/Enums/CustomEvents"

local m_TeamManager = require "BRTeamManager"
local m_Logger = Logger("Gunship", true)

function Gunship:__init()
	self:RegisterVars()
end

function Gunship:RegisterVars()
	self.m_StartPos = nil
	self.m_EndPos = nil
	self.m_TimeToFly = nil

	self.m_VehicleEntity = nil
	self.m_Enabled = false
	self.m_CalculatedTime = 0.0

	self.m_OpenParachuteList = {}
end

-- =============================================
-- Events
-- =============================================

function Gunship:OnExtensionUnloading()
	self:Disable()
end

function Gunship:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if not self.m_Enabled then
		return
	end

	if self.m_StartPos == nil or self.m_EndPos == nil or self.m_TimeToFly == nil then
		return
	end

	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		local s_Transform = LinearTransform()
		s_Transform:LookAtTransform(self.m_StartPos, self.m_EndPos)
		s_Transform.trans = self:GetCurrentPosition(self.m_CalculatedTime)

		if self.m_CalculatedTime == 0.0 then
			self:SetVehicleEntityTransform(s_Transform)
		end

		self:SetLocatorEntityTransform(s_Transform)
		self.m_CalculatedTime = self.m_CalculatedTime + p_DeltaTime / self.m_TimeToFly

		--[[if self.m_CalculatedTime >= 1.0 then
			self:Disable()
		end]]
	end
end

function Gunship:OnPlayerUpdateInput(p_Player)
	if not self.m_Enabled and self.m_Type ~= "Paradrop" then
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

function Gunship:OnJumpOutOfGunship(p_Player, p_Transform)
	local s_Transform = self:GetVehicleEntityTransform()
	s_Transform.trans = Vec3(s_Transform.trans.x, s_Transform.trans.y - 20, s_Transform.trans.z)

	if p_Transform ~= nil then
		s_Transform.left = p_Transform.left * - 1
		s_Transform.up = p_Transform.up * - 1
		s_Transform.forward = p_Transform.forward * - 1
	end

	local s_BrPlayer = m_TeamManager:GetPlayer(p_Player)

	if s_BrPlayer == nil then
		return
	end

	s_BrPlayer:Spawn(s_Transform)
	NetEvents:SendToLocal(GunshipEvents.JumpOut, p_Player)
end

function Gunship:OnOpenParachute(p_Player)
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

function Gunship:Enable(p_StartPos, p_EndPos, p_TimeToFly, p_Type)
	if self.m_Enabled then
		return
	end

	if p_StartPos == nil or p_EndPos == nil or p_TimeToFly == nil or p_Type == nil then
		return
	end

	self.m_CalculatedTime = 0.0
	self.m_StartPos = p_StartPos
	self.m_EndPos = p_EndPos
	self.m_TimeToFly = p_TimeToFly
	self.m_Enabled = true

	self:Spawn()
	NetEvents:BroadcastLocal(GunshipEvents.Enable, p_Type)
end

function Gunship:Disable()
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

function Gunship:Spawn()
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

function Gunship:Destroy()
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

function Gunship:SetVehicleEntityTransform(p_Transform)
	local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
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

function Gunship:SetLocatorEntityTransform(p_Transform)
	local s_LocatorEntityIterator = EntityManager:GetIterator("LocatorEntity")
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

function Gunship:GetVehicleEntityTransform()
	local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
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

function Gunship:GetCurrentPosition(p_Time)
	return Vec3(
		MathUtils:Lerp(self.m_StartPos.x, self.m_EndPos.x, p_Time),
		self.m_StartPos.y,
		MathUtils:Lerp(self.m_StartPos.z, self.m_EndPos.z, p_Time)
	)
end

if g_Gunship == nil then
	g_Gunship = Gunship()
end

return g_Gunship
