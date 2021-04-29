class "PingServer"

require "BRTeamManager"
require "__shared/Enums/CustomEvents"

local m_Logger = Logger("PingServer", true)

function PingServer:__init()
	-- Table of playerId, pingId
	self.m_PlayerPingIds = {}

	-- Cooldown of each player for pinging
	-- This is a table of playerId, cooldown
	self.m_PlayerCooldowns = {}

	-- Whenever someone pings how long before they can ping again
	self.m_PingCooldownTime = 0.60

	-- Client side player display time
	self.m_PingDisplayCooldownTime = 5.0

	-- Enable debug logging
	self.m_Debug = true
end

-- =============================================
-- Events
-- =============================================

function PingServer:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	-- Clear out the player ping ids
	self.m_PlayerPingIds = {}

	-- Clear out all of the player cooldowns
	self.m_PlayerCooldowns = {}
end

function PingServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	for l_PlayerId, l_Cooldown in pairs(self.m_PlayerCooldowns) do
		if l_Cooldown ~= nil then
			local s_NewCooldown = l_Cooldown - p_DeltaTime
			if s_NewCooldown < 0.001 then
				s_NewCooldown = 0.0
			end

			-- If no result was found
			self.m_PlayerCooldowns[l_PlayerId] = s_NewCooldown
		end
	end
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

function PingServer:OnPlayerConnected(p_Player)
	-- I believe this only happens once, so it should be good enough
	NetEvents:SendToLocal(PingEvents.UpdateConfig, p_Player, self.m_PingDisplayCooldownTime)
end

function PingServer:OnPlayerPing(p_Player, p_Position)
	-- Validate our player
	if p_Player == nil then
		m_Logger:Write("invalid player")
		return
	end

	-- Get the player id
	local s_PlayerId = p_Player.id

	-- If there is a cooldown then ignore this request
	local s_Cooldown = self:FindPlayerCooldownByPlayerId(s_PlayerId)
	if s_Cooldown > 0.0 then
		m_Logger:Write("player on cooldown")
		return
	end

	local s_PingId = self:FindPingIdByPlayerId(s_PlayerId)
	if s_PingId == -1 then
		m_Logger:Write("invalid ping id")
		return
	end

	-- Get the squad and player ids
	local s_TeamId = p_Player.teamId
	local s_SquadId = p_Player.squadId

	if self.m_Debug then
		m_Logger:Write("Player: " .. p_Player.name .. " pingId: " .. s_PingId .. " pinged " .. p_Position.x .. ", " ..
				   p_Position.y .. ", " .. p_Position.z)
	end

	-- Update the cooldown
	self:AddPlayerCooldown(s_PlayerId, self.m_PingCooldownTime)

	-- send only to solo player that created the ping
	if s_SquadId == SquadId.SquadNone then
		NetEvents:SendToLocal(PingEvents.ServerPing, p_Player, s_PingId, p_Position)
		return
	end

	-- Get all players in the same squad and send the notification
	local s_SquadPlayers = PlayerManager:GetPlayersBySquad(s_TeamId, s_SquadId)
	for _, l_SquadPlayer in pairs(s_SquadPlayers) do
		-- Validate the target player
		if l_SquadPlayer == nil then
			goto __on_player_ping_cont__
		end

		-- Send the net event to player in the same squad
		NetEvents:SendToLocal(PingEvents.ServerPing, l_SquadPlayer, s_PingId, p_Position)

		::__on_player_ping_cont__::
	end

end

function PingServer:OnRemovePlayerPing(p_Player)
	local s_PingId = self:FindPingIdByPlayerId(p_Player.id)

	-- Get the squad and player ids
	local s_TeamId = p_Player.teamId
	local s_SquadId = p_Player.squadId

	self.m_PlayerCooldowns[s_PingId] = 0

	-- send only to solo player that created the ping
	if s_SquadId == SquadId.SquadNone then
		NetEvents:SendToLocal(PingEvents.RemoveServerPing, p_Player, s_PingId)
		return
	end

	-- Get all players in the same squad and send the notification
	local s_SquadPlayers = PlayerManager:GetPlayersBySquad(s_TeamId, s_SquadId)
	for _, l_SquadPlayer in pairs(s_SquadPlayers) do
		-- Validate the target player
		if l_SquadPlayer == nil then
			goto __on_player_ping_cont__
		end

		-- Send the net event to player in the same squad
		NetEvents:SendToLocal(PingEvents.RemoveServerPing, l_SquadPlayer, s_PingId)

		::__on_player_ping_cont__::
	end
end

-- =============================================
-- Functions
-- =============================================

-- Finds the player ping id by their player id
-- Returns -1 on error
function PingServer:FindPingIdByPlayerId(p_PlayerId)
	local s_Result = self.m_PlayerPingIds[p_PlayerId]
	if s_Result == nil then
		return -1
	end

	return s_Result
end

function PingServer:FindPlayerCooldownByPlayerId(p_PlayerId)
	-- Get the result
	local s_Result = self.m_PlayerCooldowns[p_PlayerId]

	-- Check to see if the result is nil or less than an epsilon
	if s_Result == nil or s_Result < 0.001 then
		return 0.0
	end

	return s_Result
end

function PingServer:AddPlayerCooldown(p_PlayerId, p_CooldownTime)
	-- Check to see if we already have a cooldown
	local s_Result = self.m_PlayerCooldowns[p_PlayerId]

	-- If we have a result then add this time to the existing result
	if s_Result ~= nil then
		self.m_PlayerCooldowns[p_PlayerId] = s_Result + p_CooldownTime
		return
	end

	-- If no result was found
	self.m_PlayerCooldowns[p_PlayerId] = p_CooldownTime
end

-- This will assign all player ping ids
-- NOTE: The teams will need to have already been assigned/sorted/locked in before calling this
function PingServer:AssignPingIds(p_BrTeams)
	-- Clear all previous entries
	self.m_PlayerPingIds = {}

	for _, l_BrTeam in pairs(p_BrTeams) do
		-- Hold our player ping id per squad
		local l_PlayerPingId = 1

		-- Iterate all players and assign a number
		for _, l_BrPlayer in pairs(l_BrTeam.m_Players) do
			-- Get vanilla player
			local l_Player = l_BrPlayer.m_Player

			-- Validate our player
			if l_Player == nil then
				goto __assign_ping_ids_cont
			end

			-- Get the player id
			local l_PlayerId = l_Player.id

			-- Assign to our table at key of the player id
			self.m_PlayerPingIds[l_PlayerId] = l_PlayerPingId

			-- Debug logging output
			m_Logger:Write("Player: " .. l_Player.name .. " ping id: " .. tostring(l_PlayerPingId))

			-- Increment our player ping id
			l_PlayerPingId = l_PlayerPingId + 1

			::__assign_ping_ids_cont::
		end
	end
end

if g_PingServer == nil then
	g_PingServer = PingServer()
end

return g_PingServer
