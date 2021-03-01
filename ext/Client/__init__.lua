class "VuBattleRoyaleClient"

require "__shared/Helpers/LevelNameHelper"
require "__shared/Configs/MapsConfig"
require "__shared/Enums/GameStates"
require "__shared/Enums/PhaseManagerEvents"
require "__shared/Enums/TeamManagerEvents"
require "__shared/Utils/EventRouter"
--require "Helpers/LootPointHelper"
require "PhaseManagerClient"
require "ClientCommands"
require "PingClient"
require "BRPlayer"

local m_UICleanup = require "UICleanup"
local m_Gunship = require "Gunship"
local m_Hud = require "Hud"
local m_SpectatorCamera = require "SpectatorCamera"
local m_Showroom = require "Showroom"

function VuBattleRoyaleClient:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    -- The current gamestate, it's read-only and can only be changed by the SERVER
    self.m_GameState = GameStates.None

    self.m_PhaseManager = PhaseManagerClient()

    -- The client pinging system
    self.m_Ping = PingClient()

    self.m_BrPlayer = BRPlayer()

    m_Hud:SetShowroom(m_Showroom)
end

-- ==========
-- Extensions
-- ==========

function VuBattleRoyaleClient:OnExtensionLoaded()
    -- Register all of the console variable commands
    self:RegisterCommands()

    -- Register all of the events
    self:RegisterEvents()

    -- Register all of the hooks
    self:RegisterHooks()

    m_Hud:OnExtensionLoaded()
end

function VuBattleRoyaleClient:OnExtensionUnloaded()
    self:UnregisterCommands()
    self:UnregisterEvents()
    self:UnregisterHooks()
end

-- ==========
-- Console Commands
-- ==========

function VuBattleRoyaleClient:RegisterCommands()
    self.m_PosCommand = Console:Register("vubr_pos", "Get the current position for the player",
                                         ClientCommands.PlayerPosition)
end

function VuBattleRoyaleClient:UnregisterCommands()
    Console:Deregister("vubr_pos")
end

-- ==========
-- Events & Hooks
-- ==========

function VuBattleRoyaleClient:RegisterEvents()
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    self.m_LevelFinalizedEvent = Events:Subscribe("Level:Finalized", self, self.OnLevelFinalized)
    self.m_LevelDestroyEvent = Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    -- Player Events
    self.m_PlayerConnectedEvent = Events:Subscribe("Player:Connected", self, self.OnPlayerConnected)
    self.m_PlayerRespawnEvent = Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)
    self.m_PlayerDeletedEvent = Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted)
    self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)

    self.m_ClientUpdateInputEvent = Events:Subscribe("Client:UpdateInput", self, self.OnClientUpdateInput)

    -- UI Events
    self.m_UIDrawHudEvent = Events:Subscribe(EventRouterEvents.UIDrawHudCustom, self, self.OnUIDrawHud)

    self.m_ExtensionUnloadingEvent = Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading)

    -- ==========
    -- Custom events
    -- ==========
    self.m_PhaseManagerUpdateEvent = Events:Subscribe(PhaseManagerCustomEvents.Update, self, self.OnPhaseManagerUpdate)
    self.m_PhaseManagerUpdateEvent = Events:Subscribe(PhaseManagerCustomEvents.CircleMove, self, self.OnOuterCircleMove)

    self.m_GameStateChangedEvent = NetEvents:Subscribe("VuBattleRoyale:GameStateChanged", self, self.OnGameStateChanged)
    self.m_OnUpdateTimerEvent = NetEvents:Subscribe("VuBattleRoyale:UpdateTimer", self, self.OnUpdateTimer)
    self.m_NotifyInflictorAboutAKillEvent = NetEvents:Subscribe("VuBattleRoyale:NotifyInflictorAboutAKill", self, self.OnNotifyInflictorAboutAKill)

    -- TODO: We might not even need this beacuse of the round restarts
    self.m_CleanupEntitiesEvent = NetEvents:Subscribe("VuBattleRoyale:Cleanup", self, self.OnCleanupEntities)

    self.m_GunshipCameraNetEvent = NetEvents:Subscribe("ForceJumpOufOfGunship", self, self.OnForceJumpOufOfGunship)
    self.m_GunshipCameraNetEvent = NetEvents:Subscribe("GunshipCamera", self, self.OnGunShipCamera)
    self.m_JumpOutOfGunshipNetEvent = NetEvents:Subscribe("JumpOutOfGunship", self, self.OnJumpOutOfGunship)
    self.m_GunshipPositionNetEvent = NetEvents:Subscribe("GunshipPosition", self, self.OnGunshipPosition)
    self.m_GunshipYawNetEvent = NetEvents:Subscribe("GunshipYaw", self, self.OnGunshipYaw)
    self.m_PlayersPitchAndYawEvent = NetEvents:Subscribe("VuBattleRoyale:PlayersPitchAndYaw", self, self.OnPlayersPitchAndYaw)

    self.m_TeamJoinDeniedEvent = NetEvents:Subscribe(TeamManagerNetEvents.TeamJoinDenied, self, self.OnTeamJoinDenied)

    -- ==========
    -- WebUI events
    -- ==========
    self.m_WebUIDeploy = Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy)
    self.m_WebUISetTeamJoinStrategy = Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy)
    self.m_WebUIToggleLock = Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock)
    self.m_WebUIJoinTeam = Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam)
