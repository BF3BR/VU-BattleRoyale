---@class BRTeamManagerServer
BRTeamManagerServer = class "BRTeamManagerServer"

---@type Logger
local m_Logger = Logger("BRTeamManagerServer", false)
---@type BRLootPickupDatabase
local m_LootPickupDatabase = require "Types/BRLootPickupDatabase"

function BRTeamManagerServer:__init()
	self:RegisterVars()
	self:RegisterEvents()
end

function BRTeamManagerServer:RegisterVars()
	-- [id] -> [BRTeam]
	---@type table<integer, BRTeam>
	self.m_Teams = {}

	-- [name] -> [BRPlayer]
	---@type table<string, BRPlayer>
	self.m_Players = {}

	---@type integer
	self.m_PlayersPerTeam = ServerConfig.PlayersPerTeam
end

function BRTeamManagerServer:RegisterEvents()
	NetEvents:Subscribe(PhaseManagerNetEvent.InitialState, self, self.OnSendPlayerState)

	Events:Subscribe(TeamManagerEvent.PutOnATeam, self, self.OnPutOnATeam)
	Events:Subscribe(TeamManagerEvent.DestroyTeam, self, self.OnDestroyTeam)
	Events:Subscribe(TeamManagerEvent.RegisterKill, self, self.OnRegisterKill)

	NetEvents:Subscribe(TeamManagerNetEvent.RequestTeamJoin, self, self.OnRequestTeamJoin)
	NetEvents:Subscribe(TeamManagerNetEvent.TeamLeave, self, self.OnLeaveTeam)
	NetEvents:Subscribe(TeamManagerNetEvent.TeamToggleLock, self, self.OnLockToggle)
	NetEvents:Subscribe(TeamManagerNetEvent.TeamJoinStrategy, self, self.OnTeamJoinStrategy)
	NetEvents:Subscribe("UpdateSpectator", self, self.OnUpdateSpectator)
end

function BRTeamManagerServer:UpdatePlayerPerTeam(p_PlayerPerTeam)
	self.m_PlayersPerTeam = p_PlayerPerTeam

	for _, l_BrTeam in pairs(self.m_Teams) do
		l_BrTeam:UpdatePlayerPerTeam(p_PlayerPerTeam)
	end
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Level:Destroy Event
function BRTeamManagerServer:OnLevelDestroy()
	-- put non custom team players back to their own teams
	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
			if l_BrPlayer:LeaveTeam() then
				self:CreateTeamWithPlayer(l_BrPlayer)
			end
		end

		-- reset BrPlayer state
		l_BrPlayer:Reset()
	end

	-- reset BrTeam state
	for _, l_BrTeam in pairs(self.m_Teams) do
		l_BrTeam:Reset()
	end
end

---VEXT Server Player:Created Event
---@param p_Player Player
function BRTeamManagerServer:OnPlayerAuthenticated(p_Player)
	self:CreatePlayer(p_Player)
end

---VEXT Server Player:Killed Event
---@param p_Player Player
function BRTeamManagerServer:OnPlayerKilled(p_Player)
	self:OnSendPlayerState(p_Player)

	local s_BRPlayer = self:GetPlayer(p_Player)
	if s_BRPlayer ~= nil and s_BRPlayer.m_Inventory ~= nil then
		m_LootPickupDatabase:CreateFromInventory(s_BRPlayer:GetPosition(), s_BRPlayer.m_Inventory)
	end
end

---VEXT Server Player:Left Event
---@param p_Player Player
function BRTeamManagerServer:OnPlayerLeft(p_Player)
	m_Logger:Write(string.format("Destroying BRPlayer for '%s'", p_Player.name))

	-- update player's team placement if needed
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil then
		self:UpdateTeamPlacement(s_BrPlayer.m_Team)

		if s_BrPlayer.m_SpectatedPlayerName ~= nil then
			local s_SpectatedBRPlayer = self:GetPlayer(s_BrPlayer.m_SpectatedPlayerName)

			if s_SpectatedBRPlayer ~= nil then
				s_SpectatedBRPlayer:RemoveSpectator(p_Player.name)
			end

			s_BrPlayer.m_SpectatedPlayerName = nil
		end
	end

	self:RemovePlayer(p_Player)
end

---Returns the BRPlayer instance of a player
---@param p_Player Player|BRPlayer|string
---@return BRPlayer|nil
function BRTeamManagerServer:GetPlayer(p_Player)
	return self.m_Players[BRPlayer:GetPlayerName(p_Player)]
end

---Returns a BRTeam by it's id
---@param p_Id string
---@return BRTeam|nil
function BRTeamManagerServer:GetTeam(p_Id)
	return self.m_Teams[p_Id]
