---@class VuBattleRoyaleServer
VuBattleRoyaleServer = class "VuBattleRoyaleServer"

require "__shared/Slots/BRInventorySlot"
require "__shared/Slots/BRInventoryWeaponSlot"
require "__shared/Slots/BRInventoryAttachmentSlot"
require "__shared/Slots/BRInventoryArmorSlot"
require "__shared/Slots/BRInventoryHelmetSlot"
require "__shared/Slots/BRInventoryGadgetSlot"
require "__shared/Slots/BRInventoryBackpackSlot"

require "Types/BRTeam"
require "Types/BRPlayer"
require "Types/BRInventory"

require "DebugCommands"

---@type Whitelist
local m_Whitelist = require "Whitelist"
---@type PhaseManagerServer
local m_PhaseManagerServer = require "PhaseManagerServer"
---@type PingServer
local m_PingServer = require "PingServer"
---@type BRTeamManagerServer
local m_TeamManagerServer = require "BRTeamManagerServer"
---@type SpectatorServer
local m_SpectatorServer = require "SpectatorServer"
---@type AntiCheatServer
local m_AntiCheatServer = require "AntiCheatServer"
---@type BRAirdropManager
local m_BRAirdropManager = require "BRAirdropManager"
---@type OOCFiresServer
local m_OOCFiresServer = require "OOCFiresServer"
---@type GameStateManager
local m_GameStateManager = require "GameStateManager"
---@type Match
local m_Match = require "Match"
---@type GunshipServer
local m_GunshipServer = require "GunshipServer"
---@type MapVEManagerServer
local m_MapVEManagerServer = require "MapVEManagerServer"
---@type BRInventoryManager
local m_InventoryManager = require "BRInventoryManager"
---@type BRItemDatabase
local m_ItemDatabase = require "Types/BRItemDatabase"
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"
---@type ManDownModifier
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier" -- weird
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"

---@type Logger
local m_Logger = Logger("VuBattleRoyaleServer", false)

function VuBattleRoyaleServer:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

---VEXT Shared Extension:Loaded Event
function VuBattleRoyaleServer:OnExtensionLoaded()
	self:RegisterVars()
	Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)
	self:RegisterEvents()
	self:RegisterHooks()
	self:RegisterRconCommands()
	self:OnHotReload()
end

function VuBattleRoyaleServer:RegisterVars()
	self.m_IsHotReload = self:GetIsHotReload()

	self.m_WaitForStart = true
	self.m_CumulatedTime = 0.0
	self.m_ForcedWarmup = false

	self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart
	self.m_PlayersPerTeam = ServerConfig.PlayersPerTeam

	-- Sets the custom gamemode name
	ServerUtils:SetCustomGameModeName("Battle Royale - " .. self:CurrentTeamSize())
end

