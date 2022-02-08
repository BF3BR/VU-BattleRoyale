---@class VuBattleRoyaleClient
VuBattleRoyaleClient = class("VuBattleRoyaleClient")

require "ClientCommands"

require "__shared/Configs/SettingsConfig"
require "__shared/Configs/CircleConfig"
require "Utils/CachedJsExecutor"

require "Types/BRInventory"
require "BRTeam"

require "Visuals/CircleRenderers"
require "RenderableCircle"

---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
---@type PhaseManagerClient
local m_PhaseManagerClient = require "PhaseManagerClient"
---@type BRPlayer
local m_BrPlayer = require "BRPlayer"
---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"
---@type GunshipClient
local m_GunshipClient = require "GunshipClient"
---@type VuBattleRoyaleHud
local m_Hud = require "UI/Hud"
---@type Chat
local m_Chat = require "UI/Chat"
---@type SpectatorClient
local m_SpectatorClient = require "SpectatorClient"
---@type PingClient
local m_Ping = require "PingClient"
---@type AntiCheat
local m_AntiCheat = require "AntiCheat"
---@type Settings
local m_Settings = require "Settings"
---@type BRTeamManagerClient
local m_TeamManagerClient = require "BRTeamManagerClient"
---@type OOCFires
local m_OOCFires = require "Visuals/OOCFires"
---@type CircleEffects
local m_CircleEffects = require "Visuals/CircleEffects"
---@type OOCVision
local m_OOCVision = require "Visuals/OOCVision"
---@type WindowsCircleSpawner
local m_WindowsCircleSpawner = require "Visuals/WindowsCircleSpawner"
---@type MapVEManager
local m_MapVEManager = require "Visuals/MapVEManager"
---@type BRLootPickupDatabaseClient
local m_BRLootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type CommonSpatialRaycast
local m_CommonSpatialRaycast = require "CommonSpatialRaycast"
---@type BRLooting
local m_BRLooting = require "Types/BRLooting"
---@type VoipManager
local m_VoipManager = require "VoipManager"

local m_Logger = Logger("VuBattleRoyaleClient", false)

function VuBattleRoyaleClient:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

---VEXT Shared Extension:Loaded Event
function VuBattleRoyaleClient:OnExtensionLoaded()
	Events:Subscribe("Level:LoadResources", self, self.OnLoadResources)
	---@type boolean
	self.m_IsHotReload = self:GetIsHotReload()
	self:RegisterVars()
	self:RegisterEvents()
	self:RegisterWebUIEvents()
	self:RegisterHooks()
	self:RegisterCommands()

	m_Hud:OnExtensionLoaded()
	m_VoipManager:OnExtensionLoaded()
	m_Ping:OnExtensionLoaded()
	self:OnHotReload()
end

function VuBattleRoyaleClient:RegisterVars()
	-- The current gamestate, it's read-only and can only be changed by the SERVER
	---@type GameStates|integer
	self.m_GameState = GameStates.None
end

function VuBattleRoyaleClient:RegisterEvents()
	---@type table <integer, Event|NetEvent>
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

		Events:Subscribe("Soldier:HealthAction", self, self.OnSoldierHealthAction),
		Events:Subscribe("Soldier:Spawn", self, self.OnSoldierSpawn),

		Events:Subscribe("GunSway:Update", self, self.OnGunSwayUpdate),

		Events:Subscribe("VoipChannel:PlayerJoined", self, self.OnVoipChannelPlayerJoined),
		Events:Subscribe("VoipChannel:PlayerLeft", self, self.OnVoipChannelPlayerLeft),
		Events:Subscribe("VoipEmitter:Emitting", self, self.OnVoipEmitterEmitting),

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
		NetEvents:Subscribe(PhaseManagerNetEvent.UpdatePhases, self, self.OnPhaseManagerUpdatePhases),

		NetEvents:Subscribe("SpectatedPlayerTeamMembers", self, self.OnSpectatedPlayerTeamMembers),

		NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinDenied, self, self.OnTeamJoinDenied),
		NetEvents:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged),
		NetEvents:Subscribe(PlayerEvents.UpdateTimer, self, self.OnUpdateTimer),
		NetEvents:Subscribe(PlayerEvents.MinPlayersToStartChanged, self, self.OnMinPlayersToStartChanged),
		NetEvents:Subscribe(PlayerEvents.PlayersPerTeamChanged, self, self.OnPlayersPerTeamChanged),
		NetEvents:Subscribe(PlayerEvents.WinnerTeamUpdate, self, self.OnWinnerTeamUpdate),
		NetEvents:Subscribe(PlayerEvents.EnableSpectate, self, self.OnEnableSpectate),
		NetEvents:Subscribe(SpectatorEvents.PostPitchAndYaw, self, self.OnPostPitchAndYaw),
		NetEvents:Subscribe("UpdateSpectatorCount", self, self.OnUpdateSpectatorCount),
		NetEvents:Subscribe("ChatMessage:SquadReceive", self, self.OnChatMessageSquadReceive),
		NetEvents:Subscribe("ChatMessage:AllReceive", self, self.OnChatMessageAllReceive),

		NetEvents:Subscribe("MapVEManager:SetMapVEPreset", self, self.SetMapVEPreset),
		Events:Subscribe("VEManager:PresetsLoaded", self, self.OnPresetsLoaded),

		NetEvents:Subscribe(InventoryNetEvent.InventoryState, self, self.OnReceiveInventoryState),
		NetEvents:Subscribe(InventoryNetEvent.CreateLootPickup, self, self.OnCreateLootPickup),
		NetEvents:Subscribe(InventoryNetEvent.UnregisterLootPickup, self, self.OnUnregisterLootPickup),
		NetEvents:Subscribe(InventoryNetEvent.UpdateLootPickup, self, self.OnUpdateLootPickup),
		NetEvents:Subscribe(InventoryNetEvent.ItemActionCanceled, self, self.OnItemActionCanceled),

		NetEvents:Subscribe("Airdrop:Dropped", self, self.OnAirdropDropped),
	}
