require "__shared/Enums/TeamManagerErrors"
require "__shared/Enums/CustomEvents"
require "Types/BRTeam"
require "Types/BRPlayer"

class "BRTeamManager"

local m_Logger = Logger("BRTeamManager", true)

function BRTeamManager:__init()
	self:RegisterVars()
	self:RegisterEvents()
end

function BRTeamManager:RegisterVars()
	-- [id] -> [BRTeam]
	self.m_Teams = {}

	-- [name] -> [BRPlayer]
	self.m_Players = {}
end

function BRTeamManager:RegisterEvents()
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

-- =============================================
-- Events
-- =============================================

function BRTeamManager:OnLevelDestroy()
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

function BRTeamManager:OnPlayerAuthenticated(p_Player)
	m_Logger:Write(string.format("Creating BRPlayer for '%s'", p_Player.name))
	self:CreatePlayer(p_Player)
end

function BRTeamManager:OnPlayerKilled(p_Player)
	self:OnSendPlayerState(p_Player)
end

function BRTeamManager:OnPlayerLeft(p_Player)
	m_Logger:Write(string.format("Destroying BRPlayer for '%s'", p_Player.name))

	-- update player's team placement if needed
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil then
		self:UpdateTeamPlacement(l_BrPlayer.m_Team)

		if l_BrPlayer.m_SpectatedPlayerName ~= nil then
			local s_SpectatedBRPlayer = self:GetPlayer(l_BrPlayer.m_SpectatedPlayerName)

			if s_SpectatedBRPlayer ~= nil then
				s_SpectatedBRPlayer:RemoveSpectator(p_Player.name)
			end

			l_BrPlayer.m_SpectatedPlayerName = nil
		end
	end

	self:RemovePlayer(p_Player)
end

-- Returns the BRPlayer instance of a player
--
-- @param p_Player Player|BRPlayer|string
-- @return BRPlayer|nil
function BRTeamManager:GetPlayer(p_Player)
	return self.m_Players[BRPlayer:GetPlayerName(p_Player)]
end

-- Returns a BRTeam by it's id
--
-- @param p_Id string
-- @return BRTeam|nil
function BRTeamManager:GetTeam(p_Id)
	return self.m_Teams[p_Id]
end

-- Returns the BRTeam that the player is member of
--
-- @param p_Player Player|BRPlayer|string
-- @return BRPlayer|nil
function BRTeamManager:GetTeamByPlayer(p_Player)
	local l_BrPlayer = self:GetPlayer(p_Player)
	return (l_BrPlayer ~= nil and l_BrPlayer.m_Team) or nil
end

-- Returns the team that won the match.
-- Returns nill if more that one teams are currently alive.
function BRTeamManager:GetWinningTeam()
	local l_Winner = nil
	local l_TeamsAlive = 0

	for _, l_Team in pairs(self.m_Teams) do
		if l_Team.m_Active and l_Team:HasAlivePlayers() then
			l_Winner = l_Team
			l_TeamsAlive = l_TeamsAlive + 1

			-- check if more than one teams have alive players
			if l_TeamsAlive > 1 then
				return nil
			end
		end
	end

	if l_Winner ~= nil then
		l_Winner:SetPlacement(1)
		l_Winner:RevivePlayers()
	end

	return l_Winner
end

