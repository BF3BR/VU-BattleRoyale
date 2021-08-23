require "__shared/Configs/MapsConfig"
require "__shared/Enums/GameStates"
require "__shared/Enums/CustomEvents"
require "__shared/Utils/Timers"
require "__shared/Utils/LevelNameHelper"
require "__shared/Mixins/TimersMixin"

require "Gunship"
local m_PhaseManagerServer = require "PhaseManagerServer"

class("Match", TimersMixin)

local m_LootManager = require("LootManagerServer")
local m_Logger = Logger("Match", true)

function Match:__init(p_Server, p_TeamManager)
	-- call TimersMixin's constructor
	TimersMixin.__init(self)

	-- Save server reference
	self.m_Server = p_Server

	-- Save team manager reference
	self.m_TeamManager = p_TeamManager

	-- Winner
	self.m_WinnerTeam = nil

	-- Gunship
	self.m_Gunship = Gunship()

	-- Airdrop
	-- self.m_Airdrop = Airdrop(self)
	-- self.m_AirdropTimer = 0.0
	-- self.m_AirdropNextDrop = nil

	self.m_RestartQueue = false

	self.m_IsFadeOutSet = false

	self:InitMatch()
end

-- =============================================
-- Events
-- =============================================

function Match:OnExtensionUnloading()
	self.m_Gunship:OnExtensionUnloading()
end

function Match:OnEngineUpdate(p_GameState, p_DeltaTime)
	--[[ if self:GetCurrentState() == GameStates.Match then
		self:AirdropManager(p_DeltaTime)
	end]]
end

function Match:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)
	self.m_Gunship:OnUpdateManagerUpdate(p_DeltaTime, p_UpdatePass)

	if p_UpdatePass == UpdatePass.UpdatePass_PreSim then
		if self.m_RestartQueue then
			m_Logger:Write("INFO: Restart triggered.")
			local s_Result = RCON:SendCommand("mapList.restartRound")

			if #s_Result >= 1 then
				if s_Result[1] ~= "OK" then
					m_Logger:Write("INFO: Command: mapList.restartRound returned: " .. s_Result[1])
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
	self:OnMatchFirstTick()

	self:SetTimer("WhileMatchState", g_Timers:Interval(1, self, self.OnMatchEveryTick))

	-- start the timer for the next match state
	local s_Delay = ServerConfig.MatchStateTimes[self:GetCurrentState()]

	if s_Delay ~= nil then
		self:SetTimer("NextMatchState", g_Timers:Timeout(s_Delay, self, self.NextMatchState))
	else
		self:RemoveTimer("NextMatchState")
	end
end

function Match:GetCurrentState()
	return self.m_Server.m_GameState
end

function Match:NextMatchState()
	-- before switching state
	local s_State = self:GetCurrentState()

	if s_State == GameStates.Plane then
		NetEvents:BroadcastLocal(GunshipEvents.ForceJumpOut)
	elseif s_State == GameStates.PlaneToFirstCircle then
		m_PhaseManagerServer:Start()
	elseif s_State == GameStates.EndGame then
		self.m_RestartQueue = true
	end

	-- check if it reached the end of the matchstates
	if s_State ~= GameStates.None and s_State >= GameStates.EndGame then
		return
	end

	self.m_Server:ChangeGameState(s_State + 1)
end

function Match:OnMatchEveryTick()
	local s_CurrentTimer = self:GetTimer("NextMatchState")
	local s_State = self:GetCurrentState()

	if s_State == GameStates.Warmup then
		if s_CurrentTimer ~= nil and s_CurrentTimer:Remaining() <= 2.0 and not self.m_IsFadeOutSet then
			self.m_IsFadeOutSet = true
			PlayerManager:FadeOutAll(2.0)
		end
	elseif s_State == GameStates.Match then
		self:DoWeHaveAWinner()
	end

	if s_CurrentTimer ~= nil then
		self:SetClientTimer(s_CurrentTimer:Remaining())
	end
end

function Match:OnMatchFirstTick()
	local s_State = self:GetCurrentState()

	if s_State == GameStates.WarmupToPlane then
		-- Fade out then unspawn all soldiers
		self.m_TeamManager:UnspawnAllSoldiers()

		-- Assign all players to teams
		self.m_TeamManager:AssignTeams()

		-- Enable regular pickups
		m_LootManager:EnableMatchPickups()
	elseif s_State == GameStates.Plane then
		-- Spawn the gunship and set its course
		local s_Path = self:GetRandomGunshipPath()

		if s_Path ~= nil then
			self.m_Gunship:Enable(
				s_Path.StartPos,
				s_Path.EndPos,
				ServerConfig.MatchStateTimes[GameStates.Plane],
				"Paradrop"
			)
		end

		-- Fade in all the players
		PlayerManager:FadeInAll(2.0)
		self.m_IsFadeOutSet = false
	elseif s_State == GameStates.Match then
		-- Remove gunship after a short delay
		self:SetTimer("RemoveGunship", g_Timers:Timeout(ServerConfig.GunshipDespawn, self, self.OnRemoveGunship))
	elseif s_State == GameStates.EndGame then
		m_PhaseManagerServer:End()
		self.m_Gunship:Disable()
		-- self.m_Airdrop:Spawn(nil, false)

		if self.m_WinnerTeam ~= nil then
			m_Logger:Write("INFO: We have a winner team: " .. self.m_WinnerTeam.m_Id)

			-- Broadcast the winnin teams ID to clients
			NetEvents:Broadcast(PlayerEvents.WinnerTeamUpdate, self.m_WinnerTeam.m_Id)
		else
			m_Logger:Write("INFO: Round ended without a winner.")
		end
	end
