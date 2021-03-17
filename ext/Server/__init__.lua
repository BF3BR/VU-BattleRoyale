class "VuBattleRoyaleServer"

require "__shared/Configs/ServerConfig"
require "__shared/Utils/Logger"
require "__shared/Utils/LevelNameHelper"
require "__shared/Configs/MapsConfig"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"

require "Match"

local m_Whitelist = require "Whitelist"
local m_PingServer = require "PingServer"
local m_LootManager = require "LootManagerServer"
local m_TeamManager = require "BRTeamManager"
local m_Logger = Logger("VuBattleRoyaleServer", true)
--local m_InteractiveManDown = require "__shared/InteractiveManDown"

function VuBattleRoyaleServer:__init()
    Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)

    -- Holds the gamestate information
    self.m_GameState = GameStates.None

    self.m_PlayersPitchAndYaw = {}

    self.m_WaitForStart = true

    -- Create a new match
    self.m_Match = Match(self, m_TeamManager)

    self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart

    -- Sets the custom gamemode name
    ServerUtils:SetCustomGameModeName("Baguette")
end

function VuBattleRoyaleServer:OnExtensionLoaded()
    self:RegisterEvents()
    self:RegisterHooks()
    self:RegisterRconCommands()
end

function VuBattleRoyaleServer:RegisterEvents()
    Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
    Events:Subscribe("Player:ManDownRevived", self, self.OnManDownRevived)
    Events:Subscribe("Player:ChangingWeapon", self, self.OnChangingWeapon)
    Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)

    NetEvents:Subscribe("VuBattleRoyale:PlayerConnected", self, self.OnPlayerConnected)
    NetEvents:Subscribe("VuBattleRoyale:PlayerDeploy", self, self.OnPlayerDeploy)

    Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)
    Events:Subscribe("Player:Authenticated", self, self.OnPlayerAuthenticated)
end

function VuBattleRoyaleServer:RegisterHooks()
    Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
    Hooks:Install("Player:RequestJoin", 100, self, self.OnPlayerRequestJoin)
end

function VuBattleRoyaleServer:RegisterRconCommands()
    RCON:RegisterCommand('forceWarmup', RemoteCommandFlag.RequiresLogin, self, self.OnForceWarmupCommand)
    RCON:RegisterCommand('forceEnd', RemoteCommandFlag.RequiresLogin, self, self.OnForceEndgameCommand)
    RCON:RegisterCommand('setMinPlayers', RemoteCommandFlag.RequiresLogin, self, self.OnMinPlayersCommand)
end


-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    if not self.m_WaitForStart then
        -- Update the match
        self.m_Match:OnEngineUpdate(self.m_GameState, p_DeltaTime)

        -- Update the players pitch and yaw table
        self:GetPlayersPitchAndYaw()

        local s_PlayerCount = 0
        local s_Players = PlayerManager:GetPlayers()
        for _, l_Player in ipairs(s_Players) do
            if l_Player == nil and l_Player.alive == false then
                goto update_allowed_guids_continue
            end

            s_PlayerCount = s_PlayerCount + 1

            ::update_allowed_guids_continue::
        end

        if self.m_GameState == GameStates.None and s_PlayerCount >= self.m_MinPlayersToStart then
            self:ChangeGameState(GameStates.Warmup)
        end
    end
end

function VuBattleRoyaleServer:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    self.m_Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
end

function VuBattleRoyaleServer:OnManDownRevived(p_Player, p_Reviver, p_IsAdrenalineRevive)
    if p_Reviver ~= nil then
        p_Player.soldier.health = 30
    else
        p_Player.soldier.health = 0.0001
    end
end

function VuBattleRoyaleServer:OnChangingWeapon(p_Player)
    if p_Player == nil or p_Player.soldier == nil or p_Player.soldier.isInteractiveManDown == false then
        return
    end
    -- p_Player.soldier:ApplyCustomization(m_InteractiveManDown:CreateManDownCustomizeSoldierData())
end

