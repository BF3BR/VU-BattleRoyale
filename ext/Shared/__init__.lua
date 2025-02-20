---@class VuBattleRoyaleShared
VuBattleRoyaleShared = class "VuBattleRoyaleShared"

require "__shared/Enums/AirdropEnums"
require "__shared/Enums/Attachments"
require "__shared/Enums/BRPlayerState"
require "__shared/Enums/CustomEvents"
require "__shared/Enums/GameStates"
require "__shared/Enums/ItemEnums"
require "__shared/Enums/ParameterModificationType"
require "__shared/Enums/PingTypes"
require "__shared/Enums/SubphaseTypes"
require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/TeamManagerErrors"
require "__shared/Enums/UiStates"

require "__shared/Libs/Queue"

require "__shared/Mixins/TimersMixin"

require "__shared/Utils/Logger"

require "__shared/Types/Circle"
require "__shared/Types/DataContainer"
require "__shared/Types/MeshModel/MeshModel"
require "__shared/Types/MeshModel/SkeletonMeshModel"
require "__shared/Types/MeshModel/WeaponSkeletonMeshModel"
require "__shared/Types/LootPickupType"

require "__shared/Items/Definitions/BRItemDefinition"
require "__shared/Items/Definitions/BRItemProtectionDefinition"

require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/PostReloadEvent"

require "__shared/Configs/ServerConfig"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/FireEffectsConfig"
require "__shared/Configs/InventoryConfig"

require "__shared/Items/BRItem"

require "__shared/Types/BRLootGridCell"
require "__shared/Types/BRLootGrid"
require "__shared/Types/BRLootPickupDatabaseShared"
require "__shared/Types/BRLootPickup"

require "__shared/Items/BRItemWeapon"
require "__shared/Items/BRItemAmmo"
require "__shared/Items/BRItemArmor"
require "__shared/Items/BRItemHelmet"
require "__shared/Items/BRItemAttachment"
require "__shared/Items/BRItemConsumable"
require "__shared/Items/BRItemGadget"

require "__shared/Logic/PhaseManagerShared"

---@type BundleManager
local m_BundleManager = require "__shared/Logic/BundleManager"
---@type GunSwayManager
local m_GunSwayManager = require "__shared/Logic/GunSwayManager"
---@type MapLoader
local m_MapLoader = require "__shared/Logic/MapLoader"
---@type RegistryManager
local m_RegistryManager = require "__shared/Logic/RegistryManager"
---@type ModificationsCommon
local m_ModificationsCommon = require "__shared/Modifications/ModificationsCommon"
local m_Logger = Logger("VuBattleRoyaleShared", false)

function VuBattleRoyaleShared:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

---VEXT Shared Extension:Loaded Event
function VuBattleRoyaleShared:OnExtensionLoaded()
	Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)

	self:RegisterEvents()
	self:RegisterHooks()
	self:RegisterCallbacks()
	m_ModificationsCommon:OnExtensionLoaded()
end

function VuBattleRoyaleShared:RegisterEvents()
	self.m_Events = {
		Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading),
		Events:Subscribe("Level:RegisterEntityResources", self, self.OnRegisterEntityResources),
		Events:Subscribe("GunSway:Update", self, self.OnGunSwayUpdate),
		Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded),
		Events:Subscribe("Level:LoadingInfo", self, self.OnLevelLoadingInfo),
		Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
	}
end

function VuBattleRoyaleShared:RegisterHooks()
	self.m_Hooks = {
		Hooks:Install("ResourceManager:LoadBundles", 100, self, self.OnLoadBundles),
		Hooks:Install("Terrain:Load", 100, self, self.OnTerrainLoad),
		Hooks:Install("VisualTerrain:Load", 100, self, self.OnTerrainLoad)
	}
end

function VuBattleRoyaleShared:RegisterCallbacks()
	m_ModificationsCommon:RegisterCallbacks()
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function VuBattleRoyaleShared:OnExtensionUnloading()
	m_ModificationsCommon:OnExtensionUnloading()
end

---VEXT Shared Level:LoadResources Event
---@param p_LevelName string
---@param p_GameMode string
---@param p_IsDedicatedServer boolean
function VuBattleRoyaleShared:OnLevelLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	m_ModificationsCommon:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	m_BundleManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)

	if MapsConfig[LevelNameHelper:GetLevelName()] == nil then
		m_Logger:Write("Wrong map. Unsubscribe, uninstall & deregister everything.")
		for _, l_Event in pairs(self.m_Events) do
			l_Event:Unsubscribe()
		end

		for _, l_Hook in pairs(self.m_Hooks) do
			l_Hook:Uninstall()
		end

		self.m_Events = {}
		self.m_Hooks = {}

		m_MapLoader:Reset()
		return
	elseif #self.m_Events == 0 then
		m_Logger:Write("Subscribe, install & register everything again.")
		self:RegisterEvents()
		self:RegisterHooks()
		self:RegisterCallbacks()
	end

	m_RegistryManager:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
	m_MapLoader:OnLoadResources(p_LevelName, p_GameMode, p_IsDedicatedServer)
end

---VEXT Shared Level:RegisterEntityResources Event
---@param p_LevelData DataContainer
function VuBattleRoyaleShared:OnRegisterEntityResources(p_LevelData)
	m_BundleManager:OnRegisterEntityResources(p_LevelData)
	m_ModificationsCommon:OnRegisterEntityResources(p_LevelData)
	m_RegistryManager:OnRegisterEntityResources(p_LevelData)
end

---VEXT Shared GunSway:Update Event
---@param p_GunSway GunSway
---@param p_Weapon Entity|nil
---@param p_WeaponFiring WeaponFiring|nil
---@param p_DeltaTime number
function VuBattleRoyaleShared:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	m_GunSwayManager:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
end

---VEXT Shared Partition:Loaded Event
---@param p_Partition DatabasePartition
function VuBattleRoyaleShared:OnPartitionLoaded(p_Partition)
	m_MapLoader:OnPartitionLoaded(p_Partition)
	m_ModificationsCommon:OnPartitionLoaded(p_Partition)
end

---VEXT Shared Level:LoadingInfo Event
---@param p_ScreenInfo string
function VuBattleRoyaleShared:OnLevelLoadingInfo(p_ScreenInfo)
	m_MapLoader:OnLevelLoadingInfo(p_ScreenInfo)
end

---VEXT Shared Level:Destroy Event
function VuBattleRoyaleShared:OnLevelDestroy()
	m_MapLoader:OnLevelDestroy()
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Shared ResourceManager:LoadBundles Hook
---@param p_HookCtx HookContext
---@param p_Bundles string[]
---@param p_Compartment ResourceCompartment|integer
function VuBattleRoyaleShared:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
	m_BundleManager:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
end

---VEXT Shared VisualTerrain:Load Hook
---VEXT Shared Terrain:Load Hook
---@param p_HookCtx HookContext
---@param p_TerrainAssetName string
function VuBattleRoyaleShared:OnTerrainLoad(p_HookCtx, p_TerrainAssetName)
	m_BundleManager:OnTerrainLoad(p_HookCtx, p_TerrainAssetName)
end

return VuBattleRoyaleShared()
