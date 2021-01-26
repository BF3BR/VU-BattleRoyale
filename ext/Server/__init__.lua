class "VuBattleRoyaleServer"

require ("__shared/Utils/LevelNameHelper")

require ("__shared/Configs/MapsConfig")
require ("__shared/Configs/ServerConfig")

require ("__shared/Helpers/GameStates")

require ("PhaseManagerServer")

require ("Match")

function VuBattleRoyaleServer:__init()
    -- Extension events
    self.m_ExtensionLoadedEvent = nil
    self.m_ExtensionUnloadedEvent = nil

    -- These are the specific events that are required to kick everything else off
    self.m_ExtensionLoadedEvent = Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
    self.m_ExtensionUnloadedEvent = Events:Subscribe("Extension:Unloaded", self, self.OnExtensionUnloaded)

    -- Holds the gamestate information
    self.m_GameState = GameStates.None

    -- Create a new match
    self.m_Match = Match(self)

    self.m_PhaseManager = PhaseManagerServer()

    -- Sets the custom gamemode name
    ServerUtils:SetCustomGameModeName("Battle Royale")
end

function VuBattleRoyaleServer:OnExtensionLoaded()
    -- Register all of the events
    self:RegisterEvents()
end

function VuBattleRoyaleServer:OnExtensionUnloaded()
    self:UnregisterEvents()
end

function VuBattleRoyaleServer:RegisterEvents()
    -- Engine tick
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    -- Team and Squad management
    self.m_PlayerFindBestSquadHook = Hooks:Install("Player:FindBestSquad", 1, self, self.OnPlayerFindBestSquad)
    self.m_PlayerSelectTeamHook = Hooks:Install("Player:SelectTeam", 1, self, self.OnPlayerSelectTeam)

    -- Damage hook
    self.m_SoldierDamageHook = Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)

    -- Partition events
    self.m_PartitionLoadedEvent = Events:Subscribe("Partition:Loaded", self, self.OnPartitionLoaded)

    -- Custom player connected event, we could send out UI related stuff to the client here
    self.m_PlayerConnectedEvent = NetEvents:Subscribe("VuBattleRoyale:PlayerConnected", self, self.OnPlayerConnected)

    -- Level events
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
end

function VuBattleRoyaleServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    -- Update the match
    self.m_Match:OnEngineUpdate(self.m_GameState, p_DeltaTime)

    local s_PlayerCount = PlayerManager:GetPlayerCount()
    if self.m_GameState == GameStates.None and s_PlayerCount >= ServerConfig.MinPlayersToStart then
        self:ChangeGameState(GameStates.Warmup)
    end
end

function VuBattleRoyaleServer:OnPlayerFindBestSquad(p_Hook, p_Player)
    -- TODO
end

function VuBattleRoyaleServer:OnPlayerSelectTeam(p_Hook, p_Player, p_Team)
    -- TODO
    -- p_Team is R/W
    -- p_Player is RO
end

function VuBattleRoyaleServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
    if p_Soldier == nil or p_Info == nil then
        return
    end

    -- If we are in warmup we should disable all damages
    if self.m_GameState == GameStates.None or self.m_GameState == GameStates.Warmup then
        if p_GiverInfo.giver == nil then --or p_GiverInfo.damageType == DamageType.Suicide
            return
        end

        p_Info.damage = 0.0
        p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
    end
    if p_GiverInfo == nil or p_GiverInfo.giver == nil or p_Soldier.player == nil then
        return	
    end
    if p_GiverInfo.giver.teamId ~= p_Soldier.player.teamId or p_GiverInfo.giver.squadId ~= p_Soldier.player.squadId then
        NetEvents:SendToLocal('ConfirmHit', p_GiverInfo.giver, p_Info.damage)
        if p_Soldier.health <= p_Info.damage then
            if p_Soldier.isInteractiveManDown == false then
                NetEvents:SendToLocal('ConfirmPlayerDown', p_GiverInfo.giver, p_Soldier.player.name)
            else
                p_Soldier:ForceDead()
                NetEvents:SendToLocal('ConfirmPlayerKill', p_GiverInfo.giver, p_Soldier.player.name)
            end
        end
    else
        p_Info.damage = 0.0
        p_Hook:Pass(p_Soldier, p_Info, p_GiverInfo)
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

    -- Spawn player if the current gamestate is warmup
    if self.m_GameState == GameStates.Warmup or self.m_GameState == GameStates.None then
        self.m_Match:SpawnWarmupPlayer(p_Player)
    end