function VuBattleRoyaleServer:RegisterEvents()
	self.m_Events = {
		Events:Subscribe("Extension:Unloading", self, self.OnExtensionUnloading),

		Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded),
		Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy),

		Events:Subscribe("Engine:Update", self, self.OnEngineUpdate),
		Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate),

		Events:Subscribe("Player:Authenticated", self, self.OnPlayerAuthenticated),
		Events:Subscribe("Player:UpdateInteract", self, self.OnPlayerUpdateInteract),
		Events:Subscribe("Player:ManDownRevived", self, self.OnPlayerManDownRevived),
		Events:Subscribe("Player:Killed", self, self.OnPlayerKilled),
		Events:Subscribe("Player:Left", self, self.OnPlayerLeft),
		Events:Subscribe('Player:Destroyed', self, self.OnPlayerDestroyed),

		NetEvents:Subscribe(PlayerEvents.PlayerConnected, self, self.OnPlayerConnected),
		NetEvents:Subscribe(PlayerEvents.PlayerDeploy, self, self.OnPlayerDeploy),
		NetEvents:Subscribe(PlayerEvents.PlayerSetSkin, self, self.OnPlayerSetSkin),
		NetEvents:Subscribe(PlayerEvents.Despawn, self, self.OnPlayerDespawn),
		NetEvents:Subscribe("Player:Quit", self, self.OnPlayerQuit),
		NetEvents:Subscribe(SpectatorEvents.RequestPitchAndYaw, self, self.OnSpectatorRequestPitchAndYaw),
		NetEvents:Subscribe(PingEvents.ClientPing, self, self.OnPlayerPing),
		NetEvents:Subscribe(PingEvents.RemoveClientPing, self, self.OnRemovePlayerPing),
		NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship),
		NetEvents:Subscribe(GunshipEvents.OpenParachute, self, self.OnOpenParachute),
		NetEvents:Subscribe("ChatMessage:SquadSend", self, self.OnChatMessageSquadSend),
		NetEvents:Subscribe("ChatMessage:AllSend", self, self.OnChatMessageAllSend),
		NetEvents:Subscribe(PhaseManagerNetEvent.InitialState, self, self.OnPhaseManagerInitialState),

		Events:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged),

		NetEvents:Subscribe(InventoryNetEvent.PickupItem, self, self.OnInventoryPickupItem),
		NetEvents:Subscribe(InventoryNetEvent.MoveItem, self, self.OnInventoryMoveItem),
		NetEvents:Subscribe(InventoryNetEvent.UseItem, self, self.OnInventoryUseItem),
		NetEvents:Subscribe(InventoryNetEvent.DropItem, self, self.OnInventoryDropItem),

		Events:Subscribe("Player:ChangingWeapon", self, self.OnPlayerChangingWeapon),
		Events:Subscribe("Player:PostReload", self, self.OnPlayerPostReload),
		Events:Subscribe("BRItem:DestroyItem", self, self.OnItemDestroy),
	}
end

function VuBattleRoyaleServer:RegisterHooks()
	self.m_Hooks = {
		Hooks:Install("Player:RequestJoin", 100, self, self.OnPlayerRequestJoin),
		Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
	}
end

function VuBattleRoyaleServer:RegisterRconCommands()
	RCON:RegisterCommand("br.forceWarmup", RemoteCommandFlag.RequiresLogin, self, self.OnForceWarmupCommand)
	RCON:RegisterCommand("br.forceEnd", RemoteCommandFlag.RequiresLogin, self, self.OnForceEndgameCommand)
	RCON:RegisterCommand("br.setMinPlayers", RemoteCommandFlag.RequiresLogin, self, self.OnMinPlayersCommand)
	RCON:RegisterCommand("br.setPlayersPerTeam", RemoteCommandFlag.RequiresLogin, self, self.OnPlayerPerTeamCommand)
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Unloading Event
function VuBattleRoyaleServer:OnExtensionUnloading()
	m_PhaseManagerServer:OnExtensionUnloading()
	m_OOCFiresServer:OnExtensionUnloading()
	m_GunshipServer:OnExtensionUnloading()
end

-- =============================================
	-- Level Events
-- =============================================

---VEXT Shared Extension:Loaded Event
function VuBattleRoyaleServer:OnLevelLoadResources()
	if MapsConfig[LevelNameHelper:GetLevelName()] == nil then
		for _, l_Event in pairs(self.m_Events) do
			l_Event:Unsubscribe()
		end

		for _, l_Hook in pairs(self.m_Hooks) do
			l_Hook:Uninstall()
		end

		self.m_Events = {}
		self.m_Hooks = {}

		ServerUtils:ClearCustomGameModeName()
		m_TeamManagerServer:DestroyAll()

		return
	elseif #self.m_Events == 0 then
		self:RegisterEvents()
		self:RegisterHooks()
		ServerUtils:SetCustomGameModeName("Battle Royale - " .. self:CurrentTeamSize())

		for _, l_Player in pairs(PlayerManager:GetPlayers()) do
			m_TeamManagerServer:CreatePlayer(l_Player)
		end
	end

	m_MapVEManagerServer:OnLevelLoadResources()
	self:SetupRconVariables()
end

