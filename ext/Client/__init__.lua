class "VuBattleRoyaleClient"

require "__shared/Configs/ServerConfig"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/SettingsConfig"
require "__shared/Utils/Logger"
require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/EventRouter"
require "__shared/Utils/LootPointHelper"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"

require "PhaseManagerClient"
require "BRPlayer"
require "Visuals/OOCFires"

local m_HudUtils = require "Utils/HudUtils"
local m_VanillaUIManager = require "VanillaUIManager"
local m_Gunship = require "Gunship"
local m_Hud = require "Hud"
local m_Chat = require "UI/Chat"
local m_SpectatorClient = require "SpectatorClient"
local m_Ping = require "PingClient"
local m_ClientManDownLoot = require "ClientManDownLoot"
local m_AntiCheat = require "AntiCheat"
local m_SoundCommon = require "Sound/SoundCommon"

local m_Logger = Logger("VuBattleRoyaleClient", true)

function VuBattleRoyaleClient:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

function VuBattleRoyaleClient:OnExtensionLoaded()
	self.m_IsHotReload = self:GetIsHotReload()
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterWebUIEvents()
	self:RegisterCallbacks()
	self:RegisterHooks()

	m_Hud:OnExtensionLoaded()
	self:OnHotReload()
end

function VuBattleRoyaleClient:RegisterVars()
	-- The current gamestate, it's read-only and can only be changed by the SERVER
	self.m_GameState = GameStates.None
	self.m_PhaseManager = PhaseManagerClient()
	self.m_BrPlayer = BRPlayer()
	self.m_UserSettings = {}
end

function VuBattleRoyaleClient:RegisterEvents()
	Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading)
	Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)

	Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
	Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)

	Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)
	Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)
	Events:Subscribe("Client:UpdateInput", self, self.OnClientUpdateInput)

	Events:Subscribe("Player:Connected", self, self.OnPlayerConnected)
	Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn)
	Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted)
	Events:Subscribe("Player:TeamChange", self, self.OnPlayerTeamChange)

	Events:Subscribe('Soldier:HealthAction', self, self.OnSoldierHealthAction)

	Events:Subscribe('GunSway:Update', self, self.OnGunSwayUpdate)

	NetEvents:Subscribe("ServerPlayer:Killed", self, self.OnPlayerKilled)
	NetEvents:Subscribe(DamageEvent.PlayerDown, self, self.OnDamageConfirmPlayerDown)
	NetEvents:Subscribe(DamageEvent.PlayerKill, self, self.OnDamageConfirmPlayerKill)

	NetEvents:Subscribe(PingEvents.ServerPing, self, self.OnPingNotify)
	NetEvents:Subscribe(PingEvents.RemoveServerPing, self, self.OnPingRemoveNotify)
	NetEvents:Subscribe(PingEvents.UpdateConfig, self, self.OnPingUpdateConfig)

	NetEvents:Subscribe(GunshipEvents.Enable, self, self.OnGunshipEnable)
	NetEvents:Subscribe(GunshipEvents.Disable, self, self.OnGunshipDisable)
	NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship)
	NetEvents:Subscribe(GunshipEvents.ForceJumpOut, self, self.OnForceJumpOufOfGunship)

	Events:Subscribe(PhaseManagerEvent.Update, self, self.OnPhaseManagerUpdate)
	Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnOuterCircleMove)

	NetEvents:Subscribe(ManDownLootEvents.UpdateLootPosition, self, self.OnUpdateLootPosition)
	NetEvents:Subscribe(ManDownLootEvents.OnInteractionFinished, self, self.OnLootInteractionFinished)

	NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinDenied, self, self.OnTeamJoinDenied)
	NetEvents:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged)
	NetEvents:Subscribe(PlayerEvents.UpdateTimer, self, self.OnUpdateTimer)
	NetEvents:Subscribe(PlayerEvents.MinPlayersToStartChanged, self, self.OnMinPlayersToStartChanged)
	NetEvents:Subscribe(PlayerEvents.WinnerTeamUpdate, self, self.OnWinnerTeamUpdate)
	NetEvents:Subscribe(PlayerEvents.EnableSpectate, self, self.OnEnableSpectate)
	NetEvents:Subscribe(SpectatorEvents.PostPitchAndYaw, self, self.OnPostPitchAndYaw)
	NetEvents:Subscribe("UpdateSpectatorCount", self, self.OnUpdateSpectatorCount)