end

function VuBattleRoyaleServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
    self:DisablePreRound()
    self:SetupRconVariables()
end

function VuBattleRoyaleServer:DisablePreRound()
    -- Tahnks to https://github.com/FlashHit/VU-Mods/blob/master/No-PreRound/ext/Server/__init__.lua
	-- This is for Conquest tickets etc.
	local ticketCounterIterator = EntityManager:GetIterator("ServerTicketCounterEntity")
	
	local ticketCounterEntity = ticketCounterIterator:Next()
	while ticketCounterEntity do

		ticketCounterEntity = Entity(ticketCounterEntity)
		ticketCounterEntity:FireEvent('StartRound')
		ticketCounterEntity = ticketCounterIterator:Next()
	end
	
	-- This is for Rush tickets etc.
	local lifeCounterIterator = EntityManager:GetIterator("ServerLifeCounterEntity")
	
	local lifeCounterEntity = lifeCounterIterator:Next()
	while lifeCounterEntity do

		lifeCounterEntity = Entity(lifeCounterEntity)
		lifeCounterEntity:FireEvent('StartRound')
		lifeCounterEntity = lifeCounterIterator:Next()
	end
	
	-- This is for TDM tickets etc.
	local killCounterIterator = EntityManager:GetIterator("ServerKillCounterEntity")
	
	local killCounterEntity = killCounterIterator:Next()
	while killCounterEntity do

		killCounterEntity = Entity(killCounterEntity)
		killCounterEntity:FireEvent('StartRound')
		killCounterEntity = killCounterIterator:Next()
	end
	
	-- This is needed so you are able to move
	local inputRestrictionIterator = EntityManager:GetIterator("ServerInputRestrictionEntity")
	
	local inputRestrictionEntity = inputRestrictionIterator:Next()
	while inputRestrictionEntity do

		inputRestrictionEntity = Entity(inputRestrictionEntity)
		inputRestrictionEntity:FireEvent('Disable')
		
		inputRestrictionEntity = inputRestrictionIterator:Next()
	end
	
	-- This Entity is needed so the round ends when tickets are reached
	local roundOverIterator = EntityManager:GetIterator("ServerRoundOverEntity")
	
	local roundOverEntity = roundOverIterator:Next()
	while roundOverEntity do

		roundOverEntity = Entity(roundOverEntity)
		roundOverEntity:FireEvent('RoundStarted')
		
		roundOverEntity = roundOverIterator:Next()
	end
	
	-- This EventGate needs to be closed otherwise Attacker can't win in Rush 
	local eventGateIterator = EntityManager:GetIterator("EventGateEntity")
	
	local eventGateEntity = eventGateIterator:Next()
	while eventGateEntity do

		eventGateEntity = Entity(eventGateEntity)
		if eventGateEntity.data.instanceGuid == Guid('253BD7C1-920E-46D6-B112-5857D88DAF41') then
			eventGateEntity:FireEvent('Close')
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

    -- Reset tickets for TDM
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
        ["vars.miniMap"] = "true",
        ["vars.autoBalance"] = "false",
        ["vars.teamKillCountForKick"] = "0",
        ["vars.teamKillValueForKick"] = "0",
        ["vars.teamKillValueIncrease"] = "0",
        ["vars.teamKillValueDecreasePerSecond"] = "0",
        ["vars.idleTimeout"] = "300",
        ["vars.3pCam"] = "false",
        ["vars.killCam"] = "false",
        ["vars.roundStartPlayerCount"] = "0",
        ["vars.roundRestartPlayerCount"] = "0",
        ["vars.hud"] = "true",
        ["vu.SquadSize"] = "4",
        ["vu.ColorCorrectionEnabled"] = "false",
        ["vu.SunFlareEnabled"] = "false",
        ["vu.SuppressionMultiplier"] = "0",
        ["vu.DestructionEnabled"] = "false",
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

return VuBattleRoyaleServer()
