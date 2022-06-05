---@class Match : TimersMixin
Match = class("Match", TimersMixin)

---@type Logger
local m_Logger = Logger("Match", false)

---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
---@type GameStateManager
local m_GameStateManager = require "GameStateManager"
---@type BRTeamManagerServer
local m_TeamManagerServer = require "BRTeamManagerServer"
---@type GunshipServer
local m_GunshipServer = require "GunshipServer"
---@type PhaseManagerServer
local m_PhaseManagerServer = require "PhaseManagerServer"
---@type BRLootManager
local m_BRLootManager = require "BRLootManager"
---@type BRInventoryManager
local m_BRInventoryManager = require "BRInventoryManager"
---@type BRAirdropManager
local m_BRAirdropManager = require "BRAirdropManager"

function Match:__init()
	-- call TimersMixin's constructor
	TimersMixin.__init(self)

	-- Winner
	self.m_WinnerTeam = nil

	-- TODO: recheck these 2 vars
	-- Airdrop
	self.m_AirdropTimer = 0.0
	self.m_AirdropNextDrop = nil

	self.m_RestartQueue = false

	self.m_IsFadeOutSet = false

	self:InitMatch()
end

-- =============================================
-- Events
-- =============================================

---VEXT Server Level:Loaded Event
---Resetting the match state
function Match:OnLevelLoaded()
	self.m_RestartQueue = false
	self.m_WinnerTeam = nil
	m_GameStateManager:SetGameState(GameStates.None)

	-- Spawn loot pickups for warmup
	-- TODO: Close only code will more than likely fix this, so reenable this line
	-- m_BRLootManager:SpawnMapSpecificLootPickups()
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreSim
---@param p_DeltaTime number
function Match:OnUpdatePassPreSim(p_DeltaTime)
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

-- =============================================
-- Match Logic
-- =============================================

function Match:InitMatch()
	self:OnMatchFirstTick()

	self:SetTimer("WhileMatchState", m_TimerManager:Interval(1, self, self.OnMatchEveryTick))

	-- start the timer for the next match state
	local s_Delay = ServerConfig.MatchStateTimes[m_GameStateManager:GetGameState()]

	if s_Delay ~= nil then
		self:SetTimer("NextMatchState", m_TimerManager:Timeout(s_Delay, self, self.NextMatchState))
	else
		self:RemoveTimer("NextMatchState")
	end
end

function Match:NextMatchState()
	-- before switching state
	local s_State = m_GameStateManager:GetGameState()

	if s_State == GameStates.Plane then
		NetEvents:BroadcastLocal(GunshipEvents.ForceJumpOut)
	elseif s_State == GameStates.PlaneToFirstCircle then
		m_PhaseManagerServer:Start()
	elseif s_State == GameStates.EndGame then
		-- Clear out all inventories
		m_BRInventoryManager:Clear()

		-- Remove all loot pickups
		m_BRLootManager:RemoveAllLootPickups()

		self.m_RestartQueue = true
	end

	-- check if it reached the end of the matchstates
	if s_State ~= GameStates.None and s_State >= GameStates.EndGame then
		return
	end

	m_GameStateManager:SetGameState(s_State + 1)
end

function Match:OnMatchEveryTick()
	local s_CurrentTimer = self:GetTimer("NextMatchState")
	local s_State = m_GameStateManager:GetGameState()

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
	local s_State = m_GameStateManager:GetGameState()

	if s_State == GameStates.WarmupToPlane then
		-- Fade out then unspawn all soldiers
		m_TeamManagerServer:UnspawnAllSoldiers()

		-- Assign all players to teams
		m_TeamManagerServer:AssignTeams()

		-- Clear out all inventories
		m_BRInventoryManager:Clear()

		-- Remove all loot pickups
		m_BRLootManager:RemoveAllLootPickups()

		-- Spawn new loot pickups
		m_BRLootManager:SpawnMapSpecificLootPickups()
	elseif s_State == GameStates.Plane then
		-- Spawn the gunship and set its course
		local s_Path = m_GunshipServer:GetRandomGunshipPath()

		if s_Path ~= nil then
			m_GunshipServer:Enable(
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
		self:SetTimer("RemoveGunship", m_TimerManager:Timeout(ServerConfig.GunshipDespawn, self, self.OnRemoveGunship))
	elseif s_State == GameStates.EndGame then
		m_PhaseManagerServer:End()
		m_GunshipServer:Disable()

		if self.m_WinnerTeam ~= nil then
			m_Logger:Write("INFO: We have a winner team: " .. self.m_WinnerTeam.m_Id)

			-- Broadcast the winnin teams ID to clients
			NetEvents:Broadcast(PlayerEvents.WinnerTeamUpdate, self.m_WinnerTeam:AsTable())
		else
			m_Logger:Write("INFO: Round ended without a winner.")
		end
	end
end

---Timer Timeout callback
function Match:OnRemoveGunship()
	m_GunshipServer:Disable()
	self:RemoveTimer("RemoveGunship")
end

-- =============================================
-- Other functions
-- =============================================

---@return Vec3|nil
function Match:GetRandomWarmupSpawnpoint()
	local s_LevelName = LevelNameHelper:GetLevelName()

	if s_LevelName == nil then
		return nil
	end

	---@type Vec3
	local s_SpawnTrans = nil
	s_SpawnTrans = MapsConfig[s_LevelName].WarmupSpawnPoints[math.random(#MapsConfig[s_LevelName]["WarmupSpawnPoints"])]

	return s_SpawnTrans
end

---@param p_Time number|nil
function Match:SetClientTimer(p_Time)
	if p_Time == nil then
		return
	end

	NetEvents:BroadcastUnreliable(PlayerEvents.UpdateTimer, p_Time)
end

function Match:DoWeHaveAWinner()
	if PlayerManager:GetPlayerCount() == 0 then
		m_GameStateManager:SetGameState(GameStates.EndGame)
		return
	end

	if ServerConfig.Debug.DisableWinningCheck then
		-- m_Logger:Write("WinningCheck is disabled.")
		return
	end

	local s_WinningTeam = m_TeamManagerServer:GetWinningTeam()

	if s_WinningTeam ~= nil then
		self.m_WinnerTeam = s_WinningTeam
		m_GameStateManager:SetGameState(GameStates.EndGame)
	end
end

return Match()