end

function VuBattleRoyaleClient:RegisterWebUIEvents()
	---@type table <integer, Event>
	self.m_WebUIEvents = {
		Events:Subscribe("WebUI:Deploy", self, self.OnWebUIDeploy),
		Events:Subscribe("WebUI:SetSkin", self, self.OnWebUISetSkin),
		Events:Subscribe("WebUI:SetTeamJoinStrategy", self, self.OnWebUISetTeamJoinStrategy),
		Events:Subscribe("WebUI:ToggleLock", self, self.OnWebUIToggleLock),
		Events:Subscribe("WebUI:JoinTeam", self, self.OnWebUIJoinTeam),
		Events:Subscribe("WebUI:PingFromMap", self, self.OnWebUIPingFromMap),
		Events:Subscribe("WebUI:PingRemoveFromMap", self, self.OnWebUIPingRemoveFromMap),
		Events:Subscribe("WebUI:TriggerMenuFunction", self, self.OnWebUITriggerMenuFunction),
		Events:Subscribe("WebUI:OutgoingChatMessage", self, self.OnWebUIOutgoingChatMessage),
		Events:Subscribe("WebUI:SetCursor", self, self.OnWebUISetCursor),
		Events:Subscribe("WebUI:HoverCommoRose", self, self.OnWebUIHoverCommoRose),
		Events:Subscribe("WebUI:MoveItem", self, self.OnWebUIMoveItem),
		Events:Subscribe("WebUI:DropItem", self, self.OnWebUIDropItem),
		Events:Subscribe("WebUI:UseItem", self, self.OnWebUIUseItem),
		Events:Subscribe("WebUI:PickupItem", self, self.OnWebUIPickupItem),
		Events:Subscribe("WebUI:VoipMutePlayer", self, self.OnWebUIVoipMutePlayer),
	}
end

function VuBattleRoyaleClient:RegisterHooks()
	---@type table <integer, Hook>
	self.m_Hooks = {
		Hooks:Install("UI:InputConceptEvent", 999, self, self.OnInputConceptEvent),
		Hooks:Install("UI:PushScreen", 999, self, self.OnUIPushScreen),
		Hooks:Install("UI:CreateChatMessage",999, self, self.OnUICreateChatMessage),
		Hooks:Install("UI:CreateKillMessage", 999, self, self.OnUICreateKillMessage),
		Hooks:Install("Input:PreUpdate", 999, self, self.OnInputPreUpdate),
		Hooks:Install("UI:DrawEnemyNametag", 1, self, self.OnUIDrawEnemyNametag),
	}
end

function VuBattleRoyaleClient:RegisterCommands()
	if not ServerConfig.Debug.EnableDebugCommands then
		self.m_Commands = {}
		return
	end

	---@type table <integer, ConsoleCommand>
	self.m_Commands = {
		Console:Register("give", "Gives player items", ClientCommands.Give),
		Console:Register("spawn", "Spawns items under the player", ClientCommands.Spawn),
		Console:Register("list", "List all the items", ClientCommands.List),
		Console:Register("spawn-airdrop", "spawn-airdrop", ClientCommands.SpawnAirdrop),
	}
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function VuBattleRoyaleClient:OnExtensionUnloading()
	m_Settings:OnExtensionUnloading()
	m_SpectatorClient:OnExtensionUnloading()
	m_Hud:OnExtensionUnloading()
	m_HudUtils:OnExtensionUnloading()
	m_Chat:OnExtensionUnloading()
	m_OOCFires:OnExtensionUnloading()
	m_WindowsCircleSpawner:OnExtensionUnloading()
	m_CircleEffects:OnExtensionUnloading()
	m_BRLootPickupDatabase:OnExtensionUnloading()
