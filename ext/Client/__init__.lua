class "VuBattleRoyaleClient"

require ("__shared/Utils/LevelNameHelper")
require ("__shared/Configs/MapsConfig")

function VuBattleRoyaleClient:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)
end

-- ==========
-- Extensions
-- ==========

function VuBattleRoyaleClient:OnExtensionLoaded()
    -- Register all of the events
    self:RegisterEvents()

    -- Initialize the WebUI
    -- WebUI:Init()

    -- Show the WebUI
    -- WebUI:Show()
end

function VuBattleRoyaleClient:OnExtensionUnloaded()
    self:UnregisterEvents()
end

-- ==========
-- Events
-- ==========

function VuBattleRoyaleClient:RegisterEvents()
    self.m_LevelLoadedEvent = Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
    self.m_LevelDestroyEvent = Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
    self.m_EngineUpdateEvent = Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
end

function VuBattleRoyaleClient:UnregisterEvents()

end

function VuBattleRoyaleClient:OnLevelDestroy()

end

function VuBattleRoyaleClient:OnLevelLoaded()

end

function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)

end

return VuBattleRoyaleClient()
