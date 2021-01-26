local Match = class("Match")

require ("__shared/Utils/LevelNameHelper")
require ("__shared/Utils/TableHelper")

require ("__shared/Configs/MapsConfig")
require ("__shared/Configs/ServerConfig")

require ("__shared/Helpers/GameStates")

require ("Gunship")
require ("PhaseManagerServer")

function Match:__init(p_Server)
    -- Save server reference
    self.m_Server = p_Server

    -- Gamestates
    self.m_CurrentState = GameStates.None
    self.m_LastState = GameStates.None

    -- State callbacks
    self.m_UpdateStates = { }
    self.m_UpdateStates[GameStates.Warmup] = self.OnWarmup
    self.m_UpdateStates[GameStates.WarmupToPlane] = self.OnWarmupToPlane
    self.m_UpdateStates[GameStates.Plane] = self.OnPlane
    self.m_UpdateStates[GameStates.PlaneToFirstCircle] = self.OnPlaneToFirstCircle
    self.m_UpdateStates[GameStates.Match] = self.OnMatch
    self.m_UpdateStates[GameStates.EndGame] = self.OnEndGame

    -- State ticks
    self.m_UpdateTicks = { }
    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.WarmupToPlane] = 0.0
    self.m_UpdateTicks[GameStates.Plane] = 0.0
    self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
    self.m_UpdateTicks[GameStates.Match] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0

    -- Circle index
    self.m_CircleIndex = 1

    -- Winner
    self.m_Winner = nil

    -- Gunship
    self.m_Gunship = Gunship(self)

    -- PhaseManagerServer
    self.m_PhaseManager = PhaseManagerServer()

    self.m_RestartQueue = false

    self.m_IsFadeOutSet = false
end


-- ==========
-- Logic Update Callbacks
-- ==========

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
    local s_Callback = self.m_UpdateStates[p_GameState]
    if s_Callback == nil then
        return
    end

    if self.m_CurrentState ~= p_GameState then
        self.m_LastState = self.m_CurrentState
    end

    self.m_CurrentState = p_GameState

    s_Callback(self, p_DeltaTime)
end

function Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
        if self.m_RestartQueue then
            print('INFO: Restart triggered.')
            local s_Rcon = RCON:SendCommand('mapList.restartRound')
            self.m_RestartQueue = false
        end
    end
end

-- ==========
-- Match Logic
-- ==========

function Match:OnWarmup(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Warmup] == 0.0 then
        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.WarmupTime)
    end

    
    if self.m_UpdateTicks[GameStates.Warmup] >= ServerConfig.WarmupTime - 2.0 and not self.m_IsFadeOutSet then
        self.m_IsFadeOutSet = true
        PlayerManager:FadeOutAll(2.0)
    end

    if self.m_UpdateTicks[GameStates.Warmup] >= ServerConfig.WarmupTime then
        self.m_UpdateTicks[GameStates.Warmup] = 0.0

        -- If the warmup timer is over we should transition to WarmupToPlane state
        self.m_Server:ChangeGameState(GameStates.WarmupToPlane)
        return
    end

    self.m_UpdateTicks[GameStates.Warmup] = self.m_UpdateTicks[GameStates.Warmup] + p_DeltaTime
end

function Match:OnWarmupToPlane(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.WarmupToPlane] == 0.0 then
        -- TODO: Set the client timer
        --self.m_Server:SetClientTimer(ServerConfig.WarmupToPlaneTime)

        -- Fade out then kill all the players
        self:UnspawnAllSoldiers()
    end

    if self.m_UpdateTicks[GameStates.WarmupToPlane] >= ServerConfig.WarmupToPlaneTime then
        self.m_UpdateTicks[GameStates.WarmupToPlane] = 0.0
        self.m_Server:ChangeGameState(GameStates.Plane)
        return
    end

    self.m_UpdateTicks[GameStates.WarmupToPlane] = self.m_UpdateTicks[GameStates.WarmupToPlane] + p_DeltaTime
end

function Match:OnPlane(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Plane] == 0.0 then
        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.PlaneTime)

        self.m_Gunship:Spawn()
        PlayerManager:FadeInAll(2.0)
        self.m_IsFadeOutSet = false
    end

    if self.m_UpdateTicks[GameStates.Plane] >= ServerConfig.PlaneTime then
        self.m_UpdateTicks[GameStates.Plane] = 0.0
        self.m_Server:ChangeGameState(GameStates.PlaneToFirstCircle)
        return
    end

    self.m_UpdateTicks[GameStates.Plane] = self.m_UpdateTicks[GameStates.Plane] + p_DeltaTime
