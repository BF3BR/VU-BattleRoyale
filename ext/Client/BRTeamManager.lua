class 'BRTeamManager'

local m_BrPlayer = require "BRPlayer"
local m_Logger = Logger("BRTeamManager", true)

function BRTeamManager:__init()
	self:RegisterVars()
end

function BRTeamManager:RegisterVars()
	self.m_SpectatedPlayerNames = {}
end

-- =============================================
-- Events
-- =============================================

function BRTeamManager:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	-- we have to ignore spectated players
	-- otherwise we would switch them back to team2
	for _, l_PlayerName in pairs(self.m_SpectatedPlayerNames) do
		if p_Player.name == l_PlayerName then
			if p_TeamId == TeamId.Team3 then
				return
			else
				self:SetTeamId(p_Player, TeamId.Team3)
			end
		end
	end

	self:OverrideTeamIds(p_Player)
end

function BRTeamManager:OnPlayerRespawn(p_Player)
	self:OverrideTeamIds(p_Player)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

function BRTeamManager:OnGameStateChanged(p_GameState)
	if p_GameState == GameStates.WarmupToPlane then
		self.m_SpectatedPlayerNames = {}
		local s_Players = PlayerManager:GetPlayers()

		for _, l_Player in pairs(s_Players) do
			self:OverrideTeamIds(l_Player)
		end
	end
end

function BRTeamManager:OnSpectatedPlayerTeamMembers(p_PlayerNames)
	self.m_SpectatedPlayerNames = p_PlayerNames

	-- First we want to move all old spectated players from Team3 to Team2
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

function BRTeamManager:OverrideTeamIds(p_Player)
	if p_Player == PlayerManager:GetLocalPlayer() or self:IsTeamMate(p_Player) then
		self:SetTeamId(p_Player, TeamId.Team1)
	else
		self:SetTeamId(p_Player, TeamId.Team2)
	end
end

function BRTeamManager:SetTeamId(p_Player, p_TeamId)
	m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from Team" .. p_Player.teamId .. " to Team" .. p_TeamId)
	p_Player.teamId = p_TeamId

	if p_Player.soldier ~= nil then
		p_Player.soldier.teamId = p_TeamId
	end

	p_Player.squadId = SquadId.Squad1

	g_Timers:Timeout(1, p_Player.name, function(p_PlayerName)
		local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)

		if s_Player and s_Player.soldier ~= nil then
			m_Logger:Write("OverrideTeamId of soldier for this player from Team" .. p_Player.soldier.teamId .. " to Team" .. p_TeamId)
			p_Player.teamId = p_TeamId
			p_Player.soldier.teamId = p_TeamId
			p_Player.squadId = SquadId.Squad1
		end
	end)
end

function BRTeamManager:IsTeamMate(p_Player)
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

return BRTeamManager()