end

function VuBattleRoyaleClient:RegisterWebUIEvents()
	Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy)
	Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy)
	Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock)
	Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam)
	Events:Subscribe("WebUI:PingFromMap", self, self.OnWebUIPingFromMap)
	Events:Subscribe("WebUI:PingRemoveFromMap", self, self.OnWebUIPingRemoveFromMap)
	Events:Subscribe("WebUI:TriggerMenuFunction", self, self.OnWebUITriggerMenuFunction)
	Events:Subscribe('WebUI:OutgoingChatMessage', self, self.OnWebUIOutgoingChatMessage)
	Events:Subscribe('WebUI:SetCursor', self, self.OnWebUISetCursor)
end

function VuBattleRoyaleClient:RegisterCallbacks()
	m_Gunship:RegisterCallbacks()
end

function VuBattleRoyaleClient:RegisterHooks()
	Hooks:Install("UI:InputConceptEvent", 999, self, self.OnInputConceptEvent)
	Hooks:Install("UI:PushScreen", 999, self, self.OnUIPushScreen)
	Hooks:Install('UI:CreateChatMessage',999, self, self.OnUICreateChatMessage)
	Hooks:Install("UI:CreateKillMessage", 999, self, self.OnUICreateKillMessage)
	Hooks:Install("UI:DrawFriendlyNametag", 999, self, self.OnUIDrawFriendlyNametag)
	Hooks:Install("UI:DrawEnemyNametag", 999, self, self.OnUIDrawEnemyNametag)
	Hooks:Install("UI:DrawMoreNametags", 999, self, self.OnUIDrawMoreNametags)
	Hooks:Install("UI:RenderMinimap", 999, self, self.OnUIRenderMinimap)
	Hooks:Install("Input:PreUpdate", 999, self, self.OnInputPreUpdate)
	Hooks:Install('ClientChatManager:IncomingMessage', 1, self, self.OnClientChatManagerIncomingMessage)
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleClient:OnExtensionUnloading()
	self:ResetSettings()
	m_SpectatorClient:OnExtensionUnloading()
	m_Hud:OnExtensionUnloading()
	m_HudUtils:OnExtensionUnloading()
	m_Chat:OnExtensionUnloading()
end

function VuBattleRoyaleClient:OnPartitionLoaded(p_Partition)
	if p_Partition == nil then
		m_Logger:Error("Partition is nil")
		return
	end

	local s_Instances = p_Partition.instances

	for _, s_Instance in pairs(s_Instances) do
		if s_Instance ~= nil then
			m_SoundCommon:OnInstanceLoaded(p_Partition, s_Instance)
		end
	end
end

function VuBattleRoyaleClient:ApplySettings()
	for l_SettingsName, l_Settings in pairs(SettingsConfig) do
		local l_TempSettings = ResourceManager:GetSettings(l_SettingsName)
		l_TempSettings = _G[l_SettingsName](l_TempSettings)
		for l_SettingName, l_Setting in pairs(l_Settings) do
			if self.m_UserSettings[l_SettingsName] == nil then
				self.m_UserSettings[l_SettingsName] = {}
			end
			self.m_UserSettings[l_SettingsName][l_SettingName] = l_TempSettings[l_SettingName]
			l_TempSettings[l_SettingName] = l_Setting
		end
	end
end

function VuBattleRoyaleClient:ResetSettings()
	for l_SettingsName, l_Settings in pairs(self.m_UserSettings) do
		local l_TempSettings = ResourceManager:GetSettings(l_SettingsName)
		l_TempSettings = _G[l_SettingsName](l_TempSettings)
		for l_SettingName, l_Setting in pairs(l_Settings) do
			l_TempSettings[l_SettingName] = l_Setting
		end
	end

	self.m_UserSettings = {}
