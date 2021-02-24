class "VuBattleRoyaleServer"

require "__shared/Helpers/LevelNameHelper"
require "__shared/Configs/MapsConfig"
require "__shared/Configs/ServerConfig"
require "__shared/Enums/GameStates"
require "BRTeamManager"
require "Match"
require "Whitelist"
require "PingServer"

function VuBattleRoyaleServer:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    -- Holds the gamestate information
    self.m_GameState = GameStates.None

    self.m_PlayersPitchAndYaw = { }

    self.m_WaitForStart = true

    self.m_TeamManager = g_BRTeamManager

    -- Create a new match
    self.m_Match = Match(self, self.m_TeamManager)

    -- Server sided pinging system
    self.m_Ping = PingServer()

    -- Sets the custom gamemode name
    ServerUtils:SetCustomGameModeName("Baguette")
end

function VuBattleRoyaleServer:OnExtensionLoaded()
    self:RegisterEvents()
    self:RegisterHooks()
end

function VuBattleRoyaleServer:OnExtensionUnloaded()
    self:UnregisterEvents()
    self:UnregisterHooks()
end

function VuBattleRoyaleServer:RegisterEvents()
    -- Engine tick
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    -- Partition events
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)

    -- Custom player connected event, we could send out UI related stuff to the client here
    self.m_PlayerConnectedEvent = NetEvents:Subscribe("VuBattleRoyale:PlayerConnected", self, self.OnPlayerConnected)
    self.m_PlayerDeployEvent = NetEvents:Subscribe("VuBattleRoyale:PlayerDeploy", self, self.OnPlayerDeploy)

    -- Level events
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    self.m_LevelDestroyEvent = Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)

    -- UpdateManager events
    self.m_UpdateManagerUpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)

    -- InteractiveManDown revived event
    self.m_ManDownRevivedEvent = Events:Subscribe("Player:ManDownRevived", self, self.OnManDownRevived)
end

function VuBattleRoyaleServer:UnregisterEvents()
    
end

function VuBattleRoyaleServer:RegisterHooks()
    -- Damage hook
    -- self.m_SoldierDamageHook = Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
end

function VuBattleRoyaleServer:UnregisterHooks()
    
end

function VuBattleRoyaleServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    if not self.m_WaitForStart then
        -- Update the match
        self.m_Match:OnEngineUpdate(self.m_GameState, p_DeltaTime)

        -- Update the players pitch and yaw table
        self:GetPlayersPitchAndYaw()

        local s_PlayerCount = 0

        local s_Players = PlayerManager:GetPlayers()
        for l_Index, l_Player in ipairs(s_Players) do
            if l_Player == nil and l_Player.alive == false then
                goto update_allowed_guids_continue
            end
    
            s_PlayerCount = s_PlayerCount + 1
    
            ::update_allowed_guids_continue::
        end

        if self.m_GameState == GameStates.None and s_PlayerCount >= ServerConfig.MinPlayersToStart then
            self:ChangeGameState(GameStates.Warmup)
        end
    end
end

function VuBattleRoyaleServer:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    -- Update the match
    self.m_Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
end

function VuBattleRoyaleServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
    if p_Soldier == nil or p_Info == nil then
        return
    end

    -- If we are in warmup we should disable all damages
    if self.m_GameState == GameStates.None or self.m_GameState == GameStates.Warmup or self.m_GameState == GameStates.WarmupToPlane then
        if p_GiverInfo.giver == nil then --or p_GiverInfo.damageType == DamageType.Suicide
            return
        end

        p_Info.damage = 0.0
        p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
        return
    end

    if p_Soldier.player == nil then
        return
    end
    
    if p_GiverInfo == nil or p_GiverInfo.giver == nil then
        self:LeftOverDamageOnManDown(p_Soldier, p_Info.damage, p_GiverInfo)
        if p_Soldier.health <= p_Info.damage then
            p_Soldier:ForceDead()
        end
        return	
    end
    if p_GiverInfo.giver.teamId ~= p_Soldier.player.teamId or p_GiverInfo.giver.squadId ~= p_Soldier.player.squadId then
        NetEvents:SendToLocal("ConfirmHit", p_GiverInfo.giver, p_Info.damage)
        if p_Soldier.health <= p_Info.damage then
            NetEvents:SendToLocal("ConfirmPlayerKill", p_GiverInfo.giver, p_Soldier.player.name)
            p_Soldier:ForceDead()
        elseif (p_Soldier.health - 100) <= p_Info.damage and p_Soldier.isInteractiveManDown == false then
            self:LeftOverDamageOnManDown(p_Soldier, p_Info.damage, p_GiverInfo)
            NetEvents:SendToLocal("ConfirmPlayerDown", p_GiverInfo.giver, p_Soldier.player.name)
        end
    elseif p_GiverInfo.giver ~= p_Soldier.player then
        p_Info.damage = 0.0
        p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
    else
        self:LeftOverDamageOnManDown(p_Soldier, p_Info.damage, p_GiverInfo)
    end
