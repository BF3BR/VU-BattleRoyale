class "VuBattleRoyaleClient"

require "__shared/Configs/ServerConfig"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/SettingsConfig"
require "__shared/Utils/Logger"
require "__shared/Utils/LevelNameHelper"
require "__shared/Utils/LootPointHelper"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"
require "__shared/Configs/CircleConfig"

local m_PhaseManagerClient = require "PhaseManagerClient"
local m_BrPlayer = require "BRPlayer"
local m_HudUtils = require "UI/Utils/HudUtils"
local m_Gunship = require "Gunship"
local m_Hud = require "UI/Hud"
local m_Chat = require "UI/Chat"
local m_SpectatorClient = require "SpectatorClient"
local m_Ping = require "PingClient"
local m_ClientManDownLoot = require "ClientManDownLoot"
local m_AntiCheat = require "AntiCheat"
local m_Settings = require "Settings"
local m_TeamManager = require "BRTeamManager"
local m_OOCFires = require "Visuals/OOCFires"
local m_CircleEffects = require "Visuals/CircleEffects"
local m_OOCVision = require "Visuals/OOCVision"
local m_WindowsCircleSpawner = require "Visuals/WindowsCircleSpawner"

local m_Logger = Logger("VuBattleRoyaleClient", true)

function VuBattleRoyaleClient:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

function VuBattleRoyaleClient:OnExtensionLoaded()
	Events:Subscribe("Level:LoadResources", self, self.OnLoadResources)
	self.m_IsHotReload = self:GetIsHotReload()
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterWebUIEvents()
	self:RegisterHooks()

	m_Hud:OnExtensionLoaded()
	self:OnHotReload()
end

function VuBattleRoyaleClient:RegisterVars()
	-- The current gamestate, it's read-only and can only be changed by the SERVER
	self.m_GameState = GameStates.None
end

function VuBattleRoyaleClient:RegisterEvents()
	self.m_Events = {
		Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading),

		Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded),
		Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy),

		Events:Subscribe("Engine:Update", self, self.OnEngineUpdate),
		Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate),
		Events:Subscribe("Client:UpdateInput", self, self.OnClientUpdateInput),

		Events:Subscribe("Player:Connected", self, self.OnPlayerConnected),
		Events:Subscribe("Player:Respawn", self, self.OnPlayerRespawn),
		Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted),
		Events:Subscribe("Player:TeamChange", self, self.OnPlayerTeamChange),

		Events:Subscribe('Soldier:HealthAction', self, self.OnSoldierHealthAction),
		Events:Subscribe('Soldier:Spawn', self, self.OnSoldierSpawn),

		Events:Subscribe('GunSway:Update', self, self.OnGunSwayUpdate),

		NetEvents:Subscribe("ServerPlayer:Killed", self, self.OnPlayerKilled),
		NetEvents:Subscribe(DamageEvent.PlayerDown, self, self.OnDamageConfirmPlayerDown),
		NetEvents:Subscribe(DamageEvent.PlayerKill, self, self.OnDamageConfirmPlayerKill),
		NetEvents:Subscribe("Player:BrokeShield", self, self.OnPlayerBrokeShield),

		NetEvents:Subscribe(PingEvents.ServerPing, self, self.OnPingNotify),
		NetEvents:Subscribe(PingEvents.RemoveServerPing, self, self.OnPingRemoveNotify),
		NetEvents:Subscribe(PingEvents.UpdateConfig, self, self.OnPingUpdateConfig),

		NetEvents:Subscribe(GunshipEvents.Enable, self, self.OnGunshipEnable),
		NetEvents:Subscribe(GunshipEvents.Disable, self, self.OnGunshipDisable),
		NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship),
		NetEvents:Subscribe(GunshipEvents.ForceJumpOut, self, self.OnForceJumpOufOfGunship),

		Events:Subscribe(PhaseManagerEvent.Update, self, self.OnPhaseManagerUpdate),
		Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnOuterCircleMove),
		NetEvents:Subscribe(PhaseManagerNetEvent.UpdateState, self, self.OnPhaseManagerUpdateState),

		Events:Subscribe("SpectatedPlayerTeamMembers", self, self.OnSpectatedPlayerTeamMembers),

		NetEvents:Subscribe(ManDownLootEvents.UpdateLootPosition, self, self.OnUpdateLootPosition),
		NetEvents:Subscribe(ManDownLootEvents.OnInteractionFinished, self, self.OnLootInteractionFinished),

		NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinDenied, self, self.OnTeamJoinDenied),
		NetEvents:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged),
		NetEvents:Subscribe(PlayerEvents.UpdateTimer, self, self.OnUpdateTimer),
		NetEvents:Subscribe(PlayerEvents.MinPlayersToStartChanged, self, self.OnMinPlayersToStartChanged),
		NetEvents:Subscribe(PlayerEvents.WinnerTeamUpdate, self, self.OnWinnerTeamUpdate),
		NetEvents:Subscribe(PlayerEvents.EnableSpectate, self, self.OnEnableSpectate),
		NetEvents:Subscribe(SpectatorEvents.PostPitchAndYaw, self, self.OnPostPitchAndYaw),
		NetEvents:Subscribe("UpdateSpectatorCount", self, self.OnUpdateSpectatorCount),
		NetEvents:Subscribe("ChatMessage:SquadReceive", self, self.OnChatMessageSquadReceive),
		NetEvents:Subscribe("ChatMessage:AllReceive", self, self.OnChatMessageAllReceive)
	}
