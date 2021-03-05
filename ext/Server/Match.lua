local Match = class("Match")

require "__shared/Utils/LevelNameHelper"

require "__shared/Configs/MapsConfig"
require "__shared/Configs/ServerConfig"

require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"

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
end

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
    self.m_Gunship:OnEngineUpdate(p_DeltaTime)
    self.m_Airdrop:OnEngineUpdate(p_DeltaTime)

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

function Match:OnWarmup(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.Warmup] == 0.0 then
        self:SetClientTimer(ServerConfig.WarmupTime)
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
        self:SetClientTimer(ServerConfig.WarmupToPlaneTime)

        -- Fade out then unspawn all soldiers
        self.m_TeamManager:UnspawnAllSoldiers()

        -- Assign all players to teams
        self.m_TeamManager:AssignTeams()

        -- Enable regular pickups
        -- m_LootManager:EnableMatchPickups()
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
        self:SetClientTimer(ServerConfig.PlaneTime)

        self.m_Gunship:Spawn(self:GetRandomGunshipStart(), true)
        PlayerManager:FadeInAll(2.0)
        self.m_IsFadeOutSet = false
    end

    if self.m_UpdateTicks[GameStates.Plane] >= ServerConfig.PlaneTime then
        self.m_UpdateTicks[GameStates.Plane] = 0.0
        NetEvents:BroadcastLocal(GunshipEvents.ForceJumpOut)
        self.m_Server:ChangeGameState(GameStates.PlaneToFirstCircle)
        return
    end

    self.m_UpdateTicks[GameStates.Plane] = self.m_UpdateTicks[GameStates.Plane] + p_DeltaTime
end

function Match:OnPlaneToFirstCircle(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.PlaneToFirstCircle] == 0.0 then
        self:SetClientTimer(5.0)
    end

    -- No delay needed, PhaseManager solves all of our problems
    if self.m_UpdateTicks[GameStates.PlaneToFirstCircle] >= 5.0 then
        self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = 0.0
        self.m_Server:ChangeGameState(GameStates.Match)

        -- Start the Circle of Death
        self.m_PhaseManager:Start()
        return
    end

    self.m_UpdateTicks[GameStates.PlaneToFirstCircle] = self.m_UpdateTicks[GameStates.PlaneToFirstCircle] + p_DeltaTime
end

function Match:OnMatch(p_DeltaTime)
    self:DoWeHaveAWinner()

    if self.m_UpdateTicks[GameStates.Match] >= ServerConfig.GunshipDespawn then
        if self.m_Gunship:GetEnabled() then
            self.m_Gunship:Spawn(nil, false)
        end
    end

    self:AirdropManager(p_DeltaTime)
    
    -- PhaseManager does the rest

    self.m_UpdateTicks[GameStates.Match] = self.m_UpdateTicks[GameStates.Match] + p_DeltaTime
end

function Match:OnEndGame(p_DeltaTime)
    if self.m_UpdateTicks[GameStates.EndGame] == 0.0 then
        -- End the Circle of Death
        self.m_PhaseManager:End()
        self.m_Gunship:Spawn(nil, false)
        self.m_Airdrop:Spawn(nil, false)

        if self.m_WinnerTeam ~= nil then
            print("INFO: We have a winner team: " .. self.m_WinnerTeam.m_Id)
        else
            print("INFO: Round ended without a winner.")
        end

        -- TODO: Set client UI to show the winners name

        self:SetClientTimer(ServerConfig.EndGameTime)
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

function Match:SetClientTimer(p_Time, p_Player)
    if p_Time == nil then
        return
    end

    if p_Player ~= nil then
        NetEvents:SendTo(PlayerEvents.UpdateTimer, p_Player, p_Time)
    else
        NetEvents:Broadcast(PlayerEvents.UpdateTimer, p_Time)
    end
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

return Match
