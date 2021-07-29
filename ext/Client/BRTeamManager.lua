class 'BRTeamManager'

local m_BrPlayer = require "BRPlayer"
local m_Logger = Logger("BRTeamManager", true)

function BRTeamManager:__init()
end

-- =============================================
-- Events
-- =============================================

function BRTeamManager:OnPlayerTeamChange(p_Player, p_TeamId, p_SquadId)
	self:OverrideTeamIds(p_Player, p_TeamId)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

function BRTeamManager:OnGameStateChanged(p_GameState)
	if p_GameState == GameStates.WarmupToPlane then
		local s_Players = PlayerManager:GetPlayers()

		for _, l_Player in pairs(s_Players) do
			self:OverrideTeamIds(l_Player, l_Player.teamId)
		end
	end
end

-- =============================================
-- Functions
-- =============================================

function BRTeamManager:OverrideTeamIds(p_Player, p_TeamId)
	if p_Player == PlayerManager:GetLocalPlayer() or self:IsTeamMate(p_Player) then
		m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from " .. p_TeamId .. " to Team1")
		p_Player.teamId = TeamId.Team1
		p_Player.squadId = SquadId.Squad1

		if p_Player.soldier ~= nil then
			m_Logger:Write("OverrideTeamId of soldier for this player from " .. p_TeamId .. " to Team1")
			p_Player.soldier.teamId = TeamId.Team1
		end
	else
		m_Logger:Write("OverrideTeamId of player " .. p_Player.name .. " from " .. p_TeamId .. " to Team2")
		p_Player.teamId = TeamId.Team2
		p_Player.squadId = SquadId.Squad1

		if p_Player.soldier ~= nil then
			m_Logger:Write("OverrideTeamId of soldier for this player from " .. p_TeamId .. " to Team2")
			p_Player.soldier.teamId = TeamId.Team2
		end
	end
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

if g_BRTeamManager == nil then
	g_BRTeamManager = BRTeamManager()
end

return g_BRTeamManager