---VEXT Server Level:Loaded Event
---@param p_LevelName string
---@param p_GameMode string
---@param p_Round integer
---@param p_RoundsPerMap integer
function VuBattleRoyaleServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	self:DisablePreRound()
	m_Match:OnLevelLoaded()
	self.m_WaitForStart = false
	self.m_ForcedWarmup = false
	m_PhaseManagerServer:OnLevelLoaded()
	m_PingServer:OnLevelLoaded()
	m_AntiCheatServer:OnLevelLoaded()
	m_MapVEManagerServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
end

---VEXT Shared Level:Destroy Event
function VuBattleRoyaleServer:OnLevelDestroy()
	self.m_WaitForStart = true
	self.m_ForcedWarmup = false
	m_TeamManagerServer:OnLevelDestroy()
	m_OOCFiresServer:OnLevelDestroy()
	m_PhaseManagerServer:OnLevelDestroy()
	m_MapVEManagerServer:OnLevelDestroy()
	m_LootPickupDatabase:OnLevelDestroy()

	-- destroy all bots
	for _, l_Player in pairs(PlayerManager:GetPlayers()) do
		if l_Player.onlineId == 0 then
			-- this will trigger Player:Destroyed and from there we remove the BrPlayer
			PlayerManager:DeletePlayer(l_Player)
		end
	end
end

-- =============================================
	-- Update Events
-- =============================================

---VEXT Shared Engine:Update Event
---@param p_DeltaTime number
---@param p_SimulationDeltaTime number
function VuBattleRoyaleServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_WaitForStart then
		return
	end

	m_PingServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_AntiCheatServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_BRAirdropManager:OnEngineUpdate(p_DeltaTime)

	if self.m_CumulatedTime < 1.0 then
		self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
		return
	end

	self.m_CumulatedTime = 0.0

	if PlayerManager:GetPlayerCount() >= self.m_MinPlayersToStart then
		local s_SpawnedPlayerCount = 0
		local s_Players = PlayerManager:GetPlayers()

		for _, l_Player in ipairs(s_Players) do
			if l_Player ~= nil and l_Player.alive then
				s_SpawnedPlayerCount = s_SpawnedPlayerCount + 1
			end
		end

		if m_GameStateManager:IsGameState(GameStates.None) and s_SpawnedPlayerCount >= self.m_MinPlayersToStart then
			m_GameStateManager:SetGameState(GameStates.Warmup)
		end
	elseif m_GameStateManager:IsGameState(GameStates.Warmup) and self.m_ForcedWarmup == false then
		m_GameStateManager:SetGameState(GameStates.None)
	end
end

---VEXT Shared UpdateManager:Update Event
---@param p_DeltaTime number
---@param p_UpdatePass UpdatePass|integer
function VuBattleRoyaleServer:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		m_GunshipServer:OnUpdatePassPreSim(p_DeltaTime)
		m_Match:OnUpdatePassPreSim(p_DeltaTime)
	end
end

-- =============================================
	-- Player Events
-- =============================================

---VEXT Server Player:Authenticated Event
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerAuthenticated(p_Player)
	m_TeamManagerServer:OnPlayerAuthenticated(p_Player)

	if p_Player.onlineId ~= 0 then
		m_MapVEManagerServer:OnPlayerAuthenticated(p_Player)
	end
end

---VEXT Server Player:UpdateInteract Event
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerUpdateInteract(p_Player)
	m_GunshipServer:OnPlayerUpdateInteract(p_Player)
end

---VEXT Server Player:ChangingWeapon Event
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerChangingWeapon(p_Player)
	if p_Player.soldier == nil then
		return
	end

	if p_Player.soldier.isInteractiveManDown == false then
		m_InventoryManager:OnPlayerChangingWeapon(p_Player)
	else
		p_Player.soldier:ApplyCustomization(m_ManDownModifier:CreateManDownCustomizeSoldierData())
	end
end

---VEXT Server Player:ManDownRevived Event
---@param p_Player Player
---@param p_Reviver Player
---@param p_IsAdrenalineRevive boolean
function VuBattleRoyaleServer:OnPlayerManDownRevived(p_Player, p_Reviver, p_IsAdrenalineRevive)
	p_Player.soldier.health = 130