end

function VuBattleRoyaleClient:RegisterWebUIEvents()
	self.m_WebUIEvents = {
		Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy),
		Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy),
		Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock),
		Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam),
		Events:Subscribe("WebUI:PingFromMap", self, self.OnWebUIPingFromMap),
		Events:Subscribe("WebUI:PingRemoveFromMap", self, self.OnWebUIPingRemoveFromMap),
		Events:Subscribe("WebUI:TriggerMenuFunction", self, self.OnWebUITriggerMenuFunction),
		Events:Subscribe("WebUI:OutgoingChatMessage", self, self.OnWebUIOutgoingChatMessage),
		Events:Subscribe("WebUI:SetCursor", self, self.OnWebUISetCursor),
		Events:Subscribe("WebUI:HoverCommoRose", self, self.OnWebUIHoverCommoRose)
	}
end

function VuBattleRoyaleClient:RegisterHooks()
	self.m_Hooks = {
		Hooks:Install("UI:InputConceptEvent", 999, self, self.OnInputConceptEvent),
		Hooks:Install("UI:PushScreen", 999, self, self.OnUIPushScreen),
		Hooks:Install('UI:CreateChatMessage',999, self, self.OnUICreateChatMessage),
		Hooks:Install("UI:CreateKillMessage", 999, self, self.OnUICreateKillMessage),
		Hooks:Install("Input:PreUpdate", 999, self, self.OnInputPreUpdate),
		Hooks:Install('UI:DrawEnemyNametag', 1, self, self.OnUIDrawEnemyNametag)
	}
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleClient:OnExtensionUnloading()
	m_Settings:OnExtensionUnloading()
	m_SpectatorClient:OnExtensionUnloading()
	m_Hud:OnExtensionUnloading()
	m_HudUtils:OnExtensionUnloading()
	m_Chat:OnExtensionUnloading()
	m_OOCFires:OnExtensionUnloading()
	m_WindowsCircleSpawner:OnExtensionUnloading()
end

-- =============================================
	-- Level Events
-- =============================================

function VuBattleRoyaleClient:OnLevelLoaded(p_LevelName, p_GameMode)
	m_PhaseManagerClient:OnLevelLoaded()
	m_Settings:OnLevelLoaded()
	m_Hud:OnLevelLoaded()
	m_Ping:OnLevelLoaded()
	self:StartWindTurbines()
end

function VuBattleRoyaleClient:OnLevelDestroy()
	m_Hud:OnLevelDestroy()
	m_HudUtils:OnLevelDestroy()
	m_SpectatorClient:OnLevelDestroy()
	m_Gunship:OnLevelDestroy()
	m_Chat:OnLevelDestroy()
	m_OOCFires:OnLevelDestroy()
	m_WindowsCircleSpawner:OnLevelDestroy()
	m_OOCVision:OnLevelDestroy()
	m_PhaseManagerClient:OnLevelDestroy()
end

function VuBattleRoyaleClient:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	if MapsConfig[LevelNameHelper:GetLevelName()] == nil then
		for _, l_Event in pairs(self.m_Events) do
			l_Event:Unsubscribe()
		end

		for _, l_Event in pairs(self.m_WebUIEvents) do
			l_Event:Unsubscribe()
		end

		for _, l_Hook in pairs(self.m_Hooks) do
			l_Hook:Uninstall()
		end

		self.m_Events = {}
		self.m_WebUIEvents = {}
		self.m_Hooks = {}
		WebUI:Hide()
		return
	elseif #self.m_Events == 0 then
		self:RegisterEvents()
		self:RegisterWebUIEvents()
		self:RegisterHooks()
		WebUI:Show()
	end

	m_OOCVision:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
end

