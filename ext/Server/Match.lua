class "Match"

require "__shared/Configs/MapsConfig"
require "__shared/Configs/ServerConfig"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"
require "__shared/Utils/Timers"
require "__shared/Utils/LevelNameHelper"

require "Gunship"
require "Airdrop"
require "PhaseManagerServer"

local m_LootManager = require("LootManagerServer")

function Match:__init(p_Server, p_TeamManager)
    -- Save server reference
    self.m_Server = p_Server

    -- Save team manager reference
    self.m_TeamManager = p_TeamManager

    -- Gamestates
    self.m_CurrentState = GameStates.None
    self.m_LastState = GameStates.None

    -- Winner
    self.m_WinnerTeam = nil

    -- Gunship
    self.m_Gunship = Gunship(self, self.m_TeamManager)

    -- Airdrop
    self.m_Airdrop = Airdrop(self)
    self.m_AirdropTimer = 0.0
    self.m_AirdropNextDrop = nil

    -- PhaseManagerServer
    self.m_PhaseManager = PhaseManagerServer()

    self.m_RestartQueue = false

    self.m_IsFadeOutSet = false

    self.m_CurrentTimer = nil
    self:InitMatch()
end

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
    self.m_Gunship:OnEngineUpdate(p_DeltaTime)
    self.m_Airdrop:OnEngineUpdate(p_DeltaTime)

    if self.m_CurrentState ~= p_GameState then
        self.m_LastState = self.m_CurrentState
    end

    self.m_CurrentState = p_GameState

    if self.m_CurrentState == Gamestates.Match then
        self:AirdropManager(p_DeltaTime)
    end
end

function Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
    if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
        if self.m_RestartQueue then
            print("INFO: Restart triggered.")

            local s_Result = RCON:SendCommand("mapList.restartRound")
            if #s_Result >= 1 then
                if s_Result[1] ~= "OK" then
                    print("INFO: Command: mapList.restartRound returned: " .. s_Result[1])
                end
            end
            
            self.m_RestartQueue = false
        end
    end
end


-- =============================================
-- Match Logic
-- =============================================

function Match:InitMatch()
    self:RemoveTimer("WhileMatchState")
    self:RemoveTimer("NextMatchState")
    self:RemoveTimer("RemoveGunship")

    self.m_CurrentTimer = nil

    self:SetTimer("WhileMatchState", g_Timers:Interval(1, self, self.OnMatchEveryTick))

    self:OnMatchFirstTick()

    -- start the timer for the next match state
    local s_Delay = ServerConfig.MatchStateTimes[self.m_CurrentState]
    if s_Delay ~= nil then
        self.m_CurrentTimer = self:SetTimer("NextMatchState", g_Timers:Timeout(s_Delay, self, self.NextMatchState))
    end
end

function Match:NextMatchState()
    -- check if it reached the end of the matchstates
    if self.m_CurrentState ~= GameStates.None and self.m_CurrentState >= GameStates.EndGame then
        return false
    end

    self:OnMatchLastTick()

    -- increment gamestate
    self.m_Server:ChangeGameState(self.m_CurrentState + 1)
    self:InitMatch()
    return true
end

function Match:OnMatchEveryTick()
    if self.m_CurrentTimer == nil then
        return
    end

    if self.m_CurrentState == GameStates.Warmup then
        if self.m_CurrentTimer:Remaining() <= 2.0 and not self.m_IsFadeOutSet then
            self.m_IsFadeOutSet = true
            PlayerManager:FadeOutAll(2.0)
        end
    elseif self.m_CurrentState == Gamestates.Match then
        self:DoWeHaveAWinner()
    end
end

function Match:OnMatchFirstTick()
    if self.m_CurrentState == GameStates.WarmupToPlane then
        -- Fade out then unspawn all soldiers
        self.m_TeamManager:UnspawnAllSoldiers()

        -- Assign all players to teams
        self.m_TeamManager:AssignTeams()

        -- Enable regular pickups
        m_LootManager:EnableMatchPickups()
    elseif self.m_CurrentState == GameStates.Plane then
        -- Spawn the gunship and set its course
        self.m_Gunship:Spawn(self:GetRandomGunshipStart(), true)

        -- Fade in all the players
        PlayerManager:FadeInAll(2.0)
        self.m_IsFadeOutSet = false
    elseif self.m_CurrentState == Gamestates.Match then
        -- Remove gunship after a short delay
        self:SetTimer("RemoveGunship", g_Timers:Timeout(ServerConfig.GunshipDespawn, self, self.OnRemoveGunship))
    elseif self.m_CurrentState == Gamestates.EndGame then
        self.m_PhaseManager:End()
        self.m_Gunship:Spawn(nil, false)
        self.m_Airdrop:Spawn(nil, false)

        if self.m_WinnerTeam ~= nil then
            print("INFO: We have a winner team: " .. self.m_WinnerTeam.m_Id)
        else
            print("INFO: Round ended without a winner.")
        end
    end
