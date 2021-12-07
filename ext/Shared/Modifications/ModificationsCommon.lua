class "ModificationsCommon"

local m_Logger = Logger("ModificationsCommon", true)
local m_RegistryManager = require "__shared/Logic/RegistryManager"
local m_WeaponDropModifier = require "__shared/Modifications/Soldiers/WeaponDropModifier"
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier"
local m_WeaponSwitchingModifier = require "__shared/Modifications/Soldiers/WeaponSwitchingModifier"
local m_PhysicsModifier = require "__shared/Modifications/Soldiers/PhysicsModifier"
local m_WeaponsModifier = require "__shared/Modifications/WeaponsModifier"
local m_DropShipModifier = require "__shared/Modifications/DropShipModifier"
local m_VanillaUIModifier = require "__shared/Modifications/VanillaUIModifier"
local m_2dTreeRemoving = require "__shared/Modifications/2dTreeRemoving"
local m_MapSpecificModifier = require "__shared/Modifications/MapSpecificModifier"
local m_FireEffectsModifier = require "__shared/Modifications/FX/FireEffectsModifier"
local m_RemoveVanillaLoadingScreen = require "__shared/Modifications/LoadingScreen/RemoveVanillaLoadingScreen"
local m_RemoveAutotriggerVO = require "__shared/Modifications/Sound/RemoveAutoTriggerVO"
local m_TimeOutFix = require "__shared/Modifications/TimeOutFix"
local m_DisableDebugRenderer = require "__shared/Modifications/DisableDebugRenderer"
local m_AirdropSmokeModifier = require "__shared/Modifications/FX/AirdropSmokeModifier"
local m_Airdrop = require "__shared/Modifications/Airdrop"
local m_ShowroomModifier = require "__shared/Modifications/ShowroomModifier"
local m_ConquestLargeModifier = require "__shared/Modifications/ConquestLargeModifier"
local m_GameModeSettingsModifier = require "__shared/Modifications/GameModeSettingsModifier"

local m_SoldierBlueprint = DC(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"), Guid("261E43BF-259B-41D2-BF3B-9AE4DDA96AD2"))

function ModificationsCommon:RegisterCallbacks()
	m_SoldierBlueprint:RegisterLoadHandler(self, self.OnSoldierBlueprintLoaded)

	m_WeaponSwitchingModifier:RegisterCallbacks()
	m_WeaponsModifier:RegisterCallbacks()
	m_DropShipModifier:RegisterCallbacks()
	m_VanillaUIModifier:RegisterCallbacks()
	m_PhysicsModifier:RegisterCallbacks()
	m_2dTreeRemoving:RegisterCallbacks()
	m_FireEffectsModifier:RegisterCallbacks()
	m_AirdropSmokeModifier:RegisterCallbacks()
	m_ManDownModifier:RegisterCallbacks()
	m_RemoveAutotriggerVO:RegisterCallbacks()
	m_TimeOutFix:RegisterCallbacks()
	m_ShowroomModifier:RegisterCallbacks()
	m_Airdrop:RegisterCallbacks()
	m_ConquestLargeModifier:RegisterCallbacks()
	m_GameModeSettingsModifier:RegisterCallbacks()
end

function ModificationsCommon:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	m_Logger:Write("SoldierBlueprint Loaded")

	m_WeaponDropModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	m_ManDownModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
end

function ModificationsCommon:OnExtensionLoaded()
	m_RemoveVanillaLoadingScreen:OnExtensionLoaded()
	m_DisableDebugRenderer:OnExtensionLoaded()
end

function ModificationsCommon:OnExtensionUnloading()
	m_RemoveVanillaLoadingScreen:OnExtensionUnloading()
	m_DisableDebugRenderer:OnExtensionUnloading()
end

function ModificationsCommon:OnRegisterEntityResources(p_LevelData)
	m_FireEffectsModifier:OnRegisterEntityResources()
	m_Airdrop:OnRegisterEntityResources()
end

function ModificationsCommon:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	m_Logger:Write("OnLoadResources")

	local s_MapId = LevelNameHelper:GetLevelName()
	local s_MapConfig = MapsConfig[s_MapId]

	if s_MapConfig == nil or s_MapConfig.MapPreset == nil then
		m_Logger:Write("This map is not supported.")
		m_SoldierBlueprint:Deregister()
		m_WeaponSwitchingModifier:DeregisterCallbacks()
		m_WeaponsModifier:DeregisterCallbacks()
		m_DropShipModifier:DeregisterCallbacks()
		m_VanillaUIModifier:DeregisterCallbacks()
		m_MapSpecificModifier:DeregisterCallbacks()
		m_PhysicsModifier:DeregisterCallbacks()
		m_2dTreeRemoving:DeregisterCallbacks()
		m_FireEffectsModifier:DeregisterCallbacks()
		m_AirdropSmokeModifier:DeregisterCallbacks()
		m_ManDownModifier:DeregisterCallbacks()
		m_RemoveAutotriggerVO:DeregisterCallbacks()
		m_ShowroomModifier:DeregisterCallbacks()
		m_Airdrop:DeregisterCallbacks()
		m_ConquestLargeModifier:DeregisterCallbacks()
		m_GameModeSettingsModifier:DeregisterCallbacks()
		return
	end

	-- Register a load handler for the cql subworld of this level
	--s_MapConfig.SubWorldInstance:RegisterLoadHandlerOnce(self, self.OnSubWorldLoaded)
	m_MapSpecificModifier:RegisterCallbacks(s_MapConfig)
end

-- TODO: Implement generic map and gamemode modification system (that works)
--[[
function ModificationsCommon:OnSubWorldLoaded(p_SubWorldData)
	m_Logger:Write("SubWorld Loaded")
	local s_Registry = m_RegistryManager:GetRegistry()

	local s_WorldPartData = WorldPartData()
	s_Registry.blueprintRegistry:add(s_WorldPartData)

	local s_WorldPartReferenceObjectData = WorldPartReferenceObjectData()
	s_WorldPartReferenceObjectData.blueprint = s_WorldPartData
	s_Registry.referenceObjectRegistry:add(s_WorldPartReferenceObjectData)

	p_SubWorldData.objects:add(s_WorldPartReferenceObjectData)
end
--]]


return ModificationsCommon()
