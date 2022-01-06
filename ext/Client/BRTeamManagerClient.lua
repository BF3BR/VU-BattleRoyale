---@class BRTeamManagerClient
BRTeamManagerClient = class 'BRTeamManagerClient'

---@type BRPlayer
local m_BrPlayer = require "BRPlayer"
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"
local m_Logger = Logger("BRTeamManagerClient", true)

function BRTeamManagerClient:__init()
	self:RegisterVars()
end

function BRTeamManagerClient:RegisterVars()
	---@type string[]
	self.m_SpectatedPlayerNames = {}
end

-- =============================================
-- Events
-- =============================================

---VEXT Client Player:TeamChange Event
---@param p_Player Player
---@param p_TeamId TeamId|integer
---@param p_SquadId SquadId|integer
function BRTeamManagerClient:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	-- we have to ignore spectated players
	-- otherwise we would switch them back to team2
	for _, l_PlayerName in pairs(self.m_SpectatedPlayerNames) do
		if p_Player.name == l_PlayerName then
			if p_TeamId ~= TeamId.Team3 then
				self:SetTeamId(p_Player, TeamId.Team3)
			end

			return
		end
	end

	self:OverrideTeamIds(p_Player)
end

---VEXT Client Player:Respawn Event
---@param p_Player Player
function BRTeamManagerClient:OnPlayerRespawn(p_Player)
	self:OverrideTeamIds(p_Player)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

---Custom Client PlayerEvents.GameStateChanged NetEvent
---@param p_GameState GameStates|integer
function BRTeamManagerClient:OnGameStateChanged(p_GameState)
	if p_GameState == GameStates.WarmupToPlane then
		self.m_SpectatedPlayerNames = {}
		local s_Players = PlayerManager:GetPlayers()

		for _, l_Player in pairs(s_Players) do
			self:OverrideTeamIds(l_Player)
		end
	end
end

---Custom Client SpectatedPlayerTeamMembers NetEvent
---@param p_PlayerNames string[]
function BRTeamManagerClient:OnSpectatedPlayerTeamMembers(p_PlayerNames)
	self.m_SpectatedPlayerNames = p_PlayerNames

	m_Logger:Write("Set SpectatedPlayer TeamMembers:")
	m_Logger:WriteTable(p_PlayerNames)

	-- First we want to move all old spectated players from Team3 to Team2
	---@type Player[]
	local s_Team3Players = PlayerManager:GetPlayersByTeam(TeamId.Team3)

	for _, l_Player in pairs(s_Team3Players) do
		self:SetTeamId(l_Player, TeamId.Team2)
	end

	-- now we move the new spectated team to Team3
	for _, l_PlayerName in pairs(self.m_SpectatedPlayerNames) do
		local s_Player = PlayerManager:GetPlayerByName(l_PlayerName)

		if s_Player ~= nil then
			self:SetTeamId(s_Player, TeamId.Team3)
		end
	end
end

-- =============================================
-- Functions
-- =============================================

---We tell the client that this player is either in Team1 or Team2
---@param p_Player Player
function BRTeamManagerClient:OverrideTeamIds(p_Player)
	if p_Player == PlayerManager:GetLocalPlayer() or self:IsTeamMate(p_Player) then
		self:SetTeamId(p_Player, TeamId.Team1)
	else
		self:SetTeamId(p_Player, TeamId.Team2)
	end
end

---Changing the TeamId on the client
---@param p_Player Player
---@param p_TeamId TeamId|integer @increased to 127 IDs
function BRTeamManagerClient:SetTeamId(p_Player, p_TeamId)
	m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from Team" .. p_Player.teamId .. " to Team" .. p_TeamId)
	p_Player.teamId = p_TeamId

	if p_Player.soldier ~= nil then
		p_Player.soldier.teamId = p_TeamId
	end

	p_Player.squadId = SquadId.Squad1

	---Change the soldier TeamId as well
	---@param p_PlayerName string
	m_TimerManager:Timeout(1, p_Player.name, function(p_PlayerName)
		local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)

		if s_Player and s_Player.soldier ~= nil then
			m_Logger:Write("OverrideTeamId of soldier for this player from Team" .. s_Player.soldier.teamId .. " to Team" .. p_TeamId)
			s_Player.teamId = p_TeamId
			s_Player.soldier.teamId = p_TeamId
			s_Player.squadId = SquadId.Squad1
		end
	end)
end

---Check if the player is a teammate
---@param p_Player Player
---@return boolean
function BRTeamManagerClient:IsTeamMate(p_Player)
	if m_BrPlayer.m_Team == nil then
		return false
	end

	local s_TeamPlayers = m_BrPlayer.m_Team:PlayersTable()

	if s_TeamPlayers ~= nil then
		for _, l_Teammate in ipairs(s_TeamPlayers) do
			if l_Teammate ~= nil then
				if p_Player.name == l_Teammate.Name then
					return true
				end
			end
		end
	end

	return false
end

return BRTeamManagerClient()
