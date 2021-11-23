class "VuBattleRoyaleServer"

require "Types/BRTeam"
require "Types/BRPlayer"

local m_Whitelist = require "Whitelist"
local m_ServerManDownLoot = require "ServerManDownLoot"
local m_PhaseManagerServer = require "PhaseManagerServer"
local m_PingServer = require "PingServer"
local m_LootManager = require "LootManagerServer"
local m_TeamManager = require "BRTeamManager"
local m_SpectatorServer = require "SpectatorServer"
local m_AntiCheat = require "AntiCheat"
local m_OOCFires = require "OOCFires"
local m_GameStateManager = require "GameStateManager"
local m_Match = require "Match"
local m_Gunship = require "Gunship"
local m_MapVEManager = require "MapVEManager"
local m_Logger = Logger("VuBattleRoyaleServer", true)
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier" -- weird

function VuBattleRoyaleServer:__init()
	Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

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
	self.m_CumulatedTime = 0
	self.m_ForcedWarmup = false

	self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart

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
		Events:Subscribe("Player:Created", self, self.OnPlayerCreated),
		Events:Subscribe("Player:UpdateInput", self, self.OnPlayerUpdateInput),
		Events:Subscribe("Player:ChangingWeapon", self, self.OnPlayerChangingWeapon),
		Events:Subscribe("Player:ManDownRevived", self, self.OnPlayerManDownRevived),
		Events:Subscribe("Player:Killed", self, self.OnPlayerKilled),
		Events:Subscribe("Player:Left", self, self.OnPlayerLeft),

		NetEvents:Subscribe(PlayerEvents.PlayerConnected, self, self.OnPlayerConnected),
		NetEvents:Subscribe(PlayerEvents.PlayerDeploy, self, self.OnPlayerDeploy),
		NetEvents:Subscribe(SpectatorEvents.RequestPitchAndYaw, self, self.OnSpectatorRequestPitchAndYaw),
		NetEvents:Subscribe(PingEvents.ClientPing, self, self.OnPlayerPing),
		NetEvents:Subscribe(PingEvents.RemoveClientPing, self, self.OnRemovePlayerPing),
		NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship),
		NetEvents:Subscribe(GunshipEvents.OpenParachute, self, self.OnOpenParachute),
		NetEvents:Subscribe("ChatMessage:SquadSend", self, self.OnChatMessageSquadSend),
		NetEvents:Subscribe("ChatMessage:AllSend", self, self.OnChatMessageAllSend),
		NetEvents:Subscribe(PhaseManagerNetEvent.InitialState, self, self.OnPhaseManagerInitialState),

		Events:Subscribe(PlayerEvents.GameStateChanged, self, self.OnGameStateChanged)
	}
end

function VuBattleRoyaleServer:RegisterHooks()
	self.m_Hooks = {
		Hooks:Install("Player:RequestJoin", 100, self, self.OnPlayerRequestJoin),
		Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
	}
end

function VuBattleRoyaleServer:RegisterRconCommands()
	RCON:RegisterCommand("forceWarmup", RemoteCommandFlag.RequiresLogin, self, self.OnForceWarmupCommand)
	RCON:RegisterCommand("forceEnd", RemoteCommandFlag.RequiresLogin, self, self.OnForceEndgameCommand)
	RCON:RegisterCommand("setMinPlayers", RemoteCommandFlag.RequiresLogin, self, self.OnMinPlayersCommand)
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleServer:OnExtensionUnloading()
	m_PhaseManagerServer:OnExtensionUnloading()
	m_OOCFires:OnExtensionUnloading()
	m_Gunship:OnExtensionUnloading()
end

-- =============================================
	-- Level Events
-- =============================================

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

		return
	elseif #self.m_Events == 0 then
		self:RegisterEvents()
		self:RegisterHooks()
		ServerUtils:SetCustomGameModeName("Battle Royale - " .. self:CurrentTeamSize())
	end

	m_LootManager:OnLevelLoadResources()
	m_MapVEManager:OnLevelLoadResources()
end

function VuBattleRoyaleServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	self:DisablePreRound()
	self:SetupRconVariables()
	m_Match:OnRestartRound()
	self.m_WaitForStart = false
	self.m_ForcedWarmup = false
	m_PhaseManagerServer:OnLevelLoaded()
	m_PingServer:OnLevelLoaded()
	m_ServerManDownLoot:OnLevelLoaded()
	m_AntiCheat:OnLevelLoaded()
	m_MapVEManager:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
end

function VuBattleRoyaleServer:OnLevelDestroy()
	self.m_WaitForStart = true
	self.m_ForcedWarmup = false
	m_TeamManager:OnLevelDestroy()
	m_OOCFires:OnLevelDestroy()
	m_PhaseManagerServer:OnLevelDestroy()
	m_MapVEManager:OnLevelDestroy()