-- =============================================
	-- Update Events
-- =============================================

function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)
	m_Hud:OnEngineUpdate(p_DeltaTime)
	m_SpectatorClient:OnEngineUpdate(p_DeltaTime)
	m_Chat:OnEngineUpdate(p_DeltaTime)
	m_AntiCheat:OnEngineUpdate(p_DeltaTime)
end

function VuBattleRoyaleClient:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		m_PhaseManagerClient:OnUpdatePassPreSim(p_DeltaTime)
		m_Ping:OnUpdatePassPreSim(p_DeltaTime)
		m_Gunship:OnUpdatePassPreSim(p_DeltaTime)
	elseif p_UpdatePass == UpdatePass.UpdatePass_PreFrame then
		m_PhaseManagerClient:OnUIDrawHud(p_DeltaTime)
		m_Hud:OnUIDrawHud()
		m_Ping:OnUIDrawHud(p_DeltaTime)
	elseif p_UpdatePass == UpdatePass.UpdatePass_PostFrame then
		m_Gunship:OnUpdatePassPostFrame(p_DeltaTime)
	end
end

function VuBattleRoyaleClient:OnClientUpdateInput(p_DeltaTime)
	m_Gunship:OnClientUpdateInput()
	m_SpectatorClient:OnClientUpdateInput()
	m_Hud:OnClientUpdateInput()
	m_Ping:OnClientUpdateInput(p_DeltaTime)
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
	m_TeamManager:OnPlayerRespawn(p_Player)
	m_Hud:OnPlayerRespawn(p_Player)
	m_SpectatorClient:OnPlayerRespawn(p_Player)
	m_CircleEffects:OnPlayerRespawn(p_Player)
end

function VuBattleRoyaleClient:OnPlayerDeleted(p_Player)
	m_SpectatorClient:OnPlayerDeleted(p_Player)
end

function VuBattleRoyaleClient:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	m_TeamManager:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
end

function VuBattleRoyaleClient:OnSoldierHealthAction(p_Soldier, p_Action)
	m_Hud:OnSoldierHealthAction(p_Soldier, p_Action)
end

function VuBattleRoyaleClient:OnSoldierSpawn(p_Soldier)
	if self.m_GameState < GameStates.Plane then
		return
	end

	if p_Soldier.player == nil then
		-- it is probably always this case
		g_Timers:Timeout(1.0, self, function()
			self:FixParachuteSound(p_Soldier)
		end)
	else
		self:FixParachuteSound(p_Soldier)
	end
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

function VuBattleRoyaleClient:OnPlayerKilled(p_VictimId, p_InflictorId)
	local s_Player = PlayerManager:GetPlayerById(p_VictimId)

	if s_Player == nil then
		return
	end

	m_Logger:Write("INFO: OnPlayerKilled: " .. s_Player.name)
	m_SpectatorClient:OnPlayerKilled(s_Player.id, p_InflictorId)
	m_Hud:OnPlayerKilled(s_Player.name)
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

function VuBattleRoyaleClient:OnPlayerBrokeShield(p_PlayerName)
	m_Hud:OnPlayerBrokeShield(p_PlayerName)
end

function VuBattleRoyaleClient:OnPingNotify(p_PlayerName, p_Position, p_PingType)
	m_Ping:OnPingNotify(p_PlayerName, p_Position, p_PingType)
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
	m_CircleEffects:OnPhaseManagerUpdate(p_Data)
end

function VuBattleRoyaleClient:OnOuterCircleMove(p_OuterCircle)
	m_Hud:OnOuterCircleMove(p_OuterCircle)
	m_CircleEffects:OnOuterCircleMove(p_OuterCircle)
end

function VuBattleRoyaleClient:OnPhaseManagerUpdateState(p_State)
	m_PhaseManagerClient:OnPhaseManagerUpdateState(p_State)
end

-- =============================================
	-- ManDownLoot Events
-- =============================================

function VuBattleRoyaleClient:OnSpectatedPlayerTeamMembers(p_PlayerNames)
	m_TeamManager:OnSpectatedPlayerTeamMembers(p_PlayerNames)
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

	m_TeamManager:OnGameStateChanged(p_GameState)
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

function VuBattleRoyaleClient:OnChatMessageSquadReceive(p_PlayerName, p_Message)
	m_Chat:OnChatMessageSquadReceive(p_PlayerName, p_Message)
end

function VuBattleRoyaleClient:OnChatMessageAllReceive(p_PlayerName, p_Message)
	m_Chat:OnChatMessageAllReceive(p_PlayerName, p_Message)
end