end

function Match:OnMatchLastTick()
    if self.m_CurrentState == Gamestates.Plane then
        NetEvents:BroadcastLocal(GunshipEvents.ForceJumpOut)
    elseif self.m_CurrentState == Gamestates.PlaneToFirstCircle then
        self.m_PhaseManager:Start()
    elseif self.m_CurrentState == Gamestates.EndGame then
        self.m_RestartQueue = true
    end
end

function Match:OnRemoveGunship()
    if self.m_Gunship:GetEnabled() then
        self.m_Gunship:Spawn(nil, false)
    end
end

function Match:OnRestartRound()
    self.m_RestartQueue = false
    self.m_WinnerTeam = nil
    self.m_Server:ChangeGameState(GameStates.None)
end


-- =============================================
-- Other functions
-- =============================================

function Match:GetRandomWarmupSpawnpoint()
    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return nil
    end
    
    local s_SpawnTrans = nil;
    s_SpawnTrans = MapsConfig[s_LevelName]["WarmupSpawnPoints"][ math.random( #MapsConfig[s_LevelName]["WarmupSpawnPoints"] ) ]

    return s_SpawnTrans
end

function Match:GetRandomGunshipStart()
    local s_LevelName = LevelNameHelper:GetLevelName()
    if s_LevelName == nil then
        return nil
    end

    local s_Center = Vec3(
        MapsConfig[s_LevelName]["MapTopLeftPos"].x - 1250 / 2 + MathUtils:GetRandom(-200, 200), 
        555, 
        MapsConfig[s_LevelName]["MapTopLeftPos"].z - 1250 / 2 + MathUtils:GetRandom(-200, 200)
    )

    local s_OffsetAngle = s_Center:Clone()
    s_OffsetAngle.x = s_OffsetAngle.x + MathUtils:GetRandom(-1250, 1250)
    s_OffsetAngle.z = s_OffsetAngle.z + MathUtils:GetRandom(-1250, 1250)

    local s_Return = LinearTransform()
    s_Return:LookAtTransform(s_Center, s_OffsetAngle)

    s_Return.trans.x = s_Return.trans.x - s_Return.forward.x * 750
    s_Return.trans.z = s_Return.trans.z - s_Return.forward.z * 750

    return s_Return
end

function Match:SetClientTimer(p_Time)
    if p_Time == nil then
        return
    end

    NetEvents:Broadcast(PlayerEvents.UpdateTimer, p_Time)
end

function Match:AirdropManager(p_DeltaTime)
    if self.m_Airdrop:GetEnabled() then
        self.m_AirdropTimer = self.m_AirdropTimer + p_DeltaTime

        -- Remove the airdrop plane after 120 sec
        if self.m_AirdropTimer >= 120.0 then
            print("INFO: Airdrop unspawned")
            self.m_AirdropTimer = 0.0
            self.m_Airdrop:Spawn(nil, false, nil)
        end
    end

    if self.m_AirdropNextDrop == nil then
        self.m_AirdropNextDrop = MathUtils:GetRandom(30, 180)
    end

    self.m_AirdropTimer = self.m_AirdropTimer + p_DeltaTime
    if self.m_AirdropTimer >= self.m_AirdropNextDrop then
        self.m_AirdropNextDrop = nil
        self.m_AirdropTimer = 0.0

        if not self.m_Airdrop:GetEnabled() then
            print("INFO: Airdrop spawned")
            self.m_Airdrop:Spawn(self:GetRandomGunshipStart(), true, MathUtils:GetRandom(20, 60))
        end
    end
end

function Match:DoWeHaveAWinner()
    if PlayerManager:GetPlayerCount() == 0 then
        self.m_Server:ChangeGameState(GameStates.EndGame)
        return
    end

    local s_WinningTeam = nil
    if ServerConfig.Debug.EnableWinningCheck then
        s_WinningTeam = self.m_TeamManager:GetWinningTeam()
    end

    if s_WinningTeam ~= nil then
        print(s_WinningTeam.m_Id)
        self.m_WinnerTeam = s_WinningTeam
        self.m_Server:ChangeGameState(GameStates.EndGame)
    end
end

if g_Match == nil then
	g_Match = Match()
end

return g_Match