end

---VEXT Server Player:Killed Event
---@param p_Player Player
---@param p_Inflictor Player
---@param p_Position Vec3
---@param p_Weapon Entity
---@param p_IsRoadKill boolean
---@param p_IsHeadShot boolean
---@param p_WasVictimInReviveState boolean
---@param p_DamageGiverInfo DamageGiverInfo
function VuBattleRoyaleServer:OnPlayerKilled(p_Player, p_Inflictor, p_Position, p_Weapon, p_IsRoadKill, p_IsHeadShot, p_WasVictimInReviveState, p_DamageGiverInfo)
	m_TeamManagerServer:OnPlayerKilled(p_Player)
end

---VEXT Server Player:Left Event
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerLeft(p_Player)
	m_Logger:Write(p_Player.name .. " left")

	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

	if s_BrPlayer == nil or s_BrPlayer.m_QuitManually then
		return
	end

	-- check if this BrPlayer was replaced with a bot
	if s_BrPlayer:GetPlayer().onlineId == 0	and p_Player.onlineId ~= 0 then
		return
	end

	-- check if this bot was replaced with a real player
	if s_BrPlayer:GetPlayer().onlineId ~= 0	and p_Player.onlineId == 0 then
		return
	end

	-- that player left, so we remove his BrPlayer
	m_TeamManagerServer:OnPlayerLeft(p_Player)
	m_InventoryManager:OnPlayerLeft(p_Player)
end

---VEXT Server Player:Destroyed Event
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerDestroyed(p_Player)
	if p_Player.onlineId ~= 0 then
		return
	end

	-- bot left
	self:OnPlayerLeft(p_Player)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

-- =============================================
	-- Player Events
-- =============================================

---Custom Server PlayerEvents.PlayerConnected NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerConnected(p_Player)
	m_OOCFiresServer:OnPlayerConnected(p_Player)
	m_PingServer:OnPlayerConnected(p_Player)
	-- Send out gamestate information if he connects or reconnects
	NetEvents:SendTo(PlayerEvents.GameStateChanged, p_Player, GameStates.None, m_GameStateManager:GetGameState())
	NetEvents:SendTo(PlayerEvents.MinPlayersToStartChanged, p_Player, self.m_MinPlayersToStart)
	NetEvents:SendTo(PlayerEvents.PlayersPerTeamChanged, p_Player, self.m_PlayersPerTeam)

	m_LootPickupDatabase:SendPlayerAllLootpickupStates(p_Player)

	-- Fade in the default (showroom) camera
	p_Player:Fade(1.0, false)
end

---Custom Server PlayerEvents.PlayerDeploy NetEvent
---@param p_Player Player
---@param p_AppearanceName string
function VuBattleRoyaleServer:OnPlayerDeploy(p_Player, p_AppearanceName)
	-- Spawn player if the current gamestate is warmup
	if m_GameStateManager:IsGameState(GameStates.Warmup) or m_GameStateManager:IsGameState(GameStates.None) then
		local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

		if s_BrPlayer == nil then
			m_Logger:Warning("BrPlayer for " .. p_Player.name .. " not found. Create it now.")
			s_BrPlayer = m_TeamManagerServer:CreatePlayer(p_Player)
		end

		s_BrPlayer:SetAppearance(p_AppearanceName)

		local s_SpawnTrans = m_Match:GetRandomWarmupSpawnpoint()

		if s_SpawnTrans == nil then
			return
		end

		s_BrPlayer:Spawn(
			LinearTransform(
				Vec3(1.0, 0.0, 0.0),
				Vec3(0.0, 1.0, 0.0),
				Vec3(0.0, 0.0, 1.0),
				s_SpawnTrans
			),
			false
		)
	else
		NetEvents:SendTo(PlayerEvents.EnableSpectate, p_Player)
	end
end