function VuBattleRoyaleClient:OnMinPlayersToStartChanged(p_MinPlayersToStart)
	m_Hud.m_MinPlayersToStart = p_MinPlayersToStart
end

function VuBattleRoyaleClient:OnWinnerTeamUpdate(p_WinnerTeamId)
	if p_WinnerTeamId == nil then
		return
	end

	if m_BrPlayer.m_Team == nil then
		return
	end

	if p_WinnerTeamId ~= m_BrPlayer.m_Team.m_Id then
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
	m_Hud:OnWebUIDeploy()
end

function VuBattleRoyaleClient:OnWebUISetTeamJoinStrategy(p_Strategy)
	m_BrPlayer:SetTeamJoinStrategy(p_Strategy)
end

function VuBattleRoyaleClient:OnWebUIToggleLock()
	m_BrPlayer:ToggleLock()
end

function VuBattleRoyaleClient:OnWebUIJoinTeam(p_Id)
	if p_Id == nil or p_Id == "" then
		return
	end

	m_BrPlayer:JoinTeam(p_Id)
end

function VuBattleRoyaleClient:OnWebUIPingFromMap(p_Table)
	if m_HudUtils:GetIsMapOpened() then
		m_Ping:OnWebUIPingFromMap(p_Table)
	end
end

function VuBattleRoyaleClient:OnWebUIPingRemoveFromMap()
	if m_HudUtils:GetIsMapOpened() then
		m_Ping:OnWebUIPingRemoveFromMap()
	end
end

function VuBattleRoyaleClient:OnWebUITriggerMenuFunction(p_Function)
	if p_Function == "quit" then
		m_SpectatorClient:Disable()
	end

	m_Hud:OnWebUITriggerMenuFunction(p_Function)
end

function VuBattleRoyaleClient:OnWebUIOutgoingChatMessage(p_JsonData)
	m_Chat:OnWebUIOutgoingChatMessage(p_JsonData)
end

function VuBattleRoyaleClient:OnWebUISetCursor()
	m_Chat:OnWebUISetCursor()
end

function VuBattleRoyaleClient:OnWebUIHoverCommoRose(p_TypeIndex)
	m_Ping:OnWebUIHoverCommoRose(p_TypeIndex)
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleClient:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Hud:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Chat:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
end

function VuBattleRoyaleClient:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
	m_Hud:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
end

function VuBattleRoyaleClient:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	m_AntiCheat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	m_Chat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
end

function VuBattleRoyaleClient:OnUICreateKillMessage(p_HookCtx)
	p_HookCtx:Return()
end

function VuBattleRoyaleClient:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
	m_Gunship:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
end

function VuBattleRoyaleClient:OnUIDrawEnemyNametag(p_HookCtx)
	p_HookCtx:Return()
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

function VuBattleRoyaleClient:FixParachuteSound(p_Soldier)
	-- Fix for: Sometimes when you get close to a player you haven't been near, you hear the parachute open sound #245
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer.soldier ~= nil and s_LocalPlayer == p_Soldier.player then
		return
	end

	-- Get the parachute and freefall SoundEntity for all soldiers except the local soldier
	local s_SoundEntity = p_Soldier.bus:GetEntity(ResourceManager:FindInstanceByGuid(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"), Guid("63CDCA57-2E2C-45FF-A465-CF3EE42E5EE1")))

	-- Should never happen.
	if s_SoundEntity == nil then
		m_Logger:Write("Error - SoundEntity not found.")
		return
	end

	-- Register an event callback and block the ParachuteBegin event
	-- also the ParachuteEnd event, because it could be also this event that causes the issue
	s_SoundEntity:RegisterEventCallback(function(p_Entity, p_EntityEvent)
		if p_EntityEvent.eventId == MathUtils:FNVHash("ParachuteBegin") then
			m_Logger:Write("ParachuteBegin sound blocked.")
			return false
		elseif p_EntityEvent.eventId == MathUtils:FNVHash("ParachuteEnd") then
			m_Logger:Write("ParachuteEnd sound blocked.")
			return false
		end
	end)
end

function VuBattleRoyaleClient:StartWindTurbines()
	local s_EntityIterator = EntityManager:GetIterator('SequenceEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("F2E30E34-2E82-467B-B160-4BAD4502A465") then
			m_Logger:Write("Start turbine")
			local s_Delay = math.random(0, 5000) / 1000

			g_Timers:Timeout(s_Delay, s_Entity, function(p_Entity)
				p_Entity:FireEvent("Start")
			end)
		end

		s_Entity = s_EntityIterator:Next()
	end
end

return VuBattleRoyaleClient()
