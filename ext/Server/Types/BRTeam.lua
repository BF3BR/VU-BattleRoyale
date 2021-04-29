require "__shared/Utils/MapHelper"
require "__shared/Enums/CustomEvents"
require "__shared/Enums/TeamJoinStrategy"

class "BRTeam"

function BRTeam:__init(p_Id)
	-- the unique id of the team
	self.m_Id = p_Id

	-- contains the players as [name] -> [BRPlayer]
	self.m_Players = {}

	-- indicates if the team let's random players to fill the remaining positions
	self.m_Locked = false

	-- indicates if the team is currently taking part in the match
	self.m_Active = false

	-- the final placement of the team
	self.m_Placement = nil

	-- vanilla team/squad ids
	self.m_TeamId = TeamId.Team1
	self.m_SquadId = SquadId.SquadNone
end

-- Adds a player to the team
function BRTeam:AddPlayer(p_BrPlayer, p_IgnoreBroadcast)
	-- check if team is full or in game
	if self:IsFull() or self.m_Active then
		return false
	end

	-- check if player is already in a team
	if p_BrPlayer.m_Team ~= nil then
		-- check if already in this team
		if self:Equals(p_BrPlayer.m_Team) then
			return true
		end

		-- remove player from old team
		p_BrPlayer:LeaveTeam(true, p_IgnoreBroadcast)
	end

	-- add references
	self.m_Players[p_BrPlayer:GetName()] = p_BrPlayer
	p_BrPlayer.m_Team = self
	p_BrPlayer.m_PosInSquad = MapHelper:Size(self.m_Players)

	-- assign thew player as team leader if needed
	self:AssignLeader()

	-- update client state
	if not p_IgnoreBroadcast then
		self:BroadcastState()
	end

	return true
end

-- Removes a player from the team
function BRTeam:RemovePlayer(p_BrPlayer, p_Forced, p_IgnoreBroadcast)
	-- check if player isn't a member of this team
	if p_BrPlayer.m_Team == nil or not self:Equals(p_BrPlayer.m_Team) then
		return false
	end

	-- check if team only has one player
	if not p_Forced and MapHelper:Size(self.m_Players) == 1 then
		return false
	end

	-- remove references
	self.m_Players[p_BrPlayer:GetName()] = nil
	p_BrPlayer.m_Team = nil
	p_BrPlayer.m_IsTeamLeader = false

	-- assign new team leader if needed
	self:AssignLeader()

	-- updates the position of the player in the squad
	local l_Size = MapHelper:Size(self.m_Players)
	for _, l_Player in pairs(self.m_Players) do
		if l_Player.m_PosInSquad > l_Size then
			l_Player.m_PosInSquad = l_Player.m_PosInSquad - 1
		end
	end

	-- update client state
	if not p_IgnoreBroadcast then
		self:BroadcastState()
	end

	-- check if team should be destroyed
	if MapHelper:Size(self.m_Players) < 1 then
		Events:DispatchLocal(TeamManagerEvent.DestroyTeam, self)
	end

	return true
end

function BRTeam:Merge(p_OtherTeam)
	-- check if merge is possible
	if self:PlayerCount() + p_OtherTeam:PlayerCount() > ServerConfig.PlayersPerTeam then
		return false
	end

	-- move all the players from the other team
	for _, l_BrPlayer in pairs(p_OtherTeam.m_Players) do
		self:AddPlayer(l_BrPlayer, true)
	end

	self:BroadcastState()

	return true
end

function BRTeam:ToggleLock(p_BrPlayer)
	self:SetLock(p_BrPlayer, not self.m_Locked)
end

function BRTeam:SetLock(p_BrPlayer, p_Value)
	if self:Equals(p_BrPlayer.m_Team) and p_BrPlayer.m_IsTeamLeader then
		self.m_Locked = p_Value
		self:BroadcastState()
	end
end

-- Applies team/squad ids to each player of the team
function BRTeam:ApplyTeamSquadIds(p_TeamId, p_SquadId)
	self.m_TeamId = p_TeamId or self.m_TeamId
	self.m_SquadId = p_SquadId or self.m_SquadId

	-- update team/squad ids for each player
	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:ApplyTeamSquadIds()
	end
end