end

function Match:OnRemoveGunship()
	self.m_Gunship:Disable()
	self:RemoveTimer("RemoveGunship")
end

function Match:OnRestartRound()
	self.m_RestartQueue = false
	self.m_WinnerTeam = nil
	self.m_Server:ChangeGameState(GameStates.None)
end

function Match:OnJumpOutOfGunship(p_Player, p_Transform)
	self.m_Gunship:OnJumpOutOfGunship(p_Player, p_Transform)
end

function Match:OnOpenParachute(p_Player)
	self.m_Gunship:OnOpenParachute(p_Player)
end

function Match:OnPlayerUpdateInput(p_Player)
	self.m_Gunship:OnPlayerUpdateInput(p_Player)
end

-- =============================================
-- Other functions
-- =============================================

function Match:GetRandomWarmupSpawnpoint()
	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return nil
	end

	local s_SpawnTrans = nil
	s_SpawnTrans = MapsConfig[s_LevelName]["WarmupSpawnPoints"][ math.random( #MapsConfig[s_LevelName]["WarmupSpawnPoints"] ) ]

	return s_SpawnTrans
end

function Match:GetRandomGunshipPath()
	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return nil
	end

	local s_Return = nil

	local s_Side = math.random(1, 2)

	if s_Side == 1 then
		-- Left to right
		s_Return = {
			StartPos = Vec3(
				MapsConfig[s_LevelName]["MapTopLeftPos"].x,
				MapsConfig[s_LevelName]["PlaneFlyHeight"],
				MapsConfig[s_LevelName]["MapTopLeftPos"].z - math.random(0, MapsConfig[s_LevelName]["MapWidthHeight"])
			),
			EndPos = Vec3(
				MapsConfig[s_LevelName]["MapTopLeftPos"].x - MapsConfig[s_LevelName]["MapWidthHeight"],
				MapsConfig[s_LevelName]["PlaneFlyHeight"],
				MapsConfig[s_LevelName]["MapTopLeftPos"].z - math.random(0, MapsConfig[s_LevelName]["MapWidthHeight"])
			)
		}
	else
		-- Top to bottom
		s_Return = {
			StartPos = Vec3(
				MapsConfig[s_LevelName]["MapTopLeftPos"].x - math.random(0, MapsConfig[s_LevelName]["MapWidthHeight"]),
				MapsConfig[s_LevelName]["PlaneFlyHeight"],
				MapsConfig[s_LevelName]["MapTopLeftPos"].z
			),
			EndPos = Vec3(
				MapsConfig[s_LevelName]["MapTopLeftPos"].x - math.random(0, MapsConfig[s_LevelName]["MapWidthHeight"]),
				MapsConfig[s_LevelName]["PlaneFlyHeight"],
				MapsConfig[s_LevelName]["MapTopLeftPos"].z - MapsConfig[s_LevelName]["MapWidthHeight"]
			)
		}
	end

	local s_Invert = math.random(1, 2)

	if s_Invert == 2 then
		return {
			StartPos = s_Return.EndPos,
			EndPos = s_Return.StartPos
		}
	end

	return s_Return
end

function Match:SetClientTimer(p_Time)
	if p_Time == nil then
		return
	end

	NetEvents:Broadcast(PlayerEvents.UpdateTimer, p_Time)
end

--[[function Match:AirdropManager(p_DeltaTime)
	if self.m_Airdrop:GetEnabled() then
		self.m_AirdropTimer = self.m_AirdropTimer + p_DeltaTime

		-- Remove the airdrop plane after 120 sec
		if self.m_AirdropTimer >= 120.0 then
			m_Logger:Write("INFO: Airdrop unspawned")
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
			m_Logger:Write("INFO: Airdrop spawned")
			self.m_Airdrop:Spawn(self:GetRandomGunshipStart(), true, MathUtils:GetRandom(20, 60))
		end
	end
end]]

function Match:DoWeHaveAWinner()
	if PlayerManager:GetPlayerCount() == 0 then
		self.m_Server:ChangeGameState(GameStates.EndGame)
		return
	end

	if ServerConfig.Debug.DisableWinningCheck then
		-- m_Logger:Write("WinningCheck is disabled.")
		return
	end

	local s_WinningTeam = self.m_TeamManager:GetWinningTeam()

	if s_WinningTeam ~= nil then
		self.m_WinnerTeam = s_WinningTeam
		self.m_Server:ChangeGameState(GameStates.EndGame)
	end
end

-- causes issues cause it needs params + its instantiated again in server init
-- if g_Match == nil then
	-- g_Match = Match()
-- end

-- return g_Match
