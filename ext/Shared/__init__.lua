class "VuBattleRoyaleShared"

require "__shared/Utils/LevelNameHelper"
require "__shared/Configs/MapsConfig"

local m_ModificationCommon = require "__shared/Modifications/ModificationsCommon"
--local m_PhaseManagerShared = require "__shared/Logic/PhaseManagerShared"

function VuBattleRoyaleShared:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading)
end

function VuBattleRoyaleShared:OnExtensionLoaded()
    self:RegisterEvents()
    self:RegisterHooks()
end

function VuBattleRoyaleShared:RegisterEvents()
    Events:Subscribe('Level:LoadResources', self, self.OnLoadResources)
    Events:Subscribe('Partition:Loaded', self, self.OnPartitionLoaded)
    Events:Subscribe('Level:RegisterEntityResources', self, self.OnRegisterEntityResources)
    Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
end

function VuBattleRoyaleShared:RegisterHooks()

end

function VuBattleRoyaleShared:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
    m_ModificationCommon:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
end

function VuBattleRoyaleShared:OnPartitionLoaded(p_Partition)
    m_ModificationCommon:OnPartitionLoaded(p_Partition)
end

function VuBattleRoyaleShared:OnRegisterEntityResources(p_LevelData)
    m_ModificationCommon:OnRegisterEntityResources(p_LevelData)
end

function VuBattleRoyaleShared:OnLevelDestroy()
    print("[VuBattleRoyaleShared] OnLevelDestroy?")
    --PhaseManagerShared:Destroy()
end

function VuBattleRoyaleShared:OnExtensionUnloading()
    --m_ModificationCommon:OnExtensionUnloading()
    PhaseManagerShared:Destroy()
end


return VuBattleRoyaleShared()
