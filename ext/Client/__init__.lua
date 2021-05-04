class "VuBattleRoyaleClient"

require "__shared/Configs/ServerConfig"
require "__shared/Utils/Logger"
require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/EventRouter"
require "__shared/Utils/LootPointHelper"
require "__shared/Configs/MapsConfig"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"

require "PhaseManagerClient"
require "BRPlayer"

local m_VanillaUIManager = require "VanillaUIManager"
local m_Gunship = require "Gunship"
local m_Hud = require "Hud"
local m_SpectatorClient = require "SpectatorClient"
local m_Showroom = require "Showroom"
local m_Ping = require "PingClient"
local m_Logger = Logger("VuBattleRoyaleClient", true)


function VuBattleRoyaleClient:__init()
    Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading)

    -- The current gamestate, it's read-only and can only be changed by the SERVER
    self.m_GameState = GameStates.None

    self.m_PhaseManager = PhaseManagerClient()

    self.m_BrPlayer = BRPlayer()
end

function VuBattleRoyaleClient:OnExtensionLoaded()
    self:RegisterEvents()
    self:RegisterCallbacks()
    self:RegisterHooks()

    m_Hud:OnExtensionLoaded()
end

function VuBattleRoyaleClient:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Finalized", self, self.OnLevelFinalized)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
    Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)
    Events:Subscribe("Player:Connected", self, self.OnPlayerConnected)
    Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)
    Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted)
    Events:Subscribe("Client:UpdateInput", self, self.OnClientUpdateInput)
    Events:Subscribe(EventRouterEvents.UIDrawHudCustom, self, self.OnUIDrawHud)
    Events:Subscribe(PhaseManagerEvent.Update, self, self.OnPhaseManagerUpdate)
    Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnOuterCircleMove)
    Events:Subscribe("UpdatePass_PreSim", self, self.OnUpdatePassPreSim)

    NetEvents:Subscribe(DamageEvent.PlayerDown, self, self.OnDamageConfirmPlayerDown)
    NetEvents:Subscribe(DamageEvent.PlayerKill, self, self.OnDamageConfirmPlayerKill)
    NetEvents:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged)
    NetEvents:Subscribe(PlayerEvents.UpdateTimer, self, self.OnUpdateTimer)
    NetEvents:Subscribe(PlayerEvents.MinPlayersToStartChanged, self, self.OnMinPlayersToStartChanged)
    NetEvents:Subscribe(PlayerEvents.WinnerTeamUpdate, self, self.OnWinnerTeamUpdate)
    NetEvents:Subscribe(PlayerEvents.EnableSpectate, self, self.OnEnableSpectate)
    NetEvents:Subscribe(GunshipEvents.ForceJumpOut, self, self.OnForceJumpOufOfGunship)
    NetEvents:Subscribe(GunshipEvents.Camera, self, self.OnGunShipCamera)
    NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship)
    NetEvents:Subscribe(GunshipEvents.Position, self, self.OnGunshipPosition)
    NetEvents:Subscribe(GunshipEvents.Yaw, self, self.OnGunshipYaw)
    NetEvents:Subscribe(GunshipEvents.Remove, self, self.OnGunshipRemove)
    NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinDenied, self, self.OnTeamJoinDenied)
    NetEvents:Subscribe("ServerPlayer:Killed", self, self.OnPlayerKilled)
    NetEvents:Subscribe(SpectatorEvents.PostPitchAndYaw, self, self.OnPostPitchAndYaw)
    NetEvents:Subscribe(PingEvents.ServerPing, self, self.OnPingNotify)
    NetEvents:Subscribe(PingEvents.RemoveServerPing, self, self.OnPingRemoveNotify)
    NetEvents:Subscribe(PingEvents.UpdateConfig, self, self.OnPingUpdateConfig)

    self:RegisterWebUIEvents()
end

function VuBattleRoyaleClient:RegisterWebUIEvents()
    Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy)
    Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy)
    Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock)
    Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam)
    Events:Subscribe("WebUI:PingFromMap", self, self.OnWebUIPingFromMap)
    Events:Subscribe("WebUI:PingRemoveFromMap", self, self.OnWebUIPingRemoveFromMap)
end

function VuBattleRoyaleClient:RegisterCallbacks()
    m_Gunship:RegisterCallbacks()
    m_Showroom:RegisterCallbacks()
end

function VuBattleRoyaleClient:RegisterHooks()
    Hooks:Install("UI:InputConceptEvent", 999, self, self.OnInputConceptEvent)
    Hooks:Install("UI:PushScreen", 999, self, self.OnUIPushScreen)
    Hooks:Install("UI:CreateKillMessage", 999, self, self.OnUICreateKillMessage)
    Hooks:Install("UI:DrawFriendlyNametag", 999, self, self.OnUIDrawFriendlyNametag)
    Hooks:Install("UI:DrawEnemyNametag", 999, self, self.OnUIDrawEnemyNametag)
    Hooks:Install("UI:DrawMoreNametags", 999, self, self.OnUIDrawMoreNametags)
    Hooks:Install("UI:RenderMinimap", 999, self, self.OnUIRenderMinimap)