end

-- =============================================
	-- Level Events
-- =============================================

---VEXT Client Level:Loaded Event
---@param p_LevelName string
---@param p_GameMode string
function VuBattleRoyaleClient:OnLevelLoaded(p_LevelName, p_GameMode)
	m_PhaseManagerClient:OnLevelLoaded()
	m_Settings:OnLevelLoaded()
	m_Hud:OnLevelLoaded()
	m_Ping:OnLevelLoaded()
	self:StartWindTurbines()
end

---VEXT Shared Level:Destroy Event
function VuBattleRoyaleClient:OnLevelDestroy()
	m_Hud:OnLevelDestroy()
	m_HudUtils:OnLevelDestroy()
	m_SpectatorClient:OnLevelDestroy()
	m_GunshipClient:OnLevelDestroy()
	m_Chat:OnLevelDestroy()
	m_OOCFires:OnLevelDestroy()
	m_WindowsCircleSpawner:OnLevelDestroy()
	m_OOCVision:OnLevelDestroy()
	m_PhaseManagerClient:OnLevelDestroy()
	m_CircleEffects:OnLevelDestroy()
	m_MapVEManager:OnLevelDestroy()
	m_BrPlayer:OnLevelDestroy()
	m_BRLootPickupDatabase:OnLevelDestroy()
end

---VEXT Shared Level:LoadResources Event
---@param p_MapName string
---@param p_GameModeName string
---@param p_DedicatedServer boolean
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

		for _, l_Command in pairs(self.m_Commands) do
			l_Command:Deregister()
		end

		self.m_Events = {}
		self.m_WebUIEvents = {}
		self.m_Hooks = {}
		self.m_Commands = {}

		m_Hud:OnExtensionUnloading()
		WebUI:Hide()
		return
	elseif #self.m_Events == 0 then
		self:RegisterEvents()
		self:RegisterWebUIEvents()
		self:RegisterHooks()
		WebUI:Show()
		m_Hud:OnLevelDestroy()
	end

	m_OOCVision:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_MapVEManager:OnLoadResources(p_MapName, p_GameModeName, p_DedicatedServer)
	m_PhaseManagerClient:OnLoadResources()
end

-- =============================================
	-- Update Events
-- =============================================

---VEXT Shared Engine:Update Event
---@param p_DeltaTime number
function VuBattleRoyaleClient:OnEngineUpdate(p_DeltaTime)
	m_Hud:OnEngineUpdate(p_DeltaTime)
	m_SpectatorClient:OnEngineUpdate(p_DeltaTime)
	m_Chat:OnEngineUpdate(p_DeltaTime)
	m_AntiCheat:OnEngineUpdate(p_DeltaTime)
end

---VEXT Shared UpdateManager:Update Event
---@param p_DeltaTime number
---@param p_UpdatePass UpdatePass|integer
function VuBattleRoyaleClient:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		m_PhaseManagerClient:OnUpdatePassPreSim(p_DeltaTime)
		m_Ping:OnUpdatePassPreSim(p_DeltaTime)
		m_GunshipClient:OnUpdatePassPreSim(p_DeltaTime)
		m_CommonSpatialRaycast:OnUpdatePassPreSim(p_DeltaTime)
	elseif p_UpdatePass == UpdatePass.UpdatePass_PreFrame then
		m_PhaseManagerClient:OnUIDrawHud()
		m_Hud:OnUIDrawHud()
		m_Ping:OnUIDrawHud(p_DeltaTime)
		m_CircleEffects:OnUIDrawHud()
	elseif p_UpdatePass == UpdatePass.UpdatePass_PostFrame then
		m_GunshipClient:OnUpdatePassPostFrame(p_DeltaTime)
	end
end

---VEXT Client Client:UpdateInput Event
---@param p_DeltaTime number
function VuBattleRoyaleClient:OnClientUpdateInput(p_DeltaTime)
	m_GunshipClient:OnClientUpdateInput()
	m_SpectatorClient:OnClientUpdateInput()
	m_Hud:OnClientUpdateInput()
	m_Ping:OnClientUpdateInput(p_DeltaTime)
	m_BRLooting:OnClientUpdateInput()
	m_VoipManager:OnClientUpdateInput()
end

-- =============================================
	-- Player Events
-- =============================================

---VEXT Client Player:Connected Event
---@param p_Player Player
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

---VEXT Client Player:Respawn Event
---@param p_Player Player
function VuBattleRoyaleClient:OnPlayerRespawn(p_Player)
	m_TeamManagerClient:OnPlayerRespawn(p_Player)
	m_Hud:OnPlayerRespawn(p_Player)
	m_SpectatorClient:OnPlayerRespawn(p_Player)
	m_CircleEffects:OnPlayerRespawn()