---Custom Server PlayerEvents.PlayerSetSkin NetEvent
---@param p_Player Player
---@param p_AppearanceName string
function VuBattleRoyaleServer:OnPlayerSetSkin(p_Player, p_AppearanceName)
	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

	if s_BrPlayer == nil then
		return
	end

	s_BrPlayer:SetAppearance(p_AppearanceName, true)
end

---Custom Server PlayerEvents.Despawn NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerDespawn(p_Player)
	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

	if s_BrPlayer == nil then
		return
	end

	s_BrPlayer:Kill(true)
end

---Custom Server Player:Quit NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnPlayerQuit(p_Player)
	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Player)

	if s_BrPlayer == nil then
		return
	end

	s_BrPlayer:SetQuitManually(true)
end

-- =============================================
	-- Spectator Events
-- =============================================

---Custom Server SpectatorEvents.RequestPitchAndYaw NetEvent
---@param p_Player Player
---@param p_SpectatingId integer @Player.id
function VuBattleRoyaleServer:OnSpectatorRequestPitchAndYaw(p_Player, p_SpectatingId)
	m_SpectatorServer:OnSpectatorRequestPitchAndYaw(p_Player, p_SpectatingId)
end

-- =============================================
	-- Ping Events
-- =============================================

---Custom Server PingEvents.ClientPing NetEvent
---@param p_Player Player
---@param p_Position Vec3
---@param p_PingType PingType|integer
function VuBattleRoyaleServer:OnPlayerPing(p_Player, p_Position, p_PingType)
	m_PingServer:OnPlayerPing(p_Player, p_Position, p_PingType)
end

---Custom Server PingEvents.RemoveClientPing NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnRemovePlayerPing(p_Player)
	m_PingServer:OnRemovePlayerPing(p_Player)
end

-- =============================================
	-- Gunship Events
-- =============================================

---Custom Server GunshipEvents.JumpOut NetEvent
---@param p_Player Player
---@param p_Transform LinearTransform|nil
function VuBattleRoyaleServer:OnJumpOutOfGunship(p_Player, p_Transform)
	m_GunshipServer:OnJumpOutOfGunship(p_Player, p_Transform)
end

---Custom Server GunshipEvents.OpenParachute NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnOpenParachute(p_Player)
	m_GunshipServer:OnOpenParachute(p_Player)
end

---Custom Server ChatMessage:SquadSend NetEvent
---@param p_Player Player
---@param p_Message string
function VuBattleRoyaleServer:OnChatMessageSquadSend(p_Player, p_Message)
	local s_BrTeam = m_TeamManagerServer:GetTeamByPlayer(p_Player)

	if s_BrTeam == nil then
		m_Logger:Write("Chat: BrTeam of player ".. p_Player.name .. "is nil. We can't send this message.")
		return
	end

	for _, l_Player in pairs(s_BrTeam.m_Players) do
		NetEvents:SendToLocal("ChatMessage:SquadReceive", l_Player:GetPlayer(), p_Player.name, p_Message)
	end

	RCON:TriggerEvent("player.onChat", {p_Player.name, p_Message, "squad", tostring(p_Player.teamId), tostring(p_Player.squadId)})
end

---Custom Server ChatMessage:AllSend NetEvent
---@param p_Player Player
---@param p_Message string
function VuBattleRoyaleServer:OnChatMessageAllSend(p_Player, p_Message)
	NetEvents:BroadcastLocal("ChatMessage:AllReceive", p_Player.name, p_Message)
	RCON:TriggerEvent("player.onChat", {p_Player.name, p_Message, "all"})
end

---Custom Server PhaseManagerNetEvent.InitialState NetEvent
---@param p_Player Player
function VuBattleRoyaleServer:OnPhaseManagerInitialState(p_Player)
	m_PhaseManagerServer:OnPhaseManagerInitialState(p_Player)
end

-- =============================================
	-- GameState Event
-- =============================================

---Custom Server PlayerEvents.GameStateChanged Event
---@param p_OldGameState GameStates|integer
---@param p_GameState GameStates|integer
function VuBattleRoyaleServer:OnGameStateChanged(p_OldGameState, p_GameState)
	m_Match:InitMatch()
end