end

-- Returns the BRTeam that the player is member of
---@param p_Player Player|BRPlayer|string
---@return BRTeam|nil
function BRTeamManagerServer:GetTeamByPlayer(p_Player)
	local s_BrPlayer = self:GetPlayer(p_Player)
	return (s_BrPlayer ~= nil and s_BrPlayer.m_Team) or nil
end

-- Returns the team that won the match.
-- Returns nill if more that one teams are currently alive.
---@return BRTeam|nil
function BRTeamManagerServer:GetWinningTeam()
	---@type BRTeam|nil
	local s_Winner = nil
	local s_TeamsAlive = 0

	for _, l_Team in pairs(self.m_Teams) do
		if l_Team.m_Active and l_Team:HasAlivePlayers() then
			s_Winner = l_Team
			s_TeamsAlive = s_TeamsAlive + 1

			-- check if more than one teams have alive players
			if s_TeamsAlive > 1 then
				return nil
			end
		end
	end

	if s_Winner ~= nil then
		s_Winner:SetPlacement(1)
		s_Winner:RevivePlayers()
	end

	return s_Winner
end

-- Assigns a team to each player
function BRTeamManagerServer:AssignTeams()
	-- make sure that every player that isn't in a custom team, is the only
	-- player of his team
	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
			-- try to remove players from their teams (it will work only if the team contains
			-- other players)
			if l_BrPlayer:LeaveTeam() then
				-- if removed, put the player in a new team
				self:CreateTeamWithPlayer(l_BrPlayer)
			end

			-- lock teams whose only player chose to play as solo
			if l_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.NoJoin then
				l_BrPlayer.m_Team.m_Locked = true
			elseif l_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.AutoJoin then
				l_BrPlayer.m_Team.m_Locked = false
			end
		end
	end

	-- filter unlocked teams
	---@type BRTeam[]
	local s_UnlockedTeams = {}

	for _, l_BrTeam in pairs(self.m_Teams) do
		if not l_BrTeam.m_Locked then
			table.insert(s_UnlockedTeams, l_BrTeam)
		end
	end

	-- sort based on the number of players per team
	table.sort(s_UnlockedTeams, function(p_TeamA, p_TeamB)
		return p_TeamA:PlayerCount() < p_TeamB:PlayerCount()
	end)

	-- merge teams
	-- smaller teams are merged with the biggest as long as
	-- there is available space otherwise the index moves forward
	local s_Low = 1
	---@type integer
	local s_High = #s_UnlockedTeams

	while s_Low < s_High do
		local s_HighTeam = s_UnlockedTeams[s_High]
		local s_LowTeam = s_UnlockedTeams[s_Low]

		if s_HighTeam:Merge(s_LowTeam) then
			s_Low = s_Low + 1
		else
			s_High = s_High - 1
		end
	end

	-- finalize teams
	local s_Index = 0
	local s_AvailableTeamIds = 100

	for _, l_BrTeam in pairs(self.m_Teams) do
		l_BrTeam.m_Active = true

		-- assign team/squad ids for each BRTeam
		l_BrTeam.m_TeamId = s_Index % (s_AvailableTeamIds - 1) + 2

		-- i guess the squad always will be 1 but i'll let it as is
		-- in case we lower the number of team ids for some reason
		l_BrTeam.m_SquadId = s_Index // (s_AvailableTeamIds - 1) + 1

		s_Index = s_Index + 1

		l_BrTeam:ApplyTeamSquadIds()
	end
end

---Creates a BRTeam
---@return BRTeam
function BRTeamManagerServer:CreateTeam()
	-- create team and add it's reference
	local s_Team = BRTeam(self:CreateId(), self.m_PlayersPerTeam)
	self.m_Teams[s_Team.m_Id] = s_Team

	return s_Team
end

---Removes a BRTeam
---@param p_Team BRTeam
function BRTeamManagerServer:RemoveTeam(p_Team)
	-- clear reference and destroy team
	self.m_Teams[p_Team.m_Id] = nil
	p_Team:Destroy()
end