end

---VEXT Client Player:Deleted Event
---@param p_Player Player
function VuBattleRoyaleClient:OnPlayerDeleted(p_Player)
	m_SpectatorClient:OnPlayerDeleted(p_Player)
end

---VEXT Client Player:TeamChange Event
---@param p_Player Player
---@param p_TeamId TeamId|integer
---@param p_SquadId SquadId|integer
function VuBattleRoyaleClient:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	m_TeamManagerClient:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
end

---VEXT Client Soldier:HealthAction Event
---@param p_Soldier SoldierEntity
---@param p_Action HealthStateAction|integer
function VuBattleRoyaleClient:OnSoldierHealthAction(p_Soldier, p_Action)
	m_Hud:OnSoldierHealthAction(p_Soldier, p_Action)
end

---VEXT Client Soldier:Spawn Event
---@param p_Soldier SoldierEntity
function VuBattleRoyaleClient:OnSoldierSpawn(p_Soldier)
	if self.m_GameState < GameStates.Plane then
		return
	end

	if p_Soldier.player == nil then
		-- it is probably always this case
		m_TimerManager:Timeout(1.0, self, function()
			self:FixParachuteSound(p_Soldier)
		end)
	else
		self:FixParachuteSound(p_Soldier)
	end
end

-- =============================================
	-- GunSway Event
-- =============================================

---VEXT Shared GunSway:Update Event
---@param p_GunSway GunSway
---@param p_Weapon Entity|nil
---@param p_WeaponFiring WeaponFiring|nil
---@param p_DeltaTime number
function VuBattleRoyaleClient:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
	m_AntiCheat:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
end

-- =============================================
	-- Voip Events
-- =============================================

---VEXT Client VoipChannel:PlayerJoined Event
---@param p_Channel VoipChannel
---@param p_Player Player
---@param p_Emitter VoipEmitter
function VuBattleRoyaleClient:OnVoipChannelPlayerJoined(p_Channel, p_Player, p_Emitter)
	m_VoipManager:OnVoipChannelPlayerJoined(p_Channel, p_Player, p_Emitter)
end

---VEXT Client VoipChannel:PlayerLeft Event
---@param p_Channel VoipChannel
---@param p_Player Player
function VuBattleRoyaleClient:OnVoipChannelPlayerLeft(p_Channel, p_Player)
	m_VoipManager:OnVoipChannelPlayerLeft(p_Channel, p_Player)
end

---VEXT Client VoipEmitter:Emitting Event
---@param p_Emitter VoipEmitter
---@param p_IsEmitting boolean
function VuBattleRoyaleClient:OnVoipEmitterEmitting(p_Emitter, p_IsEmitting)
	m_VoipManager:OnVoipEmitterEmitting(p_Emitter, p_IsEmitting)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

-- =============================================
	-- Player Damage Events
-- =============================================

---Custom Client ServerPlayer:Killed NetEvent
---@param p_VictimId integer
---@param p_InflictorId integer|nil
function VuBattleRoyaleClient:OnPlayerKilled(p_VictimId, p_InflictorId)
	local s_Player = PlayerManager:GetPlayerById(p_VictimId)

	if s_Player == nil then
		return
	end

	m_Logger:Write("INFO: OnPlayerKilled: " .. s_Player.name)
	m_SpectatorClient:OnPlayerKilled(s_Player.id, p_InflictorId)
	m_Hud:OnPlayerKilled(s_Player.name)
end

---Custom Client DamageEvent.PlayerDown NetEvent
---@param p_VictimName string
function VuBattleRoyaleClient:OnDamageConfirmPlayerDown(p_VictimName)
	self:OnDamageConfirmPlayerKillOrDown(p_VictimName, false)
end

---Custom Client DamageEvent.PlayerKill NetEvent
---@param p_VictimName string
function VuBattleRoyaleClient:OnDamageConfirmPlayerKill(p_VictimName)
	self:OnDamageConfirmPlayerKillOrDown(p_VictimName, true)
end

---Called from OnDamageConfirmPlayerDown or OnDamageConfirmPlayerKill
---@param p_VictimName string
---@param p_IsKill boolean
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

---Custom Client Player:BrokeShield NetEvent
---@param p_PlayerName string
function VuBattleRoyaleClient:OnPlayerBrokeShield(p_PlayerName)
	m_Hud:OnPlayerBrokeShield(p_PlayerName)
end

---Custom Client PingEvents.ServerPing NetEvent
---@param p_PlayerName string
---@param p_Position Vec3
---@param p_PingType PingType|integer
function VuBattleRoyaleClient:OnPingNotify(p_PlayerName, p_Position, p_PingType)
	m_Ping:OnPingNotify(p_PlayerName, p_Position, p_PingType)
end