-- Checks if the team is full and has no space for more players
function BRTeam:IsFull()
	return MapHelper:Size(self.m_Players) >= ServerConfig.PlayersPerTeam
end

-- Checks if the team has any players
function BRTeam:IsEmpty()
	return MapHelper:Empty(self.m_Players)
end

-- Returns the number of players of the team
function BRTeam:PlayerCount()
	return MapHelper:Size(self.m_Players)
end

-- Checks if the team has any alive players
-- @param p_PlayerToIgnore (optional)
-- @param p_NotManDownCheck (optional)
function BRTeam:HasAlivePlayers(p_PlayerToIgnore, p_NotManDownCheck)
	p_NotManDownCheck = not (not p_NotManDownCheck)

	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_Player.alive and (p_PlayerToIgnore == nil or not l_BrPlayer:Equals(p_PlayerToIgnore)) then
			-- ensure its not in mandown state if the p_NotManDownCheck flag is enabled
			if p_NotManDownCheck then
				local l_Soldier = l_BrPlayer:GetSoldier()
				if l_Soldier ~= nil and not l_Soldier.isInteractiveManDown then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

-- Returns the team leader
function BRTeam:GetTeamLeader()
	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_IsTeamLeader then
			return l_BrPlayer
		end
	end

	return nil
end

-- Assigns a new team leader if the team doesn't already have one
function BRTeam:AssignLeader()
	-- check if there's a team leader already
	if self:GetTeamLeader() ~= nil then
		return
	end

	-- pick a player to assign as team leader
	local l_BrPlayer = MapHelper:Item(self.m_Players)
	if l_BrPlayer ~= nil then
		l_BrPlayer.m_IsTeamLeader = true
		return l_BrPlayer
	end

	return nil
end

-- Checks if the team has only one player with no Custom team join strategy selected
function BRTeam:CanBeJoinedById()
	if MapHelper:Size(self.m_Players) == 1 then
		local l_BrPlayer = MapHelper:Item(self.m_Players)
		if l_BrPlayer ~= nil and l_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
			return false
		end
	end

	return true
end

-- Sets the final placement of the team
function BRTeam:SetPlacement(p_Placement)
	if self.m_Placement ~= nil and not self.m_Active then
		return
	end

	self.m_Placement = p_Placement
	self:BroadcastState()
end

-- Finishes every player of the team which may be in mandown state
-- and sends the related kill messages
function BRTeam:FinishPlayers(p_PlayerToIgnore)
	if not self.m_Active then
		return
	end

	for _, l_BrPlayer in pairs(self.m_Players) do
		if (p_PlayerToIgnore == nil or not l_BrPlayer:Equals(p_PlayerToIgnore)) and l_BrPlayer:Kill(true) then
			Events:DispatchLocal(TeamManagerEvent.RegisterKill, l_BrPlayer, nil)
		end
	end
end

-- Broadcasts the state of the team to all of its members
function BRTeam:BroadcastState()
	local l_TeamData = self:AsTable()
	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:SendState(false, l_TeamData)
	end
end

function BRTeam:AsTable()
	local l_Players = {}
	for _, l_BrPlayer in pairs(self.m_Players) do
		table.insert(l_Players, l_BrPlayer:AsTable(true))
	end

	return {
		Id = self.m_Id,
		Locked = self.m_Locked,
		Placement = self.m_Placement,
		Players = l_Players
	}
end

function BRTeam:Reset()
	-- deactivate team
	self.m_Active = false

	-- reset placement
	self.m_Placement = nil
end

function BRTeam:Equals(p_OtherTeam)
	return p_OtherTeam ~= nil and self.m_Id == p_OtherTeam.m_Id
end

-- `==` metamethod
function BRTeam:__eq(p_OtherTeam)
	return self:Equals(p_OtherTeam)
end

-- Destroys the `BRTeam` instance
function BRTeam:Destroy()
	-- force remove all players from the team
	for l_Name, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:LeaveTeam(true)
		self.m_Players[l_Name] = nil

		-- move removed player to another team
		Events:SendLocal(TeamManagerEvent.PutOnATeam, l_BrPlayer)
	end

	self.m_Players = {}
end

-- Garbage collector metamethod
function BRTeam:__gc()
	self:Destroy()
end