end

function VuBattleRoyaleClient:RegisterHooks()
    self.m_InputConceptEventHook = Hooks:Install("UI:InputConceptEvent", 999, self, self.OnInputConceptEvent)

    self.m_UIPushScreenHook = Hooks:Install("UI:PushScreen", 999, self, self.OnUIPushScreen)
    self.m_UICreateKillMessage = Hooks:Install('UI:CreateKillMessage', 999, self, self.OnUICreateKillMessage)
    self.m_UIDrawFriendlyNametag = Hooks:Install("UI:DrawFriendlyNametag", 999, self, self.OnUIDrawFriendlyNametag)
    self.m_UIDrawEnemyNametag = Hooks:Install("UI:DrawEnemyNametag", 999, self, self.OnUIDrawEnemyNametag)
    self.m_UIDrawMoreNametags = Hooks:Install('UI:DrawMoreNametags', 999, self, self.OnUIDrawMoreNametags)
    -- self.m_UIEnableCursorMode =  Hooks:Install("UI:EnableCursorMode", 1, self, self.OnUIEnableCursorMode)
end

function VuBattleRoyaleClient:UnregisterEvents()
    
end

function VuBattleRoyaleClient:OnLevelDestroy()
    m_SpectatorCamera:OnLevelDestroy()
    m_Hud:OnLevelDestroy()
    m_SpectatorCamera:OnLevelDestroy()
end

function VuBattleRoyaleClient:OnLevelLoaded()
    m_Showroom:SetCamera(true)
    WebUI:ExecuteJS("ToggleDeployMenu();")
end

function VuBattleRoyaleClient:OnLevelFinalized(p_LevelName, p_GameMode)
    m_Hud:OnLevelFinalized(p_LevelName, p_GameMode)
end


function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)
    m_Hud:OnEngineUpdate(p_DeltaTime)
    m_SpectatorCamera:OnEngineUpdate(p_DeltaTime)
end

function VuBattleRoyaleClient:OnUIDrawHud()
    m_Hud:OnUIDrawHud(self.m_BrPlayer)
end

function VuBattleRoyaleClient:OnExtensionUnloading()
    m_SpectatorCamera:OnExtensionUnloading()
end