---Custom Client PingEvents.RemoveServerPing NetEvent
---@param p_PlayerName string
function VuBattleRoyaleClient:OnPingRemoveNotify(p_PlayerName)
	m_Ping:OnPingRemoveNotify(p_PlayerName)
end

---Custom Client PingEvents.UpdateConfig NetEvent
---@param p_CooldownTime number
function VuBattleRoyaleClient:OnPingUpdateConfig(p_CooldownTime)
	m_Ping:OnPingUpdateConfig(p_CooldownTime)
end

-- =============================================
	-- Gunship Events
-- =============================================

-- TODO: switch to enum
---Custom Client GunshipEvents.Enable NetEvent
---@param p_Type string
function VuBattleRoyaleClient:OnGunshipEnable(p_Type)
	if p_Type == "Paradrop" and not SpectatorManager:GetSpectating() then
		m_GunshipClient:OnGunshipEnable(p_Type)
		m_Hud:OnGunshipEnable()
	end
end

---Custom Client GunshipEvents.Disable NetEvent
function VuBattleRoyaleClient:OnGunshipDisable()
	m_GunshipClient:OnGunshipDisable()
	m_Hud:OnGunshipDisable()
end

---Custom Client GunshipEvents.JumpOut NetEvent
function VuBattleRoyaleClient:OnJumpOutOfGunship()
	m_GunshipClient:OnJumpOutOfGunship()
	m_Hud:OnJumpOutOfGunship()
end

---Custom Client GunshipEvents.ForceJumpOut NetEvent
function VuBattleRoyaleClient:OnForceJumpOufOfGunship()
	m_GunshipClient:OnForceJumpOufOfGunship()
end

-- =============================================
	-- PhaseManager Events
-- =============================================

---Custom Client PhaseManagerEvent.Update Event
---@param p_Data table
function VuBattleRoyaleClient:OnPhaseManagerUpdate(p_Data)
	m_Hud:OnPhaseManagerUpdate(p_Data)
	m_CircleEffects:OnPhaseManagerUpdate(p_Data)
end

---Custom Client PhaseManagerEvent.CircleMove Event
---@param p_OuterCircle table
function VuBattleRoyaleClient:OnOuterCircleMove(p_OuterCircle)
	m_Hud:OnOuterCircleMove(p_OuterCircle)
	m_CircleEffects:OnOuterCircleMove(p_OuterCircle)
end

---Custom Client PhaseManagerNetEvent.UpdateState NetEvent
---@param p_State table
function VuBattleRoyaleClient:OnPhaseManagerUpdateState(p_State)
	m_PhaseManagerClient:OnPhaseManagerUpdateState(p_State)
end

---@param p_Phases PhaseTable[]
function VuBattleRoyaleClient:OnPhaseManagerUpdatePhases(p_Phases)
	m_PhaseManagerClient:OnPhaseManagerUpdatePhases(p_Phases)
end

-- =============================================
	-- ManDownLoot Events
-- =============================================

---Custom Client SpectatedPlayerTeamMembers NetEvent
---@param p_PlayerNames string[]
function VuBattleRoyaleClient:OnSpectatedPlayerTeamMembers(p_PlayerNames)
	m_TeamManagerClient:OnSpectatedPlayerTeamMembers(p_PlayerNames)
end

-- =============================================
	-- Inventory Events
-- =============================================

---Custom Client InventoryNetEvent.InventoryState NetEvent
---@param p_State table @Inventory as table
function VuBattleRoyaleClient:OnReceiveInventoryState(p_State)
	m_BrPlayer.m_Inventory:OnReceiveInventoryState(p_State)
end

---Custom Client InventoryNetEvent.CreateLootPickup NetEvent
---@param p_DataArray table @BRLootPickup as table
function VuBattleRoyaleClient:OnCreateLootPickup(p_DataArray)
	m_BRLootPickupDatabase:OnCreateLootPickup(p_DataArray)
end

---Custom Client InventoryNetEvent.UnregisterLootPickup NetEvent
---@param p_LootPickupId string @Guid as string
function VuBattleRoyaleClient:OnUnregisterLootPickup(p_LootPickupId)
	m_BRLootPickupDatabase:OnUnregisterLootPickup(p_LootPickupId)
	m_BRLooting:OnUnregisterLootPickup(p_LootPickupId)
end

---Custom Client InventoryNetEvent.UpdateLootPickup NetEvent
---@param p_DataArray table @BRLootPickup as table
function VuBattleRoyaleClient:OnUpdateLootPickup(p_DataArray)
	m_BRLootPickupDatabase:OnUpdateLootPickup(p_DataArray)
end

---Custom Client InventoryNetEvent.ItemActionCanceled NetEvent
function VuBattleRoyaleClient:OnItemActionCanceled()
	m_BrPlayer.m_Inventory:OnItemActionCanceled()
end

-- =============================================
	-- Some more Events