end

-- =============================================
	-- Update Events
-- =============================================

function VuBattleRoyaleServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_WaitForStart then
		return
	end

	m_PingServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_AntiCheat:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)

	if self.m_CumulatedTime < 1 then
		self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
		return
	end

	self.m_CumulatedTime = 0

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

function VuBattleRoyaleServer:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		m_Gunship:OnUpdatePassPreSim(p_DeltaTime)
		m_Match:OnUpdatePassPreSim(p_DeltaTime)
	end
end

-- =============================================
	-- Player Events
-- =============================================

function VuBattleRoyaleServer:OnPlayerAuthenticated(p_Player)
	if p_Player == nil then
		return
	end

	m_LootManager:OnPlayerAuthenticated(p_Player)
	m_TeamManager:OnPlayerAuthenticated(p_Player)
	m_MapVEManager:OnPlayerAuthenticated(p_Player)
end

function VuBattleRoyaleServer:OnPlayerCreated(p_Player)
	if p_Player == nil then
		return
	end

	-- Event for bots
	m_TeamManager:OnPlayerAuthenticated(p_Player)
end

function VuBattleRoyaleServer:OnPlayerUpdateInput(p_Player)
	if p_Player == nil then
		return
	end

	m_Gunship:OnPlayerUpdateInput(p_Player)
end

function VuBattleRoyaleServer:OnPlayerChangingWeapon(p_Player)
	if p_Player == nil or p_Player.soldier == nil or p_Player.soldier.isInteractiveManDown == false then
		return
	end

	p_Player.soldier:ApplyCustomization(m_ManDownModifier:CreateManDownCustomizeSoldierData())
end

function VuBattleRoyaleServer:OnPlayerManDownRevived(p_Player, p_Reviver, p_IsAdrenalineRevive)
	p_Player.soldier.health = 130
end

function VuBattleRoyaleServer:OnPlayerKilled(p_Player, p_Inflictor, p_Position, p_Weapon, p_IsRoadKill, p_IsHeadShot)
	m_TeamManager:OnPlayerKilled(p_Player)
end

function VuBattleRoyaleServer:OnPlayerLeft(p_Player)
	m_Logger:Write(p_Player.name .. " left")
	m_TeamManager:OnPlayerLeft(p_Player)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

-- =============================================
	-- Player Events
-- =============================================

function VuBattleRoyaleServer:OnPlayerConnected(p_Player)
	if p_Player == nil then
		return
	end

	m_OOCFires:OnPlayerConnected(p_Player)
	m_PingServer:OnPlayerConnected(p_Player)
	-- Send out gamestate information if he connects or reconnects
	NetEvents:SendTo(PlayerEvents.GameStateChanged, p_Player, GameStates.None, m_GameStateManager:GetGameState())

	-- Fade in the default (showroom) camera
	p_Player:Fade(1.0, false)
end

function VuBattleRoyaleServer:OnPlayerDeploy(p_Player)
	if p_Player == nil then
		return
	end

	-- Spawn player if the current gamestate is warmup
	if m_GameStateManager:IsGameState(GameStates.Warmup) or m_GameStateManager:IsGameState(GameStates.None) then
		local s_BrPlayer = m_TeamManager:GetPlayer(p_Player)

		if s_BrPlayer == nil then
			m_Logger:Warning("BrPlayer for " .. p_Player.name .. " not found. Create it now.")
			s_BrPlayer = m_TeamManager:CreatePlayer(p_Player)
		end

		local s_SpawnTrans = m_Match:GetRandomWarmupSpawnpoint()

		if s_SpawnTrans == nil then
			return
		end

		s_BrPlayer:Spawn(LinearTransform(
			Vec3(1.0, 0.0, 0.0),
			Vec3(0.0, 1.0, 0.0),
			Vec3(0.0, 0.0, 1.0),
			s_SpawnTrans
		))
	else
		NetEvents:SendTo(PlayerEvents.EnableSpectate, p_Player)
	end
end

-- =============================================
	-- Spectator Events
-- =============================================

function VuBattleRoyaleServer:OnSpectatorRequestPitchAndYaw(p_Player, p_SpectatingId)
	if p_SpectatingId == nil then
		return
	end

	m_SpectatorServer:OnSpectatorRequestPitchAndYaw(p_Player, p_SpectatingId)
end

-- =============================================
	-- Ping Events
-- =============================================

function VuBattleRoyaleServer:OnPlayerPing(p_Player, p_Position, p_PingType)
	m_PingServer:OnPlayerPing(p_Player, p_Position, p_PingType)