function VuBattleRoyaleServer:OnPlayerConnected(p_Player)
    if p_Player == nil then
        return
    end

    -- Send out gamestate information if he connects or reconnects
    NetEvents:SendTo(PlayerEvents.GameStateChanged, p_Player, GameStates.None, self.m_GameState)

    -- Fade in the default (showroom) camera
    p_Player:Fade(1.0, false)
end

function VuBattleRoyaleServer:OnPlayerDeploy(p_Player)
    if p_Player == nil then
        return
    end

    -- Spawn player if the current gamestate is warmup
    if self.m_GameState == GameStates.Warmup or self.m_GameState == GameStates.None then
        local s_BrPlayer = m_TeamManager:GetPlayer(p_Player)
        if s_BrPlayer == nil then
            return
        end

        local s_SpawnTrans = self.m_Match:GetRandomWarmupSpawnpoint()
        if s_SpawnTrans == nil then
            return
        end

        s_BrPlayer:Spawn(s_SpawnTrans)
    end
end

function VuBattleRoyaleServer:OnPlayerAuthenticated(p_Player)
    if p_Player == nil then
        return
    end

    m_LootManager:OnPlayerAuthenticated(p_Player)
end

function VuBattleRoyaleServer:OnLevelLoadResources()
    m_LootManager:OnLevelLoadResources()
end

function VuBattleRoyaleServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self:DisablePreRound()
    self:SetupRconVariables()
    self.m_Match:OnRestartRound()
    self.m_WaitForStart = false
end

function VuBattleRoyaleServer:OnLevelDestroy()
    self.m_WaitForStart = true
end


-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleServer:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
    m_Whitelist:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
end

function VuBattleRoyaleServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
    if p_Soldier == nil or p_Info == nil or p_Soldier.player == nil then
        return
    end

    -- If we are in warmup we should disable all damages
    if self.m_GameState <= GameStates.WarmupToPlane or self.m_GameState >= GameStates.EndGame then
        if p_GiverInfo.giver == nil then --or p_GiverInfo.damageType == DamageType.Suicide
            return
        end

        p_Info.damage = 0.0
        p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
        return
    end

    if p_GiverInfo == nil or p_GiverInfo.giver == nil then
        if p_Soldier.health <= p_Info.damage then
            -- TODO add placement check
            p_Soldier:ForceDead()
        end

        return
    end

    local l_BrPlayer = m_TeamManager:GetPlayer(p_Soldier.player)
    local l_BrGiver = m_TeamManager:GetPlayer(p_GiverInfo.giver)

    p_Info.damage = l_BrPlayer:OnDamaged(p_Info.damage, l_BrGiver)
    p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
end


-- =============================================
-- RCON Commands
-- =============================================

function VuBattleRoyaleServer:OnForceWarmupCommand(p_Command, p_Args, p_LoggedIn)
	self:ChangeGameState(GameStates.Warmup)

	return { 
        'OK',
        'Warmup started!'
    }
end

function VuBattleRoyaleServer:OnForceEndgameCommand(p_Command, p_Args, p_LoggedIn)
	self:ChangeGameState(GameStates.EndGame)

	return { 
        'OK',
        'Game ended!'
    }
end

function VuBattleRoyaleServer:OnMinPlayersCommand(p_Command, p_Args, p_LoggedIn)
    if p_Args[1] == nil then
        return { 
            'ERROR',
            'You need to specify the min players count!'
        }
    end

    local s_MinNum = tonumber(p_Args[1])

    if s_MinNum <= 0 or s_MinNum > 99 then
        return { 
            'ERROR',
            'You can only set the min players count between 0 and 99!'
        }
    end

    self.m_MinPlayersToStart = s_MinNum
    NetEvents:BroadcastLocal(PlayerEvents.MinPlayersToStartChanged, s_MinNum)

	return { 
        'OK',
        'Min players count set!'
    }
end


-- =============================================
-- Custom functions
-- =============================================