-- =============================================

---Custom Client PlayerEvents.GameStateChanged NetEvent
---@param p_OldGameState GameStates|integer
---@param p_GameState GameStates|integer
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

	-- player joined too late -> SetSpectating(true)
	if p_GameState >= GameStates.WarmupToPlane and self.m_GameState == GameStates.None then
		m_Logger:Write("Joined too late - enabling spectator")
		SpectatorManager:SetSpectating(true)
	end

	self.m_GameState = p_GameState

	m_TeamManagerClient:OnGameStateChanged(p_GameState)
	m_Hud:OnGameStateChanged(p_GameState)
	m_SpectatorClient:OnGameStateChanged(p_GameState)
	m_BRLooting:OnGameStateChanged(p_GameState)
end

---Custom Client PlayerEvents.UpdateTimer NetEvent
---@param p_Time number|nil
function VuBattleRoyaleClient:OnUpdateTimer(p_Time)
	if p_Time == nil then
		return
	end

	m_Hud:OnUpdateTimer(p_Time)
end

---Custom Client TeamManagerNetEvent.TeamJoinDenied NetEvent
---@param p_Error TeamManagerErrors|integer
function VuBattleRoyaleClient:OnTeamJoinDenied(p_Error)
	m_Hud:OnTeamJoinDenied(p_Error)
end

---Custom Client SpectatorEvents.PostPitchAndYaw NetEvent
---@param p_Pitch number
---@param p_Yaw number
function VuBattleRoyaleClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
	m_SpectatorClient:OnPostPitchAndYaw(p_Pitch, p_Yaw)
end

---Custom Client UpdateSpectatorCount NetEvent
---@param p_SpectatorCount integer
function VuBattleRoyaleClient:OnUpdateSpectatorCount(p_SpectatorCount)
	m_SpectatorClient:OnUpdateSpectatorCount(p_SpectatorCount)
end

---Custom Client ChatMessage:SquadReceive NetEvent
---@param p_PlayerName string
---@param p_Message string
function VuBattleRoyaleClient:OnChatMessageSquadReceive(p_PlayerName, p_Message)
	m_Chat:OnChatMessageSquadReceive(p_PlayerName, p_Message)
end

---Custom Client ChatMessage:AllReceive NetEvent
---@param p_PlayerName string
---@param p_Message string
function VuBattleRoyaleClient:OnChatMessageAllReceive(p_PlayerName, p_Message)
	m_Chat:OnChatMessageAllReceive(p_PlayerName, p_Message)
end

---Custom Client MapVEManager:SetMapVEPreset NetEvent
---@param p_VEIndex integer
---@param p_OldFadeTime number
---@param p_NewFadeTime number
function VuBattleRoyaleClient:SetMapVEPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
	m_MapVEManager:SetMapVEPreset(p_VEIndex, p_OldFadeTime, p_NewFadeTime)
end

---Custom Client VEManager:PresetsLoaded Event
function VuBattleRoyaleClient:OnPresetsLoaded()
	m_MapVEManager:OnPresetsLoaded()
end

---Custom Client PlayerEvents.MinPlayersToStartChanged NetEvent
---@param p_MinPlayersToStart integer
function VuBattleRoyaleClient:OnMinPlayersToStartChanged(p_MinPlayersToStart)
	m_Hud.m_MinPlayersToStart = p_MinPlayersToStart
end

---Custom Client PlayerEvents.PlayersPerTeamChanged NetEvent
---@param p_PlayerPerTeam integer
function VuBattleRoyaleClient:OnPlayersPerTeamChanged(p_PlayerPerTeam)
	m_Hud.m_PlayersPerTeam = p_PlayerPerTeam
end

---Custom Client PlayerEvents.WinnerTeamUpdate NetEvent
---@param p_WinnerTeam table
function VuBattleRoyaleClient:OnWinnerTeamUpdate(p_WinnerTeam)
	local s_Winner = false

	if m_BrPlayer.m_Team ~= nil and p_WinnerTeam.Id == m_BrPlayer.m_Team.m_Id then
		s_Winner = true
	end

	m_Hud:OnGameOverScreen(s_Winner, p_WinnerTeam)
end

---Custom Client PlayerEvents.EnableSpectate NetEvent
function VuBattleRoyaleClient:OnEnableSpectate()
	m_Logger:Write("NetEvent: Enable spectator")
	m_SpectatorClient:Enable()
	m_GunshipClient:OnGunshipDisable()
	m_Hud:OnJumpOutOfGunship()
end

---Custom Client Airdrop:Dropped NetEvent
function VuBattleRoyaleClient:OnAirdropDropped()
	m_Hud:OnAirdropDropped()
end

-- =============================================
-- WebUI Events
-- =============================================