end

-- =============================================
	-- Level Events
-- =============================================

function VuBattleRoyaleClient:OnLevelLoaded(p_LevelName, p_GameMode)
	self:ApplySettings()
	WebUI:ExecuteJS("ToggleDeployMenu(true);")
	m_HudUtils:ShowroomCamera(true)
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:SetIsInDeployScreen(true)
	g_Timers:Timeout(2, function() m_VanillaUIManager:EnableShowroomSoldier(true) end)
	g_Timers:Timeout(5, function() m_Hud:OnLevelFinalized() end)
	m_Ping:OnLevelLoaded()
	self:StartWindTurbines()
end

function VuBattleRoyaleClient:OnLevelDestroy()
	m_Hud:OnLevelDestroy()
	m_HudUtils:OnExtensionUnloading()
	m_SpectatorClient:OnLevelDestroy()
	m_Gunship:OnLevelDestroy()
	m_VanillaUIManager:OnLevelDestroy()
	m_Chat:OnLevelDestroy()
end

-- =============================================
	-- Update Events
-- =============================================

function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)
	m_Hud:OnEngineUpdate(p_DeltaTime)
	m_SpectatorClient:OnEngineUpdate(p_DeltaTime)
	m_Ping:OnEngineUpdate(p_DeltaTime)
	m_Chat:OnEngineUpdate(p_DeltaTime)
	m_AntiCheat:OnEngineUpdate(p_DeltaTime)
end

function VuBattleRoyaleClient:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		m_Ping:OnUpdatePassPreSim(p_DeltaTime)
		m_Gunship:OnUpdatePassPreSim(p_DeltaTime)
	elseif p_UpdatePass == UpdatePass.UpdatePass_PreFrame then
		m_Hud:OnUIDrawHud(self.m_BrPlayer)
		m_Ping:OnUIDrawHud(self.m_BrPlayer)
		m_Gunship:OnUIDrawHud(p_DeltaTime)
	end
end

function VuBattleRoyaleClient:OnClientUpdateInput()
	m_Gunship:OnClientUpdateInput()
	m_SpectatorClient:OnClientUpdateInput()
	m_Hud:OnClientUpdateInput()
	m_Ping:OnClientUpdateInput()
end

-- =============================================
	-- Player Events
-- =============================================

function VuBattleRoyaleClient:OnPlayerConnected(p_Player)
	if p_Player == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if p_Player == s_LocalPlayer then
		m_Hud:OnLevelFinalized()
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

function VuBattleRoyaleClient:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	self:OverrideTeamIds(p_Player, p_TeamId)
end

function VuBattleRoyaleClient:OnSoldierHealthAction(p_Soldier, p_Action)
	m_Hud:OnSoldierHealthAction(p_Soldier, p_Action)
end

-- =============================================
	-- GunSway Event
-- =============================================

function VuBattleRoyaleClient:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	m_AntiCheat:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

-- =============================================
	-- Player Damage Events
-- =============================================

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
	local s_TeamMateDied = false

	if s_TeamPlayers ~= nil then
		for _, l_Teammate in ipairs(s_TeamPlayers) do
			if l_Teammate ~= nil then
				if l_Teammate.State ~= BRPlayerState.Dead then

					s_AliveSquadCount = s_AliveSquadCount + 1

					if s_AliveSquadCount == 2 or s_LocalPlayer.name ~= l_Teammate.Name then
						-- Your squad is still playing; cancel
						return
					end

					if s_Player.name == l_Teammate.Name then
						s_TeamMateDied = true
					end
				end
			end
		end
	end

	if not s_TeamMateDied then
		return
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

function VuBattleRoyaleClient:OnPingNotify(p_PlayerName, p_Position)
	m_Ping:OnPingNotify(p_PlayerName, p_Position)
end

function VuBattleRoyaleClient:OnPingRemoveNotify(p_PlayerName)
	m_Ping:OnPingRemoveNotify(p_PlayerName)
end