-- Assigns a team to each player
function BRTeamManager:AssignTeams()
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
	local l_UnlockedTeams = {}

	for _, l_BrTeam in pairs(self.m_Teams) do
		if not l_BrTeam.m_Locked then
			table.insert(l_UnlockedTeams, l_BrTeam)
		end
	end

	-- sort based on the number of players per team
	table.sort(l_UnlockedTeams, function(p_TeamA, p_TeamB)
		return p_TeamA:PlayerCount() < p_TeamB:PlayerCount()
	end)

	-- merge teams
	-- smaller teams are merged with the biggest as long as
	-- there is available space otherwise the index moves forward
	local l_Low = 1
	local l_High = #l_UnlockedTeams

	while l_Low < l_High do
		local l_HighTeam = l_UnlockedTeams[l_High]
		local l_LowTeam = l_UnlockedTeams[l_Low]

		if l_HighTeam:Merge(l_LowTeam) then
			l_Low = l_Low + 1
		else
			l_High = l_High - 1
		end
	end

	-- finalize teams
	local l_Index = 0
	local l_AvailableTeamIds = 100

	for _, l_BrTeam in pairs(self.m_Teams) do
		l_BrTeam.m_Active = true

		-- assign team/squad ids for each BRTeam
		if l_BrTeam:PlayerCount() < 2 then
			l_BrTeam.m_TeamId = TeamId.Team1
			l_BrTeam.m_SquadId = SquadId.SquadNone
		else
			l_BrTeam.m_TeamId = l_Index % (l_AvailableTeamIds - 1) + 2

			-- i guess the squad always will be 1 but i'll let it as is
			-- in case we lower the number of team ids for some reason
			l_BrTeam.m_SquadId = l_Index // (l_AvailableTeamIds - 1) + 1

			l_Index = l_Index + 1
		end

		l_BrTeam:ApplyTeamSquadIds()
	end
end

-- Creates a BRTeam
-- @return BRTeam
function BRTeamManager:CreateTeam()
	-- create team and add it's reference
	local l_Team = BRTeam(self:CreateId())
	self.m_Teams[l_Team.m_Id] = l_Team

	return l_Team
end

-- Removes a BRTeam
-- @param p_Team BRTeam
function BRTeamManager:RemoveTeam(p_Team)
	-- clear reference and destroy team
	self.m_Teams[p_Team.m_Id] = nil
	p_Team:Destroy()
end

-- Creates a BRPlayer instance for the specified player
-- @param p_Player Player
-- @return BRPlayer|nil
function BRTeamManager:CreatePlayer(p_Player)
	if p_Player == nil then
		m_Logger:Error("Cannot create BRPlayer")
		return nil
	end

	local l_Name = p_Player.name

	-- check if BRPlayer already exists
	if self.m_Players[l_Name] ~= nil then
		return self.m_Players[l_Name]
	end

	-- create player
	local l_BrPlayer = BRPlayer(p_Player)
	self.m_Players[l_Name] = l_BrPlayer

	-- create a team and put the player in it
	self:CreateTeamWithPlayer(l_BrPlayer)

	-- create and return the BRPlayer
	return l_BrPlayer
end

-- Removes a BRPlayer
-- @param p_Player Player|BRPlayer|string
function BRTeamManager:RemovePlayer(p_Player)
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil then
		self.m_Players[l_BrPlayer:GetName()] = nil
		l_BrPlayer:Destroy()
	end
end

-- Creates a new BRTeam and puts the player in it
-- @param p_BrPlayer BRPlayer
-- @return BRTeam
function BRTeamManager:CreateTeamWithPlayer(p_BrPlayer)
	local l_Team = self:CreateTeam()

	-- set team lock based on player's preferences
	if p_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.Custom then
		l_Team.m_Locked = false
	else
		l_Team.m_Locked = true
	end

	-- add player to the team
	l_Team:AddPlayer(p_BrPlayer)

	return l_Team
end

-- Kills every player
function BRTeamManager:KillAllPlayers()
	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:Kill(false)
	end
end

-- Unspawns every soldier
function BRTeamManager:UnspawnAllSoldiers()
	local s_HumanPlayerEntityIterator = EntityManager:GetIterator("ServerHumanPlayerEntity")
	local s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()

	while s_HumanPlayerEntity do
		s_HumanPlayerEntity = Entity(s_HumanPlayerEntity)
		s_HumanPlayerEntity:FireEvent("UnSpawnAllSoldiers")
		s_HumanPlayerEntity = s_HumanPlayerEntityIterator:Next()
	end
end

-- Create a unique BRTeam id
-- @param p_Len number (optional)
-- @return string
function BRTeamManager:CreateId(p_Len)
	p_Len = p_Len or 4

	while true do
		local l_Id = MathUtils:RandomGuid():ToString("N"):sub(1, p_Len)

		if self.m_Teams[l_Id] == nil then
			return l_Id
		end
	end
end

-- Checks & updates the team's placement if all of its players are dead
-- @param p_BrTeam BRTeam
function BRTeamManager:UpdateTeamPlacement(p_BrTeam)
	if p_BrTeam == nil or not p_BrTeam.m_Active or p_BrTeam:HasAlivePlayers() then
		return
	end

	local l_Count = self:GetAliveTeamCount()
	p_BrTeam:SetPlacement(l_Count + 1)