---Custom Client WebUI:Deploy WebUI Event
---@param p_AppearanceName string
function VuBattleRoyaleClient:OnWebUIDeploy(p_AppearanceName)
	m_Hud:OnWebUIDeploy(p_AppearanceName)
end

---Custom Client WebUI:SetSkin WebUI Event
---@param p_AppearanceName string
function VuBattleRoyaleClient:OnWebUISetSkin(p_AppearanceName)
	NetEvents:Send(PlayerEvents.PlayerSetSkin, p_AppearanceName)
end

---Custom Client WebUI:SetTeamJoinStrategy WebUI Event
---@param p_Strategy TeamJoinStrategy|integer
function VuBattleRoyaleClient:OnWebUISetTeamJoinStrategy(p_Strategy)
	m_BrPlayer:SetTeamJoinStrategy(p_Strategy)
end

---Custom Client WebUI:ToggleLock WebUI Event
function VuBattleRoyaleClient:OnWebUIToggleLock()
	m_BrPlayer:ToggleLock()
end

---Custom Client WebUI:JoinTeam WebUI Event
---@param p_Id string
function VuBattleRoyaleClient:OnWebUIJoinTeam(p_Id)
	m_BrPlayer:JoinTeam(p_Id)
end

---Custom Client WebUI:PingFromMap WebUI Event
---@param p_JsonTable string @json table
function VuBattleRoyaleClient:OnWebUIPingFromMap(p_JsonTable)
	if m_HudUtils:GetIsMapOpened() then
		m_Ping:OnWebUIPingFromMap(p_JsonTable)
	end
end

---Custom Client WebUI:PingRemoveFromMap WebUI Event
function VuBattleRoyaleClient:OnWebUIPingRemoveFromMap()
	if m_HudUtils:GetIsMapOpened() then
		m_Ping:OnWebUIPingRemoveFromMap()
	end
end

-- TODO: switch to enum
---Custom Client WebUI:TriggerMenuFunction WebUI Event
---@param p_Function string
function VuBattleRoyaleClient:OnWebUITriggerMenuFunction(p_Function)
	if p_Function == "quit" then
		m_SpectatorClient:Disable()
	end

	m_Hud:OnWebUITriggerMenuFunction(p_Function)
end

---Custom Client WebUI:OutgoingChatMessage WebUI Event
---@param p_JsonData string @json table
function VuBattleRoyaleClient:OnWebUIOutgoingChatMessage(p_JsonData)
	m_Chat:OnWebUIOutgoingChatMessage(p_JsonData)
end

---Custom Client WebUI:SetCursor WebUI Event
function VuBattleRoyaleClient:OnWebUISetCursor()
	m_Chat:OnWebUISetCursor()
end

---Custom Client WebUI:HoverCommoRose WebUI Event
---@param p_TypeIndex PingType|integer
function VuBattleRoyaleClient:OnWebUIHoverCommoRose(p_TypeIndex)
	m_Ping:OnWebUIHoverCommoRose(p_TypeIndex)
end

---Custom Client WebUI:VoipMutePlayer WebUI Event
---@param p_Params string @json table
function VuBattleRoyaleClient:OnWebUIVoipMutePlayer(p_Params)
	local s_DecodedParams = json.decode(p_Params)

	if s_DecodedParams.playerName == nil or s_DecodedParams.mute == nil then
		return
	end

	m_VoipManager:OnWebUIVoipMutePlayer(s_DecodedParams.playerName, s_DecodedParams.mute)
end

-- =============================================
	-- WebUI Inventory Events
-- =============================================

---Custom Client WebUI:MoveItem WebUI Event
---@param p_JsonData string @json table
function VuBattleRoyaleClient:OnWebUIMoveItem(p_JsonData)
	m_BrPlayer.m_Inventory:OnWebUIMoveItem(p_JsonData)
end

---Custom Client WebUI:DropItem WebUI Event
---@param p_JsonData string @json table
function VuBattleRoyaleClient:OnWebUIDropItem(p_JsonData)
	m_BrPlayer.m_Inventory:OnWebUIDropItem(p_JsonData)
end

-- TODO: Use just the id instead of a table?
---Custom Client WebUI:UseItem WebUI Event
---@param p_JsonData string @json table
function VuBattleRoyaleClient:OnWebUIUseItem(p_JsonData)
	m_BrPlayer.m_Inventory:OnWebUIUseItem(p_JsonData)
end

---Custom Client WebUI:PickupItem WebUI Event
---@param p_JsonData string @json table
function VuBattleRoyaleClient:OnWebUIPickupItem(p_JsonData)
	m_BrPlayer.m_Inventory:OnWebUIPickupItem(p_JsonData)
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Client UI:InputConceptEvent Hook
---@param p_HookCtx HookContext
---@param p_EventType UIInputActionEventType|integer
---@param p_Action UIInputAction|integer
function VuBattleRoyaleClient:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Hud:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Chat:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
end