function VuBattleRoyaleClient:OnPingUpdateConfig(p_CooldownTime)
	m_Ping:OnPingUpdateConfig(p_CooldownTime)
end

-- =============================================
	-- Gunship Events
-- =============================================

function VuBattleRoyaleClient:OnGunshipEnable(p_Type)
	if p_Type == "Paradrop" then
		m_Gunship:OnGunshipEnable(p_Type)
		m_Hud:OnGunshipEnable()
	end
end

function VuBattleRoyaleClient:OnGunshipDisable()
	m_Gunship:OnGunshipDisable()
	m_Hud:OnGunshipDisable()
end

function VuBattleRoyaleClient:OnJumpOutOfGunship()
	m_Gunship:OnGunshipDisable()
	m_Hud:OnJumpOutOfGunship()
end

function VuBattleRoyaleClient:OnForceJumpOufOfGunship()
	m_Gunship:OnForceJumpOufOfGunship()
end

-- =============================================
	-- PhaseManager Events
-- =============================================

function VuBattleRoyaleClient:OnPhaseManagerUpdate(p_Data)
	m_Hud:OnPhaseManagerUpdate(p_Data)
end

function VuBattleRoyaleClient:OnOuterCircleMove(p_OuterCircle)
	m_Hud:OnOuterCircleMove(p_OuterCircle)
end

-- =============================================
	-- ManDownLoot Events
-- =============================================

function VuBattleRoyaleClient:OnUpdateLootPosition(p_IndexInBlueprint, p_Transform)
	m_ClientManDownLoot:OnUpdateLootPosition(p_IndexInBlueprint, p_Transform)
end

function VuBattleRoyaleClient:OnLootInteractionFinished(p_ManDownLootTable)
	m_ClientManDownLoot:OnLootInteractionFinished(p_ManDownLootTable)
end

-- =============================================
	-- Some more Events
-- =============================================

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

	if p_GameState == GameStates.WarmupToPlane then
		local s_Players = PlayerManager:GetPlayers()

		for _, l_Player in pairs(s_Players) do
			self:OverrideTeamIds(l_Player, l_Player.teamId)
		end
	end

	m_Hud:OnGameStateChanged(p_GameState)
	m_SpectatorClient:OnGameStateChanged(p_GameState)
end

function VuBattleRoyaleClient:OnUpdateTimer(p_Time)
	if p_Time == nil then
		return
	end

	m_Hud:OnUpdateTimer(p_Time)
end

function VuBattleRoyaleClient:OnTeamJoinDenied(p_Error)
	if p_Error == nil then
		return
	end

	m_Hud:OnTeamJoinDenied(p_Error)
end

function VuBattleRoyaleClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
	m_SpectatorClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
end

function VuBattleRoyaleClient:OnUpdateSpectatorCount(p_SpectatorCount)
	m_SpectatorClient:OnUpdateSpectatorCount(p_SpectatorCount)
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

-- =============================================
-- WebUI Events
-- =============================================

function VuBattleRoyaleClient:OnWebUIDeploy()
	m_HudUtils:SetIsInDeployScreen(false)
	m_HudUtils:ShowroomCamera(false)
	m_VanillaUIManager:EnableShowroomSoldier(false)
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil and s_LocalPlayer.soldier ~= nil then
		m_HudUtils:ShowCrosshair(true)
	end

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

function VuBattleRoyaleClient:OnWebUITriggerMenuFunction(p_Function)
	if p_Function == "resume" then
		m_Hud:OnResume()
	elseif p_Function == "team" then
		m_Logger:Write("INFO: Team / Squad is missing.")
	elseif p_Function == "inventory" then
		m_Logger:Write("INFO: Inventory is missing.")
	elseif p_Function == "options" then
		m_Hud:OnOptions()
	elseif p_Function == "quit" then
		m_SpectatorClient:Disable()
		m_Hud:OnQuit()
	end
end

function VuBattleRoyaleClient:OnWebUIOutgoingChatMessage(p_JsonData)
	m_Chat:OnWebUIOutgoingChatMessage(p_JsonData)
end

