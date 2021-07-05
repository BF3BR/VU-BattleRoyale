class "VuBattleRoyaleShared"

require "__shared/Enums/AttachmentTypes"

require "__shared/Utils/Logger"
require "__shared/Utils/EventRouter"
require "__shared/Utils/LevelNameHelper"

require "__shared/Types/DataContainer"

require "__shared/Weapons/Attachments"
require "__shared/Weapons/Weapons"
require "__shared/Weapons/Gadgets"

require "__shared/Configs/ServerConfig"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/PickupsConfig"


local m_ModificationsCommon = require "__shared/Modifications/ModificationsCommon"
local m_BundleManager = require "__shared/Logic/BundleManager"
local m_GunSwayManager = require "__shared/Logic/GunSwayManager"
local m_RegistryManager = require "__shared/Logic/RegistryManager"
local m_MapLoader = require "__shared/Logic/MapLoader"

function VuBattleRoyaleShared:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

function VuBattleRoyaleShared:OnExtensionLoaded()
	self:RegisterEvents()
	self:RegisterHooks()
	self:RegisterCallbacks()
end

function VuBattleRoyaleShared:RegisterEvents()
	Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)
	Events:Subscribe("Level:RegisterEntityResources", self, self.OnRegisterEntityResources)
	Events:Subscribe("GunSway:Update", self, self.OnGunSwayUpdate)
	Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
	Events:Subscribe('Level:LoadingInfo', self, self.OnLevelLoadingInfo)
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
end

function VuBattleRoyaleShared:RegisterHooks()
	Hooks:Install("ResourceManager:LoadBundles", 100, self, self.OnLoadBundles)
	Hooks:Install("Terrain:Load", 100, self, self.OnTerrainLoad)
	Hooks:Install("VisualTerrain:Load", 100, self, self.OnTerrainLoad)
end

function VuBattleRoyaleShared:RegisterCallbacks()
	m_ModificationsCommon:RegisterCallbacks()
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleShared:OnLevelLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_BundleManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_RegistryManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_ModificationsCommon:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_MapLoader:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
end

function VuBattleRoyaleShared:OnRegisterEntityResources(p_LevelData)
	m_BundleManager:OnRegisterEntityResources(p_LevelData)
	m_ModificationsCommon:OnRegisterEntityResources(p_LevelData)
end

function VuBattleRoyaleShared:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	m_GunSwayManager:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
end

function VuBattleRoyaleShared:OnPartitionLoaded(p_Partition)
	m_MapLoader:OnPartitionLoaded(p_Partition)
end

function VuBattleRoyaleShared:OnLevelLoadingInfo(p_ScreenInfo)
	m_MapLoader:OnLevelLoadingInfo(p_ScreenInfo)
end

function VuBattleRoyaleShared:OnLevelDestroy()
	m_MapLoader:OnLevelDestroy()
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleShared:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
	m_BundleManager:OnLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
end

function VuBattleRoyaleShared:OnTerrainLoad(p_Hook, p_TerrainName)
	m_BundleManager:OnTerrainLoad(p_Hook, p_TerrainName)
end

return VuBattleRoyaleShared()