function VuBattleRoyaleClient:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    m_Hud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
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

    if self.m_GameState == p_GameState then
        return
    end

    print("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])

    self.m_GameState = p_GameState

    m_Hud:OnGameStateChanged(p_GameState)
    m_SpectatorCamera:OnGameStateChanged(p_GameState)
end

function VuBattleRoyaleClient:OnUpdateTimer(p_Time)
    if p_Time == nil then
        return
    end

    print("INFO: Set timer to: " .. p_Time)

    m_Hud:OnUpdateTimer(p_Time)
end

function VuBattleRoyaleClient:OnNotifyInflictorAboutAKill(p_PlayerName)
    if p_PlayerName == nil then
        return
    end

    m_Hud:OnNotifyInflictorAboutKillOrKnock(p_PlayerName, true)
end

function VuBattleRoyaleClient:OnCleanupEntities(p_EntityType)
    if p_EntityType == nil then
        return
    end

    local s_Entities = {}

    local s_Iterator = EntityManager:GetIterator(p_EntityType)
    local s_Entity = s_Iterator:Next()
    while s_Entity do
        s_Entities[#s_Entities + 1] = Entity(s_Entity)
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

    if self.m_GameState == GameStates.None or self.m_GameState == GameStates.Warmup then
        NetEvents:Send("VuBattleRoyale:PlayerConnected")
    else
        m_SpectatorCamera:Enable()
    end
end

function VuBattleRoyaleClient:OnPlayerRespawn(p_Player)
    m_Hud:OnPlayerRespawn(p_Player)
    m_SpectatorCamera:OnPlayerRespawn(p_Player)
end

function VuBattleRoyaleClient:OnPlayerDeleted(p_Player)
    m_SpectatorCamera:OnPlayerDeleted(p_Player)
end

function VuBattleRoyaleClient:OnPlayerKilled(p_Player)
    if p_Player == nil then
        return
    end

    print("INFO: OnPlayerKilled: " .. p_Player.name)

    m_SpectatorCamera:OnPlayerKilled(p_Player, self.m_GameState)
end

function VuBattleRoyaleClient:OnTeamJoinDenied(p_Error)
    if p_Error == nil then
        return
    end

    m_Hud:OnTeamJoinDenied(p_Error)
end

function VuBattleRoyaleClient:OnWebUIDeploy()
    m_Showroom:SetCamera(false)
    NetEvents:Send("VuBattleRoyale:PlayerDeploy")
end

function VuBattleRoyaleClient:OnWebUISetTeamJoinStrategy(p_Strategy)
    if self.m_BrPlayer == nil then
        return
    end

    self.m_BrPlayer:SetTeamJoinStrategy(p_Strategy)
end

function VuBattleRoyaleClient:OnWebUIToggleLock()
    if self.m_BrPlayer == nil then
        return
    end

    self.m_BrPlayer:ToggleLock()
end


function VuBattleRoyaleClient:OnWebUIJoinTeam(p_Id)
    if self.m_BrPlayer == nil or p_Id == nil or p_Id == "" then
        return
    end
    
    self.m_BrPlayer:JoinTeam(p_Id)
end

function VuBattleRoyaleClient:OnClientUpdateInput()
    m_Gunship:OnClientUpdateInput()
    m_SpectatorCamera:OnClientUpdateInput()
    m_Hud:OnClientUpdateInput()
end

function VuBattleRoyaleClient:OnPhaseManagerUpdate(p_Data)
    m_Hud:OnPhaseManagerUpdate(p_Data)
end

function VuBattleRoyaleClient:OnOuterCircleMove(p_OuterCircle)
    m_Hud:OnOuterCircleMove(p_OuterCircle)
end

function VuBattleRoyaleClient:OnForceJumpOufOfGunship()
    m_Gunship:OnForceJumpOufOfGunship()
end

function VuBattleRoyaleClient:OnGunShipCamera()
    m_Gunship:OnGunShipCamera()
    m_Hud:OnGunShipCamera()
end

function VuBattleRoyaleClient:OnGunshipPosition(p_Trans)
    if p_Trans == nil then
        return
    end

    m_Hud:OnGunshipPosition(p_Trans)
end

function VuBattleRoyaleClient:OnGunshipYaw(p_Trans)
    if p_Trans == nil then
        return
    end

    m_Hud:OnGunshipYaw(p_Trans)
end

function VuBattleRoyaleClient:OnJumpOutOfGunship()
    m_Hud:OnJumpOutOfGunship()
end

function VuBattleRoyaleClient:OnPlayersPitchAndYaw(p_PitchAndYaw)
    m_SpectatorCamera:OnPlayersPitchAndYaw(p_PitchAndYaw)
end

function VuBattleRoyaleClient:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    m_UICleanup:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
end

function VuBattleRoyaleClient:OnUIDrawFriendlyNametag(p_Hook)
    p_Hook:Return(nil)
end

function VuBattleRoyaleClient:OnUICreateKillMessage(p_Hook)
    p_Hook:Return(nil)
end

function VuBattleRoyaleClient:OnUIDrawEnemyNametag(p_Hook)
    p_Hook:Return(nil)
end

function VuBattleRoyaleClient:OnUIDrawMoreNametags(p_Hook)
    p_Hook:Return(nil)
end

function VuBattleRoyaleClient:OnUIEnableCursorMode(p_Hook, p_Enable, p_Cursor)
    m_UICleanup:OnUIEnableCursorMode(p_Hook, p_Enable, p_Cursor)
end

return VuBattleRoyaleClient()
