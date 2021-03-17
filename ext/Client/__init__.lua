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

local m_UICleanup = require "UICleanup"
local m_UIManager = require "UIManager"
local m_Gunship = require "Gunship"
local m_Showroom = require "Showroom"
local m_Hud = require "Hud"
local m_SpectatorCamera = require "SpectatorCamera"
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

    NetEvents:Subscribe(DamageEvent.PlayerDown, self, self.OnDamageConfirmPlayerDown)
    NetEvents:Subscribe(DamageEvent.PlayerKill, self, self.OnDamageConfirmPlayerKill)
    NetEvents:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged)
    NetEvents:Subscribe(PlayerEvents.UpdateTimer, self, self.OnUpdateTimer)
    NetEvents:Subscribe(PlayerEvents.PitchAndYaw, self, self.OnPlayersPitchAndYaw)
    NetEvents:Subscribe(PlayerEvents.MinPlayersToStartChanged, self, self.OnMinPlayersToStartChanged)
    NetEvents:Subscribe(PlayerEvents.WinnerTeamUpdate, self, self.OnWinnerTeamUpdate)
    NetEvents:Subscribe(GunshipEvents.ForceJumpOut, self, self.OnForceJumpOufOfGunship)
    Events:Subscribe("UpdatePass_PreSim", self, self.OnUpdatePassPreSim)
    NetEvents:Subscribe(GunshipEvents.Camera, self, self.OnGunShipCamera)
    NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship)
    NetEvents:Subscribe(GunshipEvents.Position, self, self.OnGunshipPosition)
    NetEvents:Subscribe(GunshipEvents.Yaw, self, self.OnGunshipYaw)
    NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinDenied, self, self.OnTeamJoinDenied)
    NetEvents:Subscribe("ServerPlayer:Killed", self, self.OnPlayerKilled)

    self:RegisterWebUIEvents()
end

function VuBattleRoyaleClient:RegisterWebUIEvents()
    Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy)
    Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy)
    Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock)
    Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam)
end

function VuBattleRoyaleClient:RegisterCallbacks()
    m_UICleanup:RegisterCallbacks()
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
    m_SpectatorCamera:OnLevelDestroy()
    m_Hud:OnLevelDestroy()
    m_SpectatorCamera:OnLevelDestroy()
end

function VuBattleRoyaleClient:OnLevelLoaded()
    m_Showroom:SetCamera(true)
    WebUI:ExecuteJS("ToggleDeployMenu(true);")
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
end

function VuBattleRoyaleClient:OnUpdateTimer(p_Time)
    if p_Time == nil then
        return
    end

    m_Hud:OnUpdateTimer(p_Time)
end

function VuBattleRoyaleClient:OnDamageConfirmPlayerDown(p_VictimName)
    if p_VictimName == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if p_VictimName == s_LocalPlayer.name then
        return
    end

    m_Hud:OnDamageConfirmPlayerKill(p_VictimName, false)
end

function VuBattleRoyaleClient:OnDamageConfirmPlayerKill(p_VictimName)
    if p_VictimName == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if p_VictimName == s_LocalPlayer.name then
        return
    end

    m_Hud:OnDamageConfirmPlayerKill(p_VictimName, true)
end

function VuBattleRoyaleClient:OnPlayerConnected(p_Player)
    if p_Player == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if self.m_GameState == GameStates.None or self.m_GameState == GameStates.Warmup then
        NetEvents:Send("VuBattleRoyale:PlayerConnected")
    elseif p_Player.name == s_LocalPlayer.name then
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

function VuBattleRoyaleClient:OnPlayerKilled(p_Table)
    local s_Player = PlayerManager:GetPlayerById(p_Table[1])
    if s_Player == nil then
        return
    end
    local s_InflictorId = p_Table[2]

    m_Logger:Write("INFO: OnPlayerKilled: " .. s_Player.name)

    m_SpectatorCamera:OnPlayerKilled(s_Player.id, s_InflictorId)

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if self.m_BrPlayer == nil then
        return
    end

    if s_Player == s_LocalPlayer then
        -- If the local player died we should check if anyone else alive in the team if not we should bring up the game over screen
        if s_LocalPlayer.squadId == SquadId.SquadNone then
			m_Hud:OnGameOverScreen(false)
            return
		end

        local s_Players = PlayerManager:GetPlayersBySquad(s_LocalPlayer.teamId, s_LocalPlayer.squadId)

        local s_AliveSquadCount = 0
        for _, l_Player in pairs(s_Players) do
            if l_Player == s_LocalPlayer then
                goto continue_enable
            end

            if l_Player.soldier == nil then
                goto continue_enable
            end

            if l_Player.soldier.alive == false then
                goto continue_enable
            end
            
            s_AliveSquadCount = s_AliveSquadCount + 1
    
            ::continue_enable::
        end

        if s_AliveSquadCount == 0 then
            m_Hud:OnGameOverScreen(false)
            return
        end
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
    m_SpectatorCamera:OnClientUpdateInput()
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


-- =============================================
-- WebUI Events
-- =============================================

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


-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleClient:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    m_Hud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
end

function VuBattleRoyaleClient:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    m_UICleanup:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
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