end

-- Returns the number of active teams with at least one player alive
-- @return number
function BRTeamManager:GetAliveTeamCount()
	local l_Count = 0

	for _, l_BrTeam in pairs(self.m_Teams) do
		if l_BrTeam.m_Active and l_BrTeam:HasAlivePlayers() then
			l_Count = l_Count + 1
		end
	end

	return l_Count
end

-- Puts the requested player to a newly created team
function BRTeamManager:OnPutOnATeam(p_BrPlayer)
	self:CreateTeamWithPlayer(p_BrPlayer)
end

-- Destroys and removes the specified team
function BRTeamManager:OnDestroyTeam(p_Team)
	self:RemoveTeam(p_Team)
end

function BRTeamManager:OnRegisterKill(p_Victim, p_Giver)
	local l_Killer = p_Giver

	-- resolve who gets the kill
	if p_Victim.m_KillerName ~= nil then
		local l_OrigKiller = self:GetPlayer(p_Victim.m_KillerName)

		if l_OrigKiller ~= nil then
			l_Killer = l_OrigKiller
		end

		-- send finish message to p_Giver
		if p_Giver ~= nil and not p_Giver:Equals(l_Killer) then
			NetEvents:SendToLocal(DamageEvent.PlayerFinish, p_Giver.m_Player, p_Victim:GetName())
		end

		p_Victim.m_KillerName = nil
	end

	local l_PlayerKilledArgs = {p_Victim.m_Player.id, nil}

	if l_Killer ~= nil then
		l_PlayerKilledArgs[2] = l_Killer.m_Player.id

		-- increment killer's counter
		l_Killer:IncrementKills(p_Victim)
	end

	-- broadcast kill
	NetEvents:BroadcastLocal("ServerPlayer:Killed", l_PlayerKilledArgs)

	self:UpdateTeamPlacement(p_Victim.m_Team)
end

function BRTeamManager:OnRequestTeamJoin(p_Player, p_Id)
	local l_BrPlayer = self:GetPlayer(p_Player)
	local l_Team = self:GetTeam(p_Id)

	-- check if team/player not found
	if l_BrPlayer == nil or l_Team == nil or (not l_Team:CanBeJoinedById()) then
		NetEvents:SendToLocal(TeamManagerNetEvent.TeamJoinDenied, p_Player, TeamManagerErrors.InvalidTeamId)
		return
	end

	-- add player to the team
	if not l_Team:AddPlayer(l_BrPlayer) then
		NetEvents:SendToLocal(TeamManagerNetEvent.TeamJoinDenied, p_Player, TeamManagerErrors.TeamIsFull)
	end
end

function BRTeamManager:OnLeaveTeam(p_Player)
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil then
		l_BrPlayer:LeaveTeam()
	end
end

function BRTeamManager:OnLockToggle(p_Player)
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil and l_BrPlayer.m_Team ~= nil then
		l_BrPlayer.m_Team:ToggleLock(l_BrPlayer)
	end
end

function BRTeamManager:OnSendPlayerState(p_Player)
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil then
		l_BrPlayer:SendState()
	end
end

function BRTeamManager:OnTeamJoinStrategy(p_Player, p_Strategy)
	local l_BrPlayer = self:GetPlayer(p_Player)

	if l_BrPlayer ~= nil then
		l_BrPlayer:SetTeamJoinStrategy(p_Strategy)
	end
end

function BRTeamManager:OnUpdateSpectator(p_Player, p_NewPlayerName, p_LastPlayerName)
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
				if s_BRPlayerToSpectate.m_Armor ~= nil then
					local s_State = {
						Armor = s_BRPlayerToSpectate.m_Armor:AsTable()
					}
					NetEvents:SendToLocal(TeamManagerNetEvent.PlayerArmorState, p_Player, s_State)
				end

				s_BRPlayer:SpectatePlayer(p_NewPlayerName)
			end
		end
	end
end

-- define global
if g_BRTeamManager == nil then
	g_BRTeamManager = BRTeamManager()
end

return g_BRTeamManager