function VuBattleRoyaleServer:DisablePreRound()
    -- Thanks to https://github.com/FlashHit/VU-Mods/blob/master/No-PreRound/ext/Server/__init__.lua
	-- This is for Conquest tickets etc.
	local ticketCounterIterator = EntityManager:GetIterator("ServerTicketCounterEntity")
	
	local ticketCounterEntity = ticketCounterIterator:Next()
	while ticketCounterEntity do
		ticketCounterEntity = Entity(ticketCounterEntity)
		ticketCounterEntity:FireEvent("StartRound")
		ticketCounterEntity = ticketCounterIterator:Next()
	end
	
	-- This is for Rush tickets etc.
	local lifeCounterIterator = EntityManager:GetIterator("ServerLifeCounterEntity")
	local lifeCounterEntity = lifeCounterIterator:Next()
	while lifeCounterEntity do
		lifeCounterEntity = Entity(lifeCounterEntity)
		lifeCounterEntity:FireEvent("StartRound")
		lifeCounterEntity = lifeCounterIterator:Next()
	end
	
	-- This is for TDM tickets etc.
	local killCounterIterator = EntityManager:GetIterator("ServerKillCounterEntity")
	local killCounterEntity = killCounterIterator:Next()
	while killCounterEntity do
		killCounterEntity = Entity(killCounterEntity)
		killCounterEntity:FireEvent("StartRound")
		killCounterEntity = killCounterIterator:Next()
	end
	
	-- This is needed so you are able to move
	local inputRestrictionIterator = EntityManager:GetIterator("ServerInputRestrictionEntity")
	local inputRestrictionEntity = inputRestrictionIterator:Next()
	while inputRestrictionEntity do
		inputRestrictionEntity = Entity(inputRestrictionEntity)
		inputRestrictionEntity:FireEvent("Disable")
		inputRestrictionEntity = inputRestrictionIterator:Next()
	end
	
	-- This Entity is needed so the round ends when tickets are reached
	local roundOverIterator = EntityManager:GetIterator("ServerRoundOverEntity")
	local roundOverEntity = roundOverIterator:Next()
	while roundOverEntity do
		roundOverEntity = Entity(roundOverEntity)
		roundOverEntity:FireEvent("RoundStarted")
		roundOverEntity = roundOverIterator:Next()
	end
	
	-- This EventGate needs to be closed otherwise Attacker can"t win in Rush 
	local eventGateIterator = EntityManager:GetIterator("EventGateEntity")
	local eventGateEntity = eventGateIterator:Next()
	while eventGateEntity do
		eventGateEntity = Entity(eventGateEntity)
		if eventGateEntity.data.instanceGuid == Guid("253BD7C1-920E-46D6-B112-5857D88DAF41") then
			eventGateEntity:FireEvent("Close")
		end
		eventGateEntity = eventGateIterator:Next()
	end
end

function VuBattleRoyaleServer:ChangeGameState(p_GameState)
    if p_GameState < GameStates.None or p_GameState > GameStates.EndGame then
        m_Logger:Error("Attempted to switch to an invalid gamestate.")
        return
    end

    -- Reset tickets for CQL
    TicketManager:SetTicketCount(TeamId.Team1, 999)
    TicketManager:SetTicketCount(TeamId.Team2, 999)

    m_Logger:Write("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])

    local s_OldGameState = self.m_GameState
    self.m_GameState = p_GameState

    self.m_Match:InitMatch()

    -- Broadcast the gamestate changes to the clients 
    NetEvents:Broadcast(PlayerEvents.GameStateChanged, s_OldGameState, p_GameState)
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

function VuBattleRoyaleServer:GetPlayersPitchAndYaw()
    self.m_PlayersPitchAndYaw = {}

    local s_Players = PlayerManager:GetPlayers()
    for _, l_Player in ipairs(s_Players) do
        if l_Player == nil and l_Player.alive == false then
            goto update_allowed_guids_continue
        end

        self.m_PlayersPitchAndYaw[l_Player.id] = {
            Yaw = l_Player.input.authoritativeAimingYaw,
            Pitch = l_Player.input.authoritativeAimingPitch,
            Camera = l_Player.input.authoritativeCameraPosition,
        }

        ::update_allowed_guids_continue::
    end
    
    NetEvents:BroadcastUnreliable(PlayerEvents.PitchAndYaw, self.m_PlayersPitchAndYaw)
end

return VuBattleRoyaleServer()
