---@class PingServer
PingServer = class "PingServer"

---@type Logger
local m_Logger = Logger("PingServer", false)

function PingServer:__init()
	---@type table<integer, number>
	-- Cooldown of each player for pinging
	---[Player.id] -> cooldown
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

---VEXT Server Level:Loaded Event
function PingServer:OnLevelLoaded()
	-- TODO: remove? unused
	-- Clear out the player ping ids
	self.m_Players = {}

	-- Clear out all of the player cooldowns
	self.m_PlayerCooldowns = {}
end

---VEXT Shared Engine:Update Event
---@param p_DeltaTime number
---@param p_SimulationDeltaTime number
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

---Custom Server PlayerEvents.PlayerConnected NetEvent
---@param p_Player Player
function PingServer:OnPlayerConnected(p_Player)
	-- I believe this only happens once, so it should be good enough
	NetEvents:SendToLocal(PingEvents.UpdateConfig, p_Player, self.m_PingDisplayCooldownTime)
end

---Custom Server PingEvents.ClientPing NetEvent
---@param p_Player Player
---@param p_Position Vec3
---@param p_PingType PingType|integer
function PingServer:OnPlayerPing(p_Player, p_Position, p_PingType)
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

	-- Get the squad and player ids
	local s_TeamId = p_Player.teamId
	local s_SquadId = p_Player.squadId

	if self.m_Debug then
		m_Logger:Write("Player: " .. p_Player.name .. " pinged " .. p_Position.x .. ", " ..
					p_Position.y .. ", " .. p_Position.z)
	end

	-- Update the cooldown
	self:AddPlayerCooldown(s_PlayerId, self.m_PingCooldownTime)

	-- send only to solo player that created the ping
	if s_SquadId == SquadId.SquadNone then
		NetEvents:SendToLocal(PingEvents.ServerPing, p_Player, p_Player.name, p_Position, p_PingType)
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
		NetEvents:SendToLocal(PingEvents.ServerPing, l_SquadPlayer, p_Player.name, p_Position, p_PingType)

		::__on_player_ping_cont__::
	end

end

---Custom Server PingEvents.RemoveClientPing NetEvent
---@param p_Player Player
function PingServer:OnRemovePlayerPing(p_Player)
	-- Get the squad and player ids
	local s_TeamId = p_Player.teamId
	local s_SquadId = p_Player.squadId

	self.m_PlayerCooldowns[p_Player.name] = 0.0

	-- send only to solo player that created the ping
	if s_SquadId == SquadId.SquadNone then
		NetEvents:SendToLocal(PingEvents.RemoveServerPing, p_Player, p_Player.name)
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
		NetEvents:SendToLocal(PingEvents.RemoveServerPing, l_SquadPlayer, p_Player.name)

		::__on_player_ping_cont__::
	end
end

-- =============================================
-- Functions
-- =============================================

---@param p_PlayerId integer @Player.id
---@return number
function PingServer:FindPlayerCooldownByPlayerId(p_PlayerId)
	-- Get the result
	local s_Result = self.m_PlayerCooldowns[p_PlayerId]

	-- Check to see if the result is nil or less than an epsilon
	if s_Result == nil or s_Result < 0.001 then
		return 0.0
	end

	return s_Result
end

---@param p_PlayerId integer @Player.id
---@param p_CooldownTime number
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

---@return number
function PingServer:GetPingDisplayCooldownTime()
	return self.m_PingDisplayCooldownTime
end

return PingServer()