-- TODO: figure out the types
---Custom Server InventoryNetEvent.PickupItem NetEvent
---@param p_Player Player
---@param p_LootPickupId any
---@param p_ItemId any
---@param p_SlotIndex any
function VuBattleRoyaleServer:OnInventoryPickupItem(p_Player, p_LootPickupId, p_ItemId, p_SlotIndex)
	m_InventoryManager:OnInventoryPickupItem(p_Player, p_LootPickupId, p_ItemId, p_SlotIndex)
end

function VuBattleRoyaleServer:OnInventoryMoveItem(p_Player, p_ItemId, p_SlotId)
	m_InventoryManager:OnInventoryMoveItem(p_Player, p_ItemId, p_SlotId)
end

function VuBattleRoyaleServer:OnInventoryUseItem(p_Player, p_ItemId)
	m_InventoryManager:OnInventoryUseItem(p_Player, p_ItemId)
end

function VuBattleRoyaleServer:OnInventoryDropItem(p_Player, p_ItemId, p_Quantity)
	m_InventoryManager:OnInventoryDropItem(p_Player, p_ItemId, p_Quantity)
end

function VuBattleRoyaleServer:OnPlayerPostReload(p_Player, p_AmmoAdded, p_Weapon)
	m_InventoryManager:OnPlayerPostReload(p_Player, p_AmmoAdded, p_Weapon)
end