---VEXT Client UI:PushScreen Hook
---@param p_HookCtx HookContext
---@param p_Screen DataContainer
---@param p_GraphPriority UIGraphPriority|integer
---@param p_ParentGraph DataContainer
---@param p_StateNodeGuid Guid|nil
function VuBattleRoyaleClient:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph, p_StateNodeGuid)
	m_Hud:OnUIPushScreen(p_HookCtx, Asset(p_Screen))
end

---VEXT Client UI:CreateChatMessage Hook
---@param p_HookCtx HookContext
---@param p_Message string
---@param p_Channel ChatChannelType|integer
---@param p_PlayerId integer
---@param p_RecipientMask integer
---@param p_SenderIsDead boolean
function VuBattleRoyaleClient:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	m_AntiCheat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
	m_Chat:OnUICreateChatMessage(p_HookCtx, p_Message, p_Channel, p_PlayerId, p_RecipientMask, p_SenderIsDead)
end

---VEXT Client UI:CreateKillMessage Hook
---@param p_HookCtx HookContext
function VuBattleRoyaleClient:OnUICreateKillMessage(p_HookCtx)
	p_HookCtx:Return()
end

---VEXT Client Input:PreUpdate Hook
---@param p_HookCtx HookContext
---@param p_Cache ConceptCache
---@param p_DeltaTime number
function VuBattleRoyaleClient:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
	m_GunshipClient:OnInputPreUpdate(p_HookCtx, p_Cache, p_DeltaTime)
end

---VEXT Client UI:DrawEnemyNametag Hook
---@param p_HookCtx HookContext
function VuBattleRoyaleClient:OnUIDrawEnemyNametag(p_HookCtx)
	p_HookCtx:Return()
end

-- =============================================
-- Functions
-- =============================================

---Determine if this was a hot mod reload
---@return boolean
function VuBattleRoyaleClient:GetIsHotReload()
	if SharedUtils:GetLevelName() == "Levels/Web_Loading/Web_Loading" then
		return false
	else
		return true
	end
end

---Gets called after OnExtensionLoaded
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

	m_TimerManager:Timeout(1, function()
		m_HudUtils:ShowCrosshair(false)
		m_HudUtils:OnEnableMouse()
	end)
end

---HotFix: Disable the parachute sound for all soldiers except the local one
---@param p_Soldier SoldierEntity
function VuBattleRoyaleClient:FixParachuteSound(p_Soldier)
	-- Fix for: Sometimes when you get close to a player you haven't been near, you hear the parachute open sound #245
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		m_Logger:Write("FixParachuteSound: Local player not found.")
		return
	end

	-- Get the parachute and freefall SoundEntity for all soldiers except the local soldier
	local s_SoundEntity = p_Soldier.bus:GetEntity(ResourceManager:FindInstanceByGuid(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"), Guid("63CDCA57-2E2C-45FF-A465-CF3EE42E5EE1")))

	-- Should never happen.
	if s_SoundEntity == nil then
		m_Logger:Write("Error - SoundEntity not found.")
		return
	end

	-- sometimes the freefall sound isn't working properly
	-- roll effect while parachuting misses
	-- jumping after landing gets/is bugged
	if s_LocalPlayer.soldier ~= nil and s_LocalPlayer == p_Soldier.player then
		m_Logger:Write("FixParachuteSound: Block freefall sound for local player.")

		s_SoundEntity:RegisterEventCallback(function(p_Entity, p_EntityEvent)
			if p_EntityEvent.eventId == MathUtils:FNVHash("FreefallEnd") then
				return false
			elseif p_EntityEvent.eventId == MathUtils:FNVHash("FreefallBegin") then
				return false
			end
		end)

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

---HotFix: Enable the WindTurbines manually
function VuBattleRoyaleClient:StartWindTurbines()
	local s_EntityIterator = EntityManager:GetIterator("SequenceEntity")
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("F2E30E34-2E82-467B-B160-4BAD4502A465") then
			local s_Delay = math.random(0, 5000) / 1000

			---@param p_EntityInstanceId integer
			m_TimerManager:Timeout(s_Delay, s_Entity.instanceId, function(p_EntityInstanceId)
				-- find the entity again
				-- there is a possibilty that we skipped to another level in this delay
				local s_TimerEntityIterator = EntityManager:GetIterator("SequenceEntity")
				local s_TimerEntity = s_TimerEntityIterator:Next()

				while s_TimerEntity do
					if s_TimerEntity.instanceId == p_EntityInstanceId then
						m_Logger:Write("Start turbine")
						s_TimerEntity:FireEvent("Start")
						return
					end

					s_TimerEntity = s_TimerEntityIterator:Next()
				end
			end)
		end

		s_Entity = s_EntityIterator:Next()
	end
end

return VuBattleRoyaleClient()