---Creates a BRPlayer instance for the specified player
---@param p_Player Player
---@return BRPlayer|nil
function BRTeamManagerServer:CreatePlayer(p_Player)
	if p_Player == nil then
		m_Logger:Error("Cannot create BRPlayer")
		return nil
	end

	local s_Name = p_Player.name
	local s_BrPlayer = self.m_Players[s_Name]

	-- check if BRPlayer already exists
	if s_BrPlayer ~= nil then
		-- check if its a bot and replace him with the real player
		local s_BotPlayer = s_BrPlayer:GetPlayer()

		if s_BotPlayer.onlineId == 0 then
			s_BrPlayer.m_Player = p_Player
			s_BrPlayer:SetQuitManually(false)

			if s_BotPlayer.alive then
				-- replace bot with player
				s_BrPlayer:ReplaceBotSoldierWithPlayer(s_BotPlayer.soldier)
			end

			PlayerManager:DeletePlayer(s_BotPlayer)
		end

		return self.m_Players[s_Name]
	end

	m_Logger:Write(string.format("Creating BRPlayer for '%s'", s_Name))

	-- create player
	s_BrPlayer = BRPlayer(p_Player)
	self.m_Players[s_Name] = s_BrPlayer

	-- create a team and put the player in it
	self:CreateTeamWithPlayer(s_BrPlayer)

	-- create and return the BRPlayer
	return s_BrPlayer
end

---Removes a BRPlayer
---@param p_Player Player|BRPlayer|string
function BRTeamManagerServer:RemovePlayer(p_Player)
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil then
		self.m_Players[s_BrPlayer:GetName()] = nil
		s_BrPlayer:Destroy()
	end
end

---Creates a new BRTeam and puts the player in it
---@param p_BrPlayer BRPlayer
---@return BRTeam
function BRTeamManagerServer:CreateTeamWithPlayer(p_BrPlayer)
	local s_Team = self:CreateTeam()

	-- set team lock based on player's preferences
	if p_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.Custom then
		s_Team.m_Locked = false
	else
		s_Team.m_Locked = true
	end

	-- add player to the team
	s_Team:AddPlayer(p_BrPlayer)

	-- set player as party member
	p_BrPlayer.m_JoinedByCode = true

	return s_Team
end

---Kills every player
function BRTeamManagerServer:KillAllPlayers()
	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:Kill(false)
	end
end

---Unspawns every soldier
function BRTeamManagerServer:UnspawnAllSoldiers()
	local s_HumanPlayerEntityIterator = EntityManager:GetIterator("ServerHumanPlayerEntity")
	local s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()

	while s_HumanPlayerEntity do
		s_HumanPlayerEntity = Entity(s_HumanPlayerEntity)
		s_HumanPlayerEntity:FireEvent("UnSpawnAllSoldiers")
		s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()
	end
end

---Create a unique BRTeam id
---@param p_Len integer (optional)
---@return string
function BRTeamManagerServer:CreateId(p_Len)
	p_Len = p_Len or 4

	while true do
		local s_Id = MathUtils:RandomGuid():ToString("N"):sub(1, p_Len)

		if self.m_Teams[s_Id] == nil then
			return s_Id
		end
	end
end

---Checks & updates the team's placement if all of its players are dead
---@param p_BrTeam BRTeam
function BRTeamManagerServer:UpdateTeamPlacement(p_BrTeam)
	if p_BrTeam == nil or not p_BrTeam.m_Active or p_BrTeam:HasAlivePlayers() then
		return
	end

	local s_Count = self:GetAliveTeamCount()
	p_BrTeam:SetPlacement(s_Count + 1)
end

---Returns the number of active teams with at least one player alive
---@return integer
function BRTeamManagerServer:GetAliveTeamCount()
	local s_Count = 0

	for _, l_BrTeam in pairs(self.m_Teams) do
		if l_BrTeam.m_Active and l_BrTeam:HasAlivePlayers() then
			s_Count = s_Count + 1
		end
	end

	return s_Count
end

---Puts the requested player to a newly created team
---@param p_BrPlayer BRPlayer
function BRTeamManagerServer:OnPutOnATeam(p_BrPlayer)
	self:CreateTeamWithPlayer(p_BrPlayer)
end

---Destroys and removes the specified team
---@param p_Team BRTeam
function BRTeamManagerServer:OnDestroyTeam(p_Team)
	self:RemoveTeam(p_Team)
end

---@param p_Victim BRPlayer
---@param p_Giver BRPlayer
function BRTeamManagerServer:OnRegisterKill(p_Victim, p_Giver)
	local s_Killer = p_Giver

	-- resolve who gets the kill
	if p_Victim.m_KillerName ~= nil then
		local s_OrigKiller = self:GetPlayer(p_Victim.m_KillerName)

		if s_OrigKiller ~= nil then
			s_Killer = s_OrigKiller
		end

		-- send finish message to p_Giver
		if p_Giver ~= nil and not p_Giver:Equals(s_Killer) then
			NetEvents:SendToLocal(DamageEvent.PlayerFinish, p_Giver.m_Player, p_Victim:GetName())
		end

		p_Victim.m_KillerName = nil
	end

	---@type integer|nil @Player.id
	local s_KilledId = nil

	if s_Killer ~= nil then
		s_KilledId = s_Killer.m_Player.id

		-- increment killer's counter
		s_Killer:IncrementKills(p_Victim)
	end

	-- broadcast kill
	NetEvents:BroadcastLocal("ServerPlayer:Killed", p_Victim.m_Player.id, s_KilledId)

	self:UpdateTeamPlacement(p_Victim.m_Team)