function VuBattleRoyaleClient:OnWebUISetCursor()
	m_Chat:OnWebUISetCursor()
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleClient:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Hud:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Chat:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
end

function VuBattleRoyaleClient:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
	p_Screen = Asset(p_Screen)
	m_VanillaUIManager:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
end

function VuBattleRoyaleClient:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	m_Chat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
end

function VuBattleRoyaleClient:OnUICreateKillMessage(p_HookCtx)
	p_HookCtx:Return()
end

function VuBattleRoyaleClient:OnUIDrawFriendlyNametag(p_HookCtx)
	if not ServerConfig.Debug.ShowAllNametags then
		-- p_HookCtx:Return()
	end
end

function VuBattleRoyaleClient:OnUIDrawEnemyNametag(p_HookCtx)
	if not ServerConfig.Debug.ShowAllNametags then
		p_HookCtx:Return()
	end
end

function VuBattleRoyaleClient:OnUIDrawMoreNametags(p_HookCtx)
	if not ServerConfig.Debug.ShowAllNametags then
		--p_HookCtx:Return()
	end
end

function VuBattleRoyaleClient:OnUIRenderMinimap(p_HookCtx)
	p_HookCtx:Return()
end

function VuBattleRoyaleClient:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
	m_Gunship:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
end

function VuBattleRoyaleClient:OnClientChatManagerIncomingMessage(p_HookCtx, p_Message, p_PlayerId, p_RecipientMask, p_ChannelId, p_IsSenderDead)
	m_AntiCheat:OnClientChatManagerIncomingMessage(p_HookCtx, p_Message, p_PlayerId, p_RecipientMask, p_ChannelId, p_IsSenderDead)
end

-- =============================================
-- Functions
-- =============================================

function VuBattleRoyaleClient:GetIsHotReload()
	if SharedUtils:GetLevelName() == "Levels/Web_Loading/Web_Loading" then
		return false
	else
		return true
	end
end

function VuBattleRoyaleClient:OnHotReload()
	if not self.m_IsHotReload then
		return
	end

	if SharedUtils:GetLevelName() == nil then
		return
	end

	-- This was a hot reload, and the game is already loaded
	-- So we dispatch all Level / Connection events
	self:OnLevelLoaded()
	m_Hud:OnLevelFinalized()
	-- OnPlayerConnected
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer.soldier ~= nil then
		self:OnPlayerRespawn(s_LocalPlayer)
	end

	g_Timers:Timeout(1, function()
		m_HudUtils:ShowCrosshair(false)
		m_HudUtils:OnEnableMouse()
	end)
end

function VuBattleRoyaleClient:IsTeamMate(p_Player)
	if self.m_BrPlayer == nil then
		return false
	end

	local s_TeamPlayers = self.m_BrPlayer.m_Team:PlayersTable()

	if s_TeamPlayers ~= nil then
		for _, l_Teammate in ipairs(s_TeamPlayers) do
			if l_Teammate ~= nil then
				if p_Player.name == l_Teammate.Name then
					return true
				end
			end
		end
	end

	return false
end

function VuBattleRoyaleClient:OverrideTeamIds(p_Player, p_TeamId)
	if p_Player == PlayerManager:GetLocalPlayer() or self:IsTeamMate(p_Player) then
		m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from " .. p_TeamId .. " to Team1")
		p_Player:OverrideTeamId(TeamId.Team1)
		p_Player:OverrideSquadId(SquadId.Squad1)
	else
		m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from " .. p_TeamId .. " to Team2")
		p_Player:OverrideTeamId(TeamId.Team2)
		p_Player:OverrideSquadId(SquadId.Squad1)
	end
end

function VuBattleRoyaleClient:StartWindTurbines()
	local s_EntityIterator = EntityManager:GetIterator('SequenceEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("F2E30E34-2E82-467B-B160-4BAD4502A465") then
			m_Logger:Write("Start turbine")
			s_Entity:FireEvent("Start")
		end

		s_Entity = s_EntityIterator:Next()
	end
end

return VuBattleRoyaleClient()