end

function Match:OnPlaneToFirstCircle(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.PlaneToFirstCircle] == 0.0 then
        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.PlaneTime)
    end

    -- No delay needed, Phase Manager solves all of our problems
    if self.m_UpdateTicks[GameStates.PlaneToFirstCircle] >= 0.0 then
        self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
        self.m_Server:ChangeGameState(GameStates.Match)

        -- Start the Circle of Death
        self.m_PhaseManager:Start()

        return
    end

    self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = self.m_UpdateTicks[GameStates.PlaneToFirstCircle] + p_DeltaTime
end

function Match:OnMatch(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Match] == 0.0 then
        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.PlaneTime)
    end

    self:DoWeHaveAWinner()

    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return
    end

    if self.m_UpdateTicks[GameStates.Match] >= MapsConfig[s_LevelName]["Phases"][self.m_CircleIndex]["StartsAt"] then
        -- TODO: Update the ring state
        -- Not needed, Phase Manager solves all of our problems
        return
    end

    local s_StartToEnd = MapsConfig[s_LevelName]["Phases"][self.m_CircleIndex]["StartsAt"] + MapsConfig[s_LevelName]["Phases"][self.m_CircleIndex]["MoveDuration"]
    if self.m_UpdateTicks[GameStates.Match] >= s_StartToEnd then
        if self.m_CircleIndex < MapsConfig[s_LevelName]["PhasesCount"] then
            print("INFO: Circle stopped shrinking")
            self.m_UpdateTicks[GameStates.Match] = 0.0

            self.m_CircleIndex = self.m_CircleIndex + 1
        end
        return
    end

    self.m_UpdateTicks[GameStates.Match] = self.m_UpdateTicks[GameStates.Match] + p_DeltaTime
end

function Match:OnEndGame(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.EndGame] == 0.0 then
        -- End the Circle of Death
        self.m_PhaseManager:End()

        if self.m_Winner ~= nil then
            print('INFO: We have a winner: ' .. self.m_Winner.name)
        else
            print('INFO: Round ended without a winner.')
        end
        

        -- TODO: Set client UI to show the winners name

        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.EndGameTime)
    end

    if self.m_UpdateTicks[GameStates.EndGame] >= ServerConfig.EndGameTime then
        self.m_UpdateTicks[GameStates.EndGame] = 0.0

        -- Queue round reset
        self.m_RestartQueue = true

        return
    end

    self.m_UpdateTicks[GameStates.EndGame] = self.m_UpdateTicks[GameStates.EndGame] + p_DeltaTime
end

function Match:OnRestartRound()
    self.m_RestartQueue = false

    self.m_UpdateTicks[GameStates.None] = 0.0
    self.m_UpdateTicks[GameStates.Warmup] = 0.0
    self.m_UpdateTicks[GameStates.WarmupToPlane] = 0.0
    self.m_UpdateTicks[GameStates.Plane] = 0.0
    self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
    self.m_UpdateTicks[GameStates.Match] = 0.0
    self.m_UpdateTicks[GameStates.EndGame] = 0.0
    self.m_CircleIndex = 1
    self.m_Winner = nil

    self:Cleanup()

    self.m_Server:ChangeGameState(GameStates.None)
end

-- ==========
-- Other functions
-- ==========

function Match:DoWeHaveAWinner()
    local s_AlivePlayersCount = 0
    local s_Winner = nil

    if PlayerManager:GetPlayerCount() == 0 then
        self.m_Server:ChangeGameState(GameStates.EndGame)
        return
    end

    -- TODO: FIXME: This only works for solo gamemode
    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        if l_Player == nil then
            goto _on_loop_continue_
        end

        if l_Player.alive then
            s_AlivePlayersCount = s_AlivePlayersCount + 1
            s_Winner = l_Player
        end

        ::_on_loop_continue_::
    end

    self.m_Winner = s_Winner

    if s_AlivePlayersCount <= 1 then
        self.m_Server:ChangeGameState(GameStates.EndGame)
    end
end

function Match:SpawnWarmupAllPlayers()
    self:UnspawnAllSoldiers()
    
    local s_Players = PlayerManager:GetPlayers()
    for l_Index, l_Player in ipairs(s_Players) do
        -- Validate our player
        if l_Player == nil then
            goto _spawn_all_players_continue_
        end

        self:SpawnWarmupPlayer(l_Player)

        ::_spawn_all_players_continue_::
    end
end