end

function VuBattleRoyaleServer:OnRemovePlayerPing(p_Player)
	m_PingServer:OnRemovePlayerPing(p_Player)
end

-- =============================================
	-- Gunship Events
-- =============================================

function VuBattleRoyaleServer:OnJumpOutOfGunship(p_Player, p_Transform)
	if p_Player == nil then
		return
	end

	m_Gunship:OnJumpOutOfGunship(p_Player, p_Transform)
end

function VuBattleRoyaleServer:OnOpenParachute(p_Player)
	if p_Player == nil then
		return
	end

	m_Gunship:OnOpenParachute(p_Player)
end

function VuBattleRoyaleServer:OnChatMessageSquadSend(p_Player, p_Message)
	local s_BrTeam = m_TeamManager:GetTeamByPlayer(p_Player)

	if s_BrTeam == nil then
		m_Logger:Write("Chat: BrTeam of player ".. p_Player.name .. "is nil. We can't send this message.")
		return
	end

	for _, l_Player in pairs(s_BrTeam.m_Players) do
		NetEvents:SendToLocal("ChatMessage:SquadReceive", l_Player:GetPlayer(), p_Player.name, p_Message)
	end

	RCON:TriggerEvent("player.onChat", {p_Player.name, p_Message, "squad", tostring(p_Player.teamId), tostring(p_Player.squadId)})
end

function VuBattleRoyaleServer:OnChatMessageAllSend(p_Player, p_Message)
	NetEvents:BroadcastLocal("ChatMessage:AllReceive", p_Player.name, p_Message)
	RCON:TriggerEvent("player.onChat", {p_Player.name, p_Message, "all"})
end

function VuBattleRoyaleServer:OnPhaseManagerInitialState(p_Player)
	m_PhaseManagerServer:OnPhaseManagerInitialState(p_Player)
end

-- =============================================
	-- GameState Event
-- =============================================

function VuBattleRoyaleServer:OnGameStateChanged(p_OldGameState, p_GameState)
	m_Match:InitMatch()
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleServer:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
	m_Whitelist:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
end

function VuBattleRoyaleServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
	-- If we are in warmup we should disable all damages
	if m_GameStateManager:GetGameState() <= GameStates.WarmupToPlane or m_GameStateManager:GetGameState() >= GameStates.EndGame then
		-- if p_GiverInfo.giver == nil then --or p_GiverInfo.damageType == DamageType.Suicide
			-- return
		-- end

		-- p_Info.damage = 0.0
		-- p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
		p_Hook:Return()
		return
	end

	if p_Soldier == nil or p_Info == nil or p_Soldier.player == nil then
		return
	end

	if p_GiverInfo == nil then
		return
	end

	if p_Soldier.player == nil then
		-- already dead
		return
	end

	local s_BrPlayer = m_TeamManager:GetPlayer(p_Soldier.player)
	local s_BrGiver = nil

	if p_GiverInfo.giver ~= nil then
		s_BrGiver = m_TeamManager:GetPlayer(p_GiverInfo.giver)
	end

	p_Info.damage = s_BrPlayer:OnDamaged(p_Info.damage, s_BrGiver)
	p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
end

-- =============================================
-- RCON Commands
-- =============================================

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

function VuBattleRoyaleServer:OnForceEndgameCommand(p_Command, p_Args, p_LoggedIn)
	m_GameStateManager:SetGameState(GameStates.EndGame)

	return {
		"OK",
		"Game ended!"
	}
end

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

-- =============================================
-- Functions
-- =============================================

function VuBattleRoyaleServer:GetIsHotReload()
	if #SharedUtils:GetContentPackages() == 0 then
		return false
	else
		return true
	end
end

function VuBattleRoyaleServer:OnHotReload()
	if not self.m_IsHotReload then
		return
	end

	-- Delay because client didn't finish the mod reload yet
	g_Timers:Timeout(1, function()
		-- OnPlayerAuthenticated
		local s_Players = PlayerManager:GetPlayers()

		if s_Players ~= nil and #s_Players > 0 then
			for _, l_Player in pairs(s_Players) do
				if l_Player ~= nil then
					m_TeamManager:OnPlayerAuthenticated(l_Player)
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

	m_LootManager:OnModReload()
	self:OnLevelLoaded()
	PlayerManager:FadeInAll(1.0)
end

function VuBattleRoyaleServer:CurrentTeamSize()
	if ServerConfig.PlayersPerTeam == 1 then
		return "Solo"
	elseif ServerConfig.PlayersPerTeam == 2 then
		return "Duo"
	else
		return "Squad"
	end
end

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
		["vu.SunFlareEnabled"] = "false",
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