end

---@param p_Player Player|BRPlayer|string
---@param p_Id string
function BRTeamManagerServer:OnRequestTeamJoin(p_Player, p_Id)
	local s_BrPlayer = self:GetPlayer(p_Player)
	local s_Team = self:GetTeam(p_Id)

	-- check if team/player not found
	if s_BrPlayer == nil or s_Team == nil or (not s_Team:CanBeJoinedById()) then
		NetEvents:SendToLocal(TeamManagerNetEvent.TeamJoinDenied, p_Player, TeamManagerErrors.InvalidTeamId)
		return
	end

	-- add player to the team
	if not s_Team:AddPlayer(s_BrPlayer) then
		NetEvents:SendToLocal(TeamManagerNetEvent.TeamJoinDenied, p_Player, TeamManagerErrors.TeamIsFull)
	end

	-- set player as party member
	s_BrPlayer.m_JoinedByCode = true
end

---@param p_Player Player|BRPlayer|string
function BRTeamManagerServer:OnLeaveTeam(p_Player)
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil then
		s_BrPlayer:LeaveTeam()
	end
end

---@param p_Player Player|BRPlayer|string
function BRTeamManagerServer:OnLockToggle(p_Player)
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil and s_BrPlayer.m_Team ~= nil then
		s_BrPlayer.m_Team:ToggleLock(s_BrPlayer)
	end
end

---@param p_Player Player|BRPlayer|string
function BRTeamManagerServer:OnSendPlayerState(p_Player)
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil then
		s_BrPlayer:SendState()
	end
end

---@param p_Player Player|BRPlayer|string
---@param p_Strategy TeamJoinStrategy|integer
function BRTeamManagerServer:OnTeamJoinStrategy(p_Player, p_Strategy)
	local s_BrPlayer = self:GetPlayer(p_Player)

	if s_BrPlayer ~= nil then
		s_BrPlayer:SetTeamJoinStrategy(p_Strategy)
	end
end

---@param p_Player Player|BRPlayer|string
---@param p_NewPlayerName string|nil
---@param p_LastPlayerName string|nil
function BRTeamManagerServer:OnUpdateSpectator(p_Player, p_NewPlayerName, p_LastPlayerName)
	m_Logger:Write("OnUpdateSpectator player: " .. p_Player.name)
	local s_BRPlayer = self:GetPlayer(p_Player)

	if s_BRPlayer ~= nil then
		s_BRPlayer:SpectatePlayer(nil)
	end

	if p_LastPlayerName ~= nil then
		local s_LastSpectatedBRPlayer = self:GetPlayer(p_LastPlayerName)

		if s_LastSpectatedBRPlayer ~= nil then
			s_LastSpectatedBRPlayer:RemoveSpectator(p_Player.name)
		end
	end

	if p_NewPlayerName ~= nil then
		local s_BRPlayerToSpectate = self:GetPlayer(p_NewPlayerName)

		if s_BRPlayerToSpectate ~= nil then
			s_BRPlayerToSpectate:AddSpectator(p_Player.name)

			if s_BRPlayer ~= nil then
				-- add a NetEvent with all player names of the spectated player team
				-- if it is a teammate we don't want to do that
				if s_BRPlayerToSpectate.m_Team ~= nil and not s_BRPlayerToSpectate:IsTeammate(s_BRPlayer) then
					---@type string[]
					local s_PlayerNames = {}

					for l_PlayerName, _ in pairs(s_BRPlayerToSpectate.m_Team.m_Players) do
						table.insert(s_PlayerNames, l_PlayerName)
					end

					NetEvents:SendToLocal("SpectatedPlayerTeamMembers", p_Player, s_PlayerNames)
				end

				s_BRPlayer:SpectatePlayer(s_BRPlayerToSpectate)
			end
		end
	end
end

function BRTeamManagerServer:DestroyAll()
	for l_Id, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:Destroy()
	end

	for l_Id, l_BrTeam in pairs(self.m_Teams) do
		l_BrTeam:Destroy()
	end

	self.m_Players = {}
	self.m_Teams = {}
end

return BRTeamManagerServer()