end

function VuBattleRoyaleServer:LeftOverDamageOnManDown(p_Soldier, p_Damage, p_GiverInfo)
    if (p_Soldier.health - 100) <= p_Damage and p_Soldier.isInteractiveManDown == false then
        local s_PlayerName = p_Soldier.player.name
        local s_Damage = p_Damage - p_Soldier.health + 100
        local s_Table = {s_PlayerName, s_Damage}
        g_Timers:Timeout(0.1, s_Table, function(p_Table)
            local s_Player = PlayerManager:GetPlayerByName(p_Table[1])
            if s_Player == nil or s_Player.soldier == nil then
                return
            end
            if p_Soldier.health > p_Damage then
                s_Player.soldier.health = s_Player.soldier.health - p_Table[2]
            else
                s_Player.soldier.health = 0
            end
        end)
    end
end

function VuBattleRoyaleServer:OnManDownRevived(p_Player, p_Reviver, p_IsAdrenalineRevive)
    if p_Reviver ~= nil then
        p_Player.soldier.health = 130
    else
        p_Player.soldier.health = 0.0001
    end
end

function VuBattleRoyaleServer:OnPartitionLoaded(p_Partition)
    if p_Partition == nil then
        return
    end

    -- We might need this
end

function VuBattleRoyaleServer:OnPlayerConnected(p_Player)
    if p_Player == nil then
        return
    end

    -- TODO: Update the connected clients UI

    -- Send out gamestate information if he connects or reconnects
    NetEvents:SendTo("VuBattleRoyale:GameStateChanged", p_Player, GameStates.None, self.m_GameState)

    -- TODO: Send out the timer if its mid round

    -- Fade in the default (showroom) camera
    p_Player:Fade(1.0, false)
end

function VuBattleRoyaleServer:OnPlayerDeploy(p_Player)
    if p_Player == nil then
        return
    end

    -- Spawn player if the current gamestate is warmup
    if self.m_GameState == GameStates.Warmup or self.m_GameState == GameStates.None then
        self.m_Match:SpawnWarmupPlayer(p_Player)
    end
end

function VuBattleRoyaleServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self:DisablePreRound()
    self:SetupRconVariables()

    self.m_WaitForStart = false
end

function VuBattleRoyaleServer:OnLevelDestroy()
    -- Reset the match
    self.m_Match:OnRestartRound()

    self.m_WaitForStart = true
end

function VuBattleRoyaleServer:DisablePreRound()
    -- Tahnks to https://github.com/FlashHit/VU-Mods/blob/master/No-PreRound/ext/Server/__init__.lua
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


-- ==========
-- Not event related functions
-- ==========

function VuBattleRoyaleServer:ChangeGameState(p_GameState)
    if p_GameState < GameStates.None or p_GameState > GameStates.EndGame then
        print("ERROR: Attempted to switch to an invalid gamestate.")
        return
    end

    -- Reset tickets for CQL
    TicketManager:SetTicketCount(TeamId.Team1, 999)
    TicketManager:SetTicketCount(TeamId.Team2, 999)

    print("INFO: Transitioning from " .. GameStatesStrings[self.m_GameState] .. " to " .. GameStatesStrings[p_GameState])

    local s_OldGameState = self.m_GameState
    self.m_GameState = p_GameState

    -- Broadcast the gamestate changes to the clients 
    NetEvents:Broadcast("VuBattleRoyale:GameStateChanged", s_OldGameState, p_GameState)
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
                print("INFO: Command: " .. l_Command .. " returned: " .. s_Result[1])
            end
        end
    end
end

function VuBattleRoyaleServer:GetPlayersPitchAndYaw()
    self.m_PlayersPitchAndYaw = { }

    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
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
    
    NetEvents:BroadcastUnreliable("VuBattleRoyale:PlayersPitchAndYaw", self.m_PlayersPitchAndYaw)
end

return VuBattleRoyaleServer()
