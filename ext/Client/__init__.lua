class "VuBattleRoyaleClient"

require ("__shared/Utils/LevelNameHelper")

require ("__shared/Configs/MapsConfig")

require ("__shared/Helpers/GameStates")

require ("UICleanup")
require ("ClientCommands")
require ("Gunship")
require ("Helpers/LootPointHelper")

function VuBattleRoyaleClient:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    -- The current gamestate, it's read-only and can only be changed by the SERVER
    self.m_GameState = GameStates.None
end

-- ==========
-- Extensions
-- ==========

function VuBattleRoyaleClient:OnExtensionLoaded()
    -- Register all of the console variable commands
    self:RegisterCommands()

    -- Register all of the events
    self:RegisterEvents()

    -- Initialize the WebUI
    -- WebUI:Init()

    -- Show the WebUI
    -- WebUI:Show()
end

function VuBattleRoyaleClient:OnExtensionUnloaded()
    self:UnregisterCommands()
    self:UnregisterEvents()
end


-- ==========
-- Console Commands
-- ==========

function VuBattleRoyaleClient:RegisterCommands()
    self.m_PosCommand = Console:Register("vubr_pos", "Get the current position for the player", ClientCommands.PlayerPosition)
end

function VuBattleRoyaleClient:UnregisterCommands()
    Console:Deregister("vubr_pos")
end


-- ==========
-- Events
-- ==========

function VuBattleRoyaleClient:RegisterEvents()
    self.m_LevelLoadedEvent = Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
    self.m_LevelDestroyEvent = Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
    self.m_EngineUpdateEvent = Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)

    -- Game State events
    self.m_GameStateChangedEvent = NetEvents:Subscribe("VuBattleRoyale:GameStateChanged", self, self.OnGameStateChanged)

    -- Cleanup Events
    self.m_CleanupEntitiesEvent = NetEvents:Subscribe("VuBattleRoyale:Cleanup", self, self.OnCleanupEntities)

    -- Player Events
    self.m_PlayerConnectedEvent = Events:Subscribe('Player:Connected', self, self.OnPlayerConnected)
end

function VuBattleRoyaleClient:UnregisterEvents()

end

function VuBattleRoyaleClient:OnLevelDestroy()

end

function VuBattleRoyaleClient:OnLevelLoaded()

end

function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)

end

function VuBattleRoyaleClient:OnGameStateChanged(p_OldGameState, p_GameState)
    -- Validate our gamestates
    if p_OldGameState == nil or p_GameState == nil then
        print("ERROR: Invalid gamestate from the server")
        return
    end

    if p_OldGameState == p_GameState then
        return
    end

    print("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])
    
    self.m_GameState = p_GameState

    -- Update the WebUI
    -- TODO: WebUI:ExecuteJS("ChangeState(" .. self.m_GameState .. ");")
end

function VuBattleRoyaleClient:OnCleanupEntities(p_EntityType)
    if p_EntityType == nil then
        return
    end

    local s_Entities = {}

    local s_Iterator = EntityManager:GetIterator(p_EntityType)
    local s_Entity = s_Iterator:Next()
    while s_Entity do
        s_Entities[#s_Entities+1] = Entity(s_Entity)
        s_Entity = s_Iterator:Next()
    end

    for _, l_Entity in pairs(s_Entities) do
        if l_Entity ~= nil then
            l_Entity:Destroy()
        end
    end
end

function VuBattleRoyaleClient:OnPlayerConnected(p_Player)
    if p_Player == nil then
        return
    end

    NetEvents:Send("VuBattleRoyale:PlayerConnected")
end

return VuBattleRoyaleClient()
