local Match = class("Match")

require ("__shared/Utils/LevelNameHelper")

require ("__shared/Configs/MapsConfig")
require ("__shared/Configs/ServerConfig")

require ("__shared/Utils/LevelNameHelper")
require ("__shared/Helpers/GameStates")

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


-- ==========
-- Match Logic
-- ==========

function Match:OnWarmup(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Warmup] == 0.0 then
        -- TODO: Set the client timer
        -- self.m_Server:SetClientTimer(ServerConfig.WarmupTime)
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

        -- Kill all players and disable their ability to spawn
        -- TODO: self:KillAllPlayers(false)
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

        -- TODO: Spawn the plane, set the camera for players and enable players to jump out
    end

    self:DoWeHaveAWinner()

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

    self:DoWeHaveAWinner()

    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return
    end

    if self.m_UpdateTicks[GameStates.PlaneToFirstCircle] >= MapsConfig[s_LevelName]["BeforeFirstCircleDelay"] then
        self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
        self.m_Server:ChangeGameState(GameStates.Match)
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

    if self.m_UpdateTicks[GameStates.Match] >= MapsConfig[s_LevelName]["Circles"][self.m_CircleIndex]["StartsAt"] then
        -- TODO: Update the ring state
        return
    end

    local s_StartToEnd = MapsConfig[s_LevelName]["Circles"][self.m_CircleIndex]["StartsAt"] + MapsConfig[s_LevelName]["Circles"][self.m_CircleIndex]["EndsAt"]
    if self.m_UpdateTicks[GameStates.Match] >= s_StartToEnd then
        if self.m_CircleIndex < MapsConfig[s_LevelName]["CirclesCount"] then
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
        -- TODO: Reset the clients UI

        -- Reset
        self.m_UpdateTicks[GameStates.None] = 0.0
        self.m_UpdateTicks[GameStates.Warmup] = 0.0
        self.m_UpdateTicks[GameStates.WarmupToPlane] = 0.0
        self.m_UpdateTicks[GameStates.Plane] = 0.0
        self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
        self.m_UpdateTicks[GameStates.Match] = 0.0
        self.m_UpdateTicks[GameStates.EndGame] = 0.0
        self.m_CircleIndex = 1
        self.m_Winner = nil

        self.m_Server:ChangeGameState(GameStates.None)
        return
    end

    self.m_UpdateTicks[GameStates.EndGame] = self.m_UpdateTicks[GameStates.EndGame] + p_DeltaTime
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

    if s_AlivePlayersCount <= 1 and s_Winner ~= nil then
        self.m_Winner = s_Winner
        self.m_Server:ChangeGameState(GameStates.EndGame)
    end
end


return Match