function Match:SpawnWarmupPlayer(p_Player)
    if p_Player == nil then
        return
    end

    local s_SpawnTrans = self:GetRandomWarmupSpawnpoint(p_Player)
    if s_SpawnTrans == nil then
        print('ERROR: (Warmup) Coulnd\'t spawn player: ' .. p_Player.name)
        return
    end

    self:SpawnPlayer(p_Player, s_SpawnTrans)
end

function Match:SpawnPlayer(p_Player, p_Transform)
    if p_Player == nil then
        return
    end

    if p_Player.alive then
        return
    end

    print('INFO: Spawning player: ' .. p_Player.name)

    local s_SoldierAsset = nil
    local s_Appearance = nil
    local s_SoldierBlueprint = ResourceManager:SearchForDataContainer('Characters/Soldiers/MpSoldier')

    if p_Player.teamId == TeamId.Team1 then
        s_SoldierAsset = ResourceManager:SearchForDataContainer('Gameplay/Kits/USAssault')
        s_Appearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/Us/MP_US_Assault_Appearance_Wood01')
    elseif p_Player.teamId == TeamId.Team2 then
        s_SoldierAsset = ResourceManager:SearchForDataContainer('Gameplay/Kits/RUAssault')
        s_Appearance = ResourceManager:SearchForDataContainer('Persistence/Unlocks/Soldiers/Visual/MP/RU/MP_RU_Assault_Appearance_Wood01')
    end

    if s_SoldierAsset == nil or s_Appearance == nil or s_SoldierBlueprint == nil then
        return
    end

    -- Spawn the player with only a knife
    local s_Knife = ResourceManager:SearchForDataContainer('Weapons/Knife/U_Knife')
    p_Player:SelectWeapon(WeaponSlot.WeaponSlot_0, s_Knife, {})
    p_Player:SelectWeapon(WeaponSlot.WeaponSlot_7, s_Knife, {})

    p_Player:SelectUnlockAssets(s_SoldierAsset, { s_Appearance })

    local s_SpawnedSoldier = p_Player:CreateSoldier(s_SoldierBlueprint, p_Transform)

	p_Player:SpawnSoldierAt(s_SpawnedSoldier, p_Transform, CharacterPoseType.CharacterPoseType_Stand)
	p_Player:AttachSoldier(s_SpawnedSoldier)

    return s_SpawnedSoldier
end

function Match:GetRandomWarmupSpawnpoint(p_Player)
    if p_Player == nil then
        return nil
    end

    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return nil
    end
    
    local s_SpawnTrans = nil;
    s_SpawnTrans = MapsConfig[s_LevelName]["WarmupSpawnPoints"][ math.random( #MapsConfig[s_LevelName]["WarmupSpawnPoints"] ) ]

    return s_SpawnTrans
end

function Match:Cleanup()
    self:CleanupSpecificEntity("ServerPickupEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientPickupEntity")

    self:CleanupSpecificEntity("ServerMedicBagEntity")
    self:CleanupSpecificEntity("ServerMedicBagHealingSphereEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientMedicBagEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientMedicBagHealingSphereEntity")

    self:CleanupSpecificEntity("ServerSupplySphereEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientSupplySphereEntity")

    self:CleanupSpecificEntity("ServerExplosionEntity")
    self:CleanupSpecificEntity("ServerExplosionPackEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientExplosionEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientExplosionPackEntity")

    self:CleanupSpecificEntity("ServerGrenadeEntity")
    NetEvents:Broadcast("VuBattleRoyale:Cleanup", "ClientGrenadeEntity")
end

function Match:CleanupSpecificEntity(p_EntityType)
    if p_EntityType == nil then
        return
    end

    local s_Entities = {}

    local s_Iterator = EntityManager:GetIterator(p_EntityType)
    local s_Entity = s_Iterator:Next()
    while s_Entity do
        s_Entities[#s_Entities+1] = Entity(s_Entity)
        s_Entity = s_Iterator:Next()
    end

    for _, l_Entity in pairs(s_Entities) do
        if l_Entity ~= nil then
            l_Entity:Destroy()
        end
    end
end

function Match:UnspawnAllSoldiers()
    local s_HumanPlayerEntityIterator = EntityManager:GetIterator("ServerHumanPlayerEntity")
    local s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()
    
    while s_HumanPlayerEntity do
        s_HumanPlayerEntity = Entity(s_HumanPlayerEntity)	
        s_HumanPlayerEntity:FireEvent("UnSpawnAllSoldiers")
        s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()
    end
end

return Match