end


-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleClient:OnLevelDestroy()
    m_Hud:OnLevelDestroy()
    m_SpectatorClient:OnLevelDestroy()
    m_VanillaUIManager:OnLevelDestroy()
end

function VuBattleRoyaleClient:OnLevelLoaded(p_LevelName, p_GameMode)
    WebUI:ExecuteJS("ToggleDeployMenu(true);")
    m_Showroom:SetCamera(true)
    g_Timers:Timeout(2, function() m_VanillaUIManager:EnableShowroomSoldier(true) end)
    m_Ping:OnLevelLoaded(p_LevelName, p_GameMode)
end

function VuBattleRoyaleClient:OnLevelFinalized(p_LevelName, p_GameMode)
    m_Hud:OnLevelFinalized(p_LevelName, p_GameMode)
end

function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)
    m_Hud:OnEngineUpdate(p_DeltaTime)
    m_SpectatorClient:OnEngineUpdate(p_DeltaTime)
    m_Ping:OnEngineUpdate(p_DeltaTime)
end

function VuBattleRoyaleClient:OnUIDrawHud()
    m_Hud:OnUIDrawHud(self.m_BrPlayer)
    m_Ping:OnUIDrawHud()
end

function VuBattleRoyaleClient:OnExtensionUnloading()
    m_SpectatorClient:OnExtensionUnloading()
end