function VuBattleRoyaleServer:OnItemDestroy(p_ItemId)
	m_InventoryManager:OnItemDestroy(p_ItemId)
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Server Player:RequestJoin Hook
---@param p_HookCtx HookContext
---@param p_JoinMode string
---@param p_AccountGuid Guid
---@param p_PlayerGuid Guid
---@param p_PlayerName string
function VuBattleRoyaleServer:OnPlayerRequestJoin(p_HookCtx, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
	m_Whitelist:OnPlayerRequestJoin(p_HookCtx, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
end

---VEXT Server Soldier:Damage Hook
---@param p_HookCtx HookContext
---@param p_Soldier SoldierEntity
---@param p_Info DamageInfo
---@param p_GiverInfo DamageGiverInfo
function VuBattleRoyaleServer:OnSoldierDamage(p_HookCtx, p_Soldier, p_Info, p_GiverInfo)
	-- If we are in warmup we should disable all damages
	if m_GameStateManager:GetGameState() <= GameStates.WarmupToPlane or m_GameStateManager:GetGameState() >= GameStates.EndGame then
		-- if p_GiverInfo.giver == nil then --or p_GiverInfo.damageType == DamageType.Suicide
			-- return
		-- end

		-- p_Info.damage = 0.0
		-- p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
		p_HookCtx:Return()
		return
	end

	if p_Soldier == nil or p_Info == nil or p_Soldier.player == nil or p_GiverInfo == nil then
		return
	end

	-- let healing items "damage" pass
	if p_Info.damage < 0 then
		p_HookCtx:Pass(p_Soldier, p_Info, p_GiverInfo)
		return
	end

	local s_BrPlayer = m_TeamManagerServer:GetPlayer(p_Soldier.player)
	---@type BRPlayer|nil
	local s_BrGiver = nil

	if p_GiverInfo.giver ~= nil then
		s_BrGiver = m_TeamManagerServer:GetPlayer(p_GiverInfo.giver)
	end

	p_Info.damage = s_BrPlayer:OnDamaged(p_Info.damage, s_BrGiver, p_Info.boneIndex == 1)
	p_HookCtx:Pass(p_Soldier, p_Info, p_GiverInfo)
end

-- =============================================
-- RCON Commands
-- =============================================

---Custom br.forceWarmup RCON Command
---@param p_Command string
---@param p_Args string[]
---@param p_LoggedIn boolean
---@return string[]
function VuBattleRoyaleServer:OnForceWarmupCommand(p_Command, p_Args, p_LoggedIn)
	if not m_GameStateManager:IsGameState(GameStates.None) then
		return {
			"ERROR",
			"You can only start the warmup pre-round!"
		}
	end

	self.m_ForcedWarmup = true
	m_GameStateManager:SetGameState(GameStates.Warmup)

	return {
		"OK",
		"Warmup started!"
	}
end

---Custom br.forceEnd RCON Command
---@param p_Command string
---@param p_Args string[]
---@param p_LoggedIn boolean
---@return string[]
function VuBattleRoyaleServer:OnForceEndgameCommand(p_Command, p_Args, p_LoggedIn)
	m_GameStateManager:SetGameState(GameStates.EndGame)

	return {
		"OK",
		"Game ended!"
	}
end

---Custom br.setMinPlayers RCON Command
---@param p_Command string
---@param p_Args string[]
---@param p_LoggedIn boolean
---@return string[]
function VuBattleRoyaleServer:OnMinPlayersCommand(p_Command, p_Args, p_LoggedIn)
	if p_Args[1] == nil then
		return {
			"ERROR",
			"You need to specify the min players count!"
		}
	end

	local s_MinNum = tonumber(p_Args[1])

	if s_MinNum <= 0 or s_MinNum > 99 then
		return {
			"ERROR",
			"You can only set the min players count between 0 and 99!"
		}
	end

	self.m_MinPlayersToStart = s_MinNum
	NetEvents:BroadcastLocal(PlayerEvents.MinPlayersToStartChanged, s_MinNum)

	return {
		"OK",
		"Min players count set!"
	}
end

---Custom br.setPlayersPerTeam RCON Command
---@param p_Command string
---@param p_Args string[]
---@param p_LoggedIn boolean
---@return string[]
function VuBattleRoyaleServer:OnPlayerPerTeamCommand(p_Command, p_Args, p_LoggedIn)
	if p_Args[1] == nil then
		return {
			"ERROR",
			"You need to specify the player count per time!"
		}
	end

	local s_MinNum = tonumber(p_Args[1])

	if s_MinNum < 1 or s_MinNum > 4 then
		return {
			"ERROR",
			"You can only set player count per team between 1 and 4!"
		}
	end

	if s_MinNum == self.m_PlayersPerTeam then
		return {
			"ERROR",
			"Player count per team already set!"
		}
	end

	self.m_PlayersPerTeam = s_MinNum
	NetEvents:BroadcastLocal(PlayerEvents.PlayersPerTeamChanged, s_MinNum)
	m_TeamManagerServer:UpdatePlayerPerTeam(s_MinNum)
	ServerUtils:SetCustomGameModeName("Battle Royale - " .. self:CurrentTeamSize())

	return {
		"OK",
		"Player count per team set!"
	}
end

-- =============================================
-- Functions
-- =============================================

---Determine if this was a hot mod reload
---@return boolean
function VuBattleRoyaleServer:GetIsHotReload()
	if #SharedUtils:GetContentPackages() == 0 then
		return false
	else
		return true
	end
end

---Gets called after OnExtensionLoaded
function VuBattleRoyaleServer:OnHotReload()
	if not self.m_IsHotReload then
		return
	end

	-- Delay because client didn't finish the mod reload yet
	m_TimerManager:Timeout(1, function()
		-- OnPlayerAuthenticated
		local s_Players = PlayerManager:GetPlayers()

		if s_Players ~= nil and #s_Players > 0 then
			for _, l_Player in pairs(s_Players) do
				if l_Player ~= nil then
					self:OnPlayerAuthenticated(l_Player)
				end
			end
		end

		if SharedUtils:GetLevelName() == nil then
			self.m_WaitForStart = true
			return
		end

		-- OnPlayerConnected
		NetEvents:BroadcastLocal(PingEvents.UpdateConfig, m_PingServer:GetPingDisplayCooldownTime())
		NetEvents:Broadcast(PlayerEvents.GameStateChanged, GameStates.None, m_GameStateManager:GetGameState())
	end)

	if SharedUtils:GetLevelName() == nil then
		self.m_WaitForStart = true
		return
	end

	self:OnLevelLoaded()
	PlayerManager:FadeInAll(1.0)
end

---Returns the current team size
---@return '"Solo"'|'"Duo"'|'"Squad"'
function VuBattleRoyaleServer:CurrentTeamSize()
	if self.m_PlayersPerTeam == 1 then
		return "Solo"
	elseif self.m_PlayersPerTeam == 2 then
		return "Duo"
	else
		return "Squad"
	end
end

---Disabling the PreRound
function VuBattleRoyaleServer:DisablePreRound()
	-- Thanks to https://github.com/FlashHit/VU-Mods/blob/master/No-PreRound/ext/Server/__init__.lua
	-- This is for Conquest tickets etc.
	local s_TicketCounterIterator = EntityManager:GetIterator("ServerTicketCounterEntity")
	local s_TicketCounterEntity = s_TicketCounterIterator:Next()

	while s_TicketCounterEntity do
		s_TicketCounterEntity = Entity(s_TicketCounterEntity)
		s_TicketCounterEntity:FireEvent("StartRound")
		s_TicketCounterEntity = s_TicketCounterIterator:Next()
	end

	-- This is needed so you are able to move
	local s_InputRestrictionIterator = EntityManager:GetIterator("ServerInputRestrictionEntity")
	local s_InputRestrictionEntity = s_InputRestrictionIterator:Next()

	while s_InputRestrictionEntity do
		if s_InputRestrictionEntity.data.instanceGuid == Guid("E8C37E6A-0C8B-4F97-ABDD-28715376BD2D") then
			s_InputRestrictionEntity = Entity(s_InputRestrictionEntity)
			s_InputRestrictionEntity:FireEvent("Disable")
		end

		s_InputRestrictionEntity = s_InputRestrictionIterator:Next()
	end

	-- This Entity is needed so the round ends when tickets are reached
	local s_RoundOverIterator = EntityManager:GetIterator("ServerRoundOverEntity")
	local s_RoundOverEntity = s_RoundOverIterator:Next()

	while s_RoundOverEntity do
		s_RoundOverEntity = Entity(s_RoundOverEntity)
		s_RoundOverEntity:FireEvent("RoundStarted")
		s_RoundOverEntity = s_RoundOverIterator:Next()
	end
end

---Executing a bunch of RCON commands
function VuBattleRoyaleServer:SetupRconVariables()
	-- Hold a dictionary of all of the variables we want to change
	local s_VariablePair = {
		["vars.friendlyFire"] = "true",
		["vars.soldierHealth"] = "100",
		["vars.regenerateHealth"] = "false",
		["vars.onlySquadLeaderSpawn"] = "false",
		["vars.3dSpotting"] = "false",
		["vars.miniMap"] = "false",
		["vars.autoBalance"] = "false",
		["vars.teamKillCountForKick"] = "0",
		["vars.teamKillValueForKick"] = "0",
		["vars.teamKillValueIncrease"] = "0",
		["vars.teamKillValueDecreasePerSecond"] = "0",
		["vars.idleTimeout"] = "0",
		["vars.3pCam"] = "false",
		["vars.killCam"] = "false",
		["vars.roundStartPlayerCount"] = "0",
		["vars.roundRestartPlayerCount"] = "0",
		["vars.hud"] = "true",
		["vu.SquadSize"] = "4",
		["vu.ColorCorrectionEnabled"] = "false",
		["vu.SunFlareEnabled"] = "true",
		["vu.SuppressionMultiplier"] = "0",
		["vu.DestructionEnabled"] = "true",
		["vu.DesertingAllowed"] = "true",
	}

	if ServerConfig.UseOfficialImage then
		s_VariablePair["vu.ServerBanner"] = "https://i.imgur.com/jdUmPVA.jpg"
	end

	-- Iterate through all of the commands and set their values via rcon
	for l_Command, l_Value in pairs(s_VariablePair) do
		local s_Result = RCON:SendCommand(l_Command, { l_Value })

		if #s_Result >= 1 then
			if s_Result[1] ~= "OK" then
				m_Logger:Write("INFO: Command: " .. l_Command .. " returned: " .. s_Result[1])
			end
		end
	end
end

return VuBattleRoyaleServer()
