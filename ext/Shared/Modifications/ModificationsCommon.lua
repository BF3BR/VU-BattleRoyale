class "ModificationsCommon"

local m_Logger = Logger("ModificationsCommon", true)
local m_RegistryManager = require "__shared/Logic/RegistryManager"
local m_WeaponDropModifier = require "__shared/Modifications/Soldiers/WeaponDropModifier"
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier"
local m_WeaponSwitchingModifier = require "__shared/Modifications/Soldiers/WeaponSwitchingModifier"
local m_PhysicsModifier = require "__shared/Modifications/Soldiers/PhysicsModifier"
local m_WeaponsModifier = require "__shared/Modifications/WeaponsModifier"
local m_DropShipModifier = require "__shared/Modifications/DropShipModifier"
local m_LootCreation = require "__shared/Modifications/LootCreation"

local m_TempMapPatches = require "__shared/Modifications/TempMapPatches"

local m_SoldierBlueprint = DC(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"), Guid("261E43BF-259B-41D2-BF3B-9AE4DDA96AD2"))

function ModificationsCommon:__init()

end

function ModificationsCommon:RegisterCallbacks()
	m_SoldierBlueprint:RegisterLoadHandler(self, self.OnSoldierBlueprintLoaded)

	m_WeaponSwitchingModifier:RegisterCallbacks()
	m_WeaponsModifier:RegisterCallbacks()
	m_DropShipModifier:RegisterCallbacks()
	m_TempMapPatches:RegisterCallbacks()
	m_PhysicsModifier:RegisterCallbacks()
end

function ModificationsCommon:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	m_Logger:Write("SoldierBlueprint Loaded")

	m_WeaponDropModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	m_ManDownModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	m_TempMapPatches:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
end

function ModificationsCommon:OnRegisterEntityResources(p_LevelData)
	m_WeaponDropModifier:OnRegisterEntityResources(p_LevelData)
end

-- TODO: Implement generic map and gamemode modification system (that works)
--[[
function ModificationsCommon:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_Logger:Write("OnLoadResources")

	local s_MapId = LevelNameHelper:GetLevelName()
	local s_Config = MapsConfig[s_MapId]
	if s_Config == nil then
		m_Logger:Write("Unsupported map!")
		return
	end

	-- Register a load handler for the cql subworld of this level
	--s_Config.SubWorldInstance:RegisterLoadHandlerOnce(self, self.OnSubWorldLoaded)
end

function ModificationsCommon:OnSubWorldLoaded(p_SubWorldData)
	m_Logger:Write("SubWorld Loaded")
	local s_Registry = m_RegistryManager:GetRegistry()

	local s_WorldPartData = WorldPartData()
	s_Registry.blueprintRegistry:add(s_WorldPartData)

	local s_WorldPartReferenceObjectData = WorldPartReferenceObjectData()
	s_WorldPartReferenceObjectData.blueprint = s_WorldPartData
	s_Registry.referenceObjectRegistry:add(s_WorldPartReferenceObjectData)

	p_SubWorldData.objects:add(s_WorldPartReferenceObjectData)

	m_LootCreation:OnSubWorldLoaded(s_WorldPartData)
end
--]]

if g_ModificationsCommon == nil then
	g_ModificationsCommon = ModificationsCommon()
end

return g_ModificationsCommon