function VuBattleRoyaleClient:OnGameStateChanged(p_OldGameState, p_GameState)
    if p_OldGameState == nil or p_GameState == nil then
        m_Logger:Error("Invalid gamestate from the server")
        return
    end

    if p_OldGameState == p_GameState then
        return
    end

    if self.m_GameState == p_GameState then
        return
    end

    m_Logger:Write("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])

    self.m_GameState = p_GameState

    m_Hud:OnGameStateChanged(p_GameState)
    m_SpectatorClient:OnGameStateChanged(p_GameState)
end

function VuBattleRoyaleClient:OnUpdateTimer(p_Time)
    if p_Time == nil then
        return
    end

    m_Hud:OnUpdateTimer(p_Time)
end

function VuBattleRoyaleClient:OnDamageConfirmPlayerDown(p_VictimName)
    self:OnDamageConfirmPlayerKillOrDown(p_VictimName, false)
end

function VuBattleRoyaleClient:OnDamageConfirmPlayerKill(p_VictimName)
    self:OnDamageConfirmPlayerKillOrDown(p_VictimName, true)
end

function VuBattleRoyaleClient:OnDamageConfirmPlayerKillOrDown(p_VictimName, p_IsKill)    
    if p_VictimName == nil or p_IsKill == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if p_VictimName == s_LocalPlayer.name then
        return
    end

    m_Hud:OnDamageConfirmPlayerKill(p_VictimName, p_IsKill)
end

function VuBattleRoyaleClient:OnPlayerConnected(p_Player)
    if p_Player == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if p_Player == s_LocalPlayer then
        -- Tell the server that the local player is connected
        NetEvents:Send(PlayerEvents.PlayerConnected)
    end
end

function VuBattleRoyaleClient:OnPlayerRespawn(p_Player)
    m_Hud:OnPlayerRespawn(p_Player)
    m_SpectatorClient:OnPlayerRespawn(p_Player)
end

function VuBattleRoyaleClient:OnPlayerDeleted(p_Player)
    m_SpectatorClient:OnPlayerDeleted(p_Player)
end

function VuBattleRoyaleClient:OnPlayerKilled(p_Table)
    local s_Player = PlayerManager:GetPlayerById(p_Table[1])
    if s_Player == nil then
        return
    end

    m_Logger:Write("INFO: OnPlayerKilled: " .. s_Player.name)

    local s_InflictorId = p_Table[2]
    m_SpectatorClient:OnPlayerKilled(s_Player.id, s_InflictorId)

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if self.m_BrPlayer == nil then
        return
    end

    local s_AliveSquadCount = 0
    local s_TeamPlayers = self.m_BrPlayer.m_Team:PlayersTable()
    if s_TeamPlayers ~= nil then
        for _, l_Teammate in ipairs(s_TeamPlayers) do
            if l_Teammate ~= nil then
                if l_Teammate.State ~= BRPlayerState.Dead then
                    s_AliveSquadCount = s_AliveSquadCount + 1
                end
            end
        end
    end

    if s_Player.name == s_LocalPlayer.name and s_AliveSquadCount == 1 then
        -- If the local player dies and the AliveSquadCount is 1 (local player doesnt update that fast)
        s_AliveSquadCount = 0
    end

    if s_AliveSquadCount == 0 then
        m_Hud:OnGameOverScreen(false)
        return
    end
end

function VuBattleRoyaleClient:OnTeamJoinDenied(p_Error)
    if p_Error == nil then
        return
    end

    m_Hud:OnTeamJoinDenied(p_Error)
end

function VuBattleRoyaleClient:OnClientUpdateInput()
    m_Gunship:OnClientUpdateInput()
    m_SpectatorClient:OnClientUpdateInput()
    m_Hud:OnClientUpdateInput()
    m_Ping:OnClientUpdateInput()
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

function VuBattleRoyaleClient:OnUpdatePassPreSim(p_DeltaTime)
    m_Gunship:OnUpdatePassPreSim(p_DeltaTime)
    m_Ping:OnUpdatePassPreSim(p_DeltaTime)
end

function VuBattleRoyaleClient:OnGunShipCamera()
    m_Gunship:OnGunShipCamera()
    m_Hud:OnGunShipCamera()
end

function VuBattleRoyaleClient:OnGunshipPosition(p_Trans)
    m_Hud:OnGunshipPosition(p_Trans)
end

function VuBattleRoyaleClient:OnGunshipYaw(p_Trans)
    m_Hud:OnGunshipYaw(p_Trans)
end

function VuBattleRoyaleClient:OnGunshipRemove()
    m_Hud:OnGunshipRemove()
end

function VuBattleRoyaleClient:OnJumpOutOfGunship()
    m_Hud:OnJumpOutOfGunship()
end

function VuBattleRoyaleClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
    m_SpectatorClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
end

function VuBattleRoyaleClient:OnMinPlayersToStartChanged(p_MinPlayersToStart)
    m_Hud.m_MinPlayersToStart = p_MinPlayersToStart
end

function VuBattleRoyaleClient:OnWinnerTeamUpdate(p_WinnerTeamId)
    if p_WinnerTeamId == nil then
        return
    end

    if self.m_BrPlayer == nil then
        return
    end

    if self.m_BrPlayer.m_Team == nil then
        return
    end

    if p_WinnerTeamId ~= self.m_BrPlayer.m_Team.m_Id then
        return
    end

    m_Hud:OnGameOverScreen(true)
end

function VuBattleRoyaleClient:OnEnableSpectate()
    m_SpectatorClient:Enable()
    m_Hud:OnJumpOutOfGunship()
end

function VuBattleRoyaleClient:OnPingNotify(p_PingId, p_Position)
    m_Ping:OnPingNotify(p_PingId, p_Position)
end

function VuBattleRoyaleClient:OnPingRemoveNotify(p_PingId)
    m_Ping:OnPingRemoveNotify(p_PingId)
end

function VuBattleRoyaleClient:OnPingUpdateConfig(p_CooldownTime)
    m_Ping:OnPingUpdateConfig(p_CooldownTime)
end

-- =============================================
-- WebUI Events
-- =============================================

function VuBattleRoyaleClient:OnWebUIDeploy()
    m_Showroom:SetCamera(false)
    m_VanillaUIManager:EnableShowroomSoldier(false)
    NetEvents:Send(PlayerEvents.PlayerDeploy)
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

function VuBattleRoyaleClient:OnWebUIPingFromMap(p_Table)
    m_Ping:OnWebUIPingFromMap(p_Table)
end

function VuBattleRoyaleClient:OnWebUIPingRemoveFromMap()
    m_Ping:OnWebUIPingRemoveFromMap()
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleClient:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    m_Hud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
end

function VuBattleRoyaleClient:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    m_Hud:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    m_VanillaUIManager:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
end

function VuBattleRoyaleClient:OnUICreateKillMessage(p_Hook)
    p_Hook:Return(nil)
end

function VuBattleRoyaleClient:OnUIDrawFriendlyNametag(p_Hook)
    if not ServerConfig.Debug.ShowAllNametags then
        p_Hook:Return(nil)
    end
end


function VuBattleRoyaleClient:OnUIDrawEnemyNametag(p_Hook)
    if not ServerConfig.Debug.ShowAllNametags then
        p_Hook:Return(nil)
    end
end

function VuBattleRoyaleClient:OnUIDrawMoreNametags(p_Hook)
    if not ServerConfig.Debug.ShowAllNametags then
        --p_Hook:Return(nil)
    end
end

function VuBattleRoyaleClient:OnUIRenderMinimap(p_Hook)
    p_Hook:Return(nil)
end

return VuBattleRoyaleClient()
