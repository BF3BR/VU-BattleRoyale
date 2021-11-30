class "VuBattleRoyaleShared"

require "__shared/Enums/ArmorTypes"
require "__shared/Enums/BRPlayerState"
require "__shared/Enums/CustomEvents"
require "__shared/Enums/GameStates"
require "__shared/Enums/PingTypes"
require "__shared/Enums/SubphaseTypes"
require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/TeamManagerErrors"
require "__shared/Enums/UiStates"
require "__shared/Enums/Attachments"

require "__shared/Libs/Queue"

require "__shared/Mixins/TimersMixin"

require "__shared/Types/Circle"
require "__shared/Types/DataContainer"
require "__shared/Types/MeshModel/MeshModel"
require "__shared/Types/MeshModel/SkeletonMeshModel"
require "__shared/Types/MeshModel/WeaponSkeletonMeshModel"

require "__shared/Utils/Logger"
require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/Timers"
require "__shared/Utils/PostReloadEvent"

require "__shared/Configs/ServerConfig"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/FireEffectsConfig"
require "__shared/Configs/InventoryConfig"

require "__shared/Items/BRItem"

require "__shared/Types/BRLootPickup"

require "__shared/Logic/PhaseManagerShared"

local m_BundleManager = require "__shared/Logic/BundleManager"
local m_GunSwayManager = require "__shared/Logic/GunSwayManager"
local m_MapLoader = require "__shared/Logic/MapLoader"
local m_RegistryManager = require "__shared/Logic/RegistryManager"
local m_ModificationsCommon = require "__shared/Modifications/ModificationsCommon"
local m_Logger = Logger("VuBattleRoyaleShared", true)

function VuBattleRoyaleShared:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

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

function VuBattleRoyaleShared:OnExtensionUnloading()
	m_ModificationsCommon:OnExtensionUnloading()
end

function VuBattleRoyaleShared:OnLevelLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_ModificationsCommon:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_BundleManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)

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

		return
	elseif #self.m_Events == 0 then
		m_Logger:Write("Subscribe, install & register everything again.")
		self:RegisterEvents()
		self:RegisterHooks()
		self:RegisterCallbacks()
	end

	m_RegistryManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_MapLoader:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
end

function VuBattleRoyaleShared:OnRegisterEntityResources(p_LevelData)
	m_BundleManager:OnRegisterEntityResources(p_LevelData)
	m_ModificationsCommon:OnRegisterEntityResources(p_LevelData)
	m_RegistryManager:OnRegisterEntityResources(p_LevelData)
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
