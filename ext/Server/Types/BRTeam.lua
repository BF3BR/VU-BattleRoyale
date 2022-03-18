---@class BRTeam
BRTeam = class "BRTeam"

---@type Logger
local m_Logger = Logger("BRTeam", false)

---@type MapHelper
local m_MapHelper = require "__shared/Utils/MapHelper"

---@param p_Id string
function BRTeam:__init(p_Id, p_PlayersPerTeam)
	-- the unique id of the team
	---@type string
	self.m_Id = p_Id

	-- contains the players as `[name] -> [BRPlayer]`
	---@type table<string, BRPlayer>
	self.m_Players = {}

	-- indicates if the team let's random players to fill the remaining positions
	self.m_Locked = false

	-- indicates if the team is currently taking part in the match
	self.m_Active = false

	-- the final placement of the team
	---@type integer|nil
	self.m_Placement = nil

	-- vanilla team/squad ids
	---@type TeamId|integer
	self.m_TeamId = TeamId.Team1
	---@type SquadId|integer
	self.m_SquadId = SquadId.SquadNone

	-- create a VoipChannel if the team has more then 1 member
	---@type VoipChannel|nil
	self.m_VoipChannel = nil

	-- player count per team
	---@type integer
	self.m_PlayersPerTeam = p_PlayersPerTeam
end

---Updates the player count per team
---@param p_PlayerPerTeam integer
function BRTeam:UpdatePlayerPerTeam(p_PlayerPerTeam)
	self.m_PlayersPerTeam = p_PlayerPerTeam
end

---Adds a player to the team
---@param p_BrPlayer BRPlayer
---@param p_IgnoreBroadcast boolean
---@return boolean
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
	p_BrPlayer.m_PosInSquad = self:PlayerCount()

	-- assign thew player as team leader if needed
	self:AssignLeader()

	-- update client state
	if not p_IgnoreBroadcast then
		self:BroadcastState()
	end

	if self:PlayerCount() > 1 then
		-- if we have no voip channel, create a voip channel (if the playercount is higher then 1)
		if self.m_VoipChannel == nil then
			self:CreateVoipChannel()

			-- add all players to this channel
			for _, l_BrPlayer in pairs(self.m_Players) do
				self:AddPlayerToVoip(l_BrPlayer)
			end
		else
			-- we already have a voip channel, just add this player to it
			self:AddPlayerToVoip(p_BrPlayer)
		end
	end

	return true
end

---Removes a player from the team
---@param p_BrPlayer BRPlayer
---@param p_Forced boolean
---@param p_IgnoreBroadcast boolean
---@return boolean
function BRTeam:RemovePlayer(p_BrPlayer, p_Forced, p_IgnoreBroadcast)
	-- check if player isn't a member of this team
	if p_BrPlayer.m_Team == nil or not self:Equals(p_BrPlayer.m_Team) then
		return false
	end

	-- check if team only has one player
	if not p_Forced and self:PlayerCount() == 1 then
		return false
	end

	-- remove references
	self.m_Players[p_BrPlayer:GetName()] = nil

	-- update BRPlayer related fields
	p_BrPlayer.m_Team = nil
	p_BrPlayer.m_IsTeamLeader = false
	p_BrPlayer.m_JoinedByCode = false

	-- assign new team leader if needed
	self:AssignLeader()

	-- updates the position of the player in the squad
	local s_Size = self:PlayerCount()

	for _, l_Player in pairs(self.m_Players) do
		if l_Player.m_PosInSquad > s_Size then
			l_Player.m_PosInSquad = l_Player.m_PosInSquad - 1
		end
	end

	-- update client state
	if not p_IgnoreBroadcast then
		self:BroadcastState()
	end

	-- check if team should be destroyed
	if self:PlayerCount() < 1 then
		Events:DispatchLocal(TeamManagerEvent.DestroyTeam, self)
	end

	-- if a voip channel exists, remove the player that left the team
	if self.m_VoipChannel ~= nil then
		self:RemovePlayerFromVoip(p_BrPlayer)

		-- we have 1 or less players in this BRTeam, we can close the voip channel
		if self:PlayerCount() <= 1 then
			self:CloseVoipChannel()
		end
	end

	return true
end

---@param p_OtherTeam BRTeam
---@return boolean
function BRTeam:Merge(p_OtherTeam)
	-- check if merge is possible
	if self:PlayerCount() + p_OtherTeam:PlayerCount() > self.m_PlayersPerTeam then
		return false
	end

	-- move all the players from the other team
	for _, l_BrPlayer in pairs(p_OtherTeam.m_Players) do
		self:AddPlayer(l_BrPlayer, true)
	end

	self:BroadcastState()

	return true
end

-- =============================================
-- Voip Functions
-- =============================================

function BRTeam:CreateVoipChannel()
	self.m_VoipChannel = Voip:CreateChannel("BRTeam_" .. tostring(self.m_Id), VoipEmitterType.Local)
end

---@param p_BrPlayer BRPlayer
function BRTeam:AddPlayerToVoip(p_BrPlayer)
	self.m_VoipChannel:AddPlayer(p_BrPlayer:GetPlayer())
end

---@param p_BrPlayer BRPlayer
function BRTeam:RemovePlayerFromVoip(p_BrPlayer)
	self.m_VoipChannel:RemovePlayer(p_BrPlayer:GetPlayer())
end

function BRTeam:CloseVoipChannel()
	-- remove all players before closing
	for _, l_Player in pairs(self.m_VoipChannel.players) do
		self.m_VoipChannel:RemovePlayer(l_Player)
	end

	self.m_VoipChannel:Close()
	self.m_VoipChannel = nil
end

---Returns the members of the team that joined using the code
---(which means that they are party members)
---@return table<integer, BRPlayer> @len 1-4
function BRTeam:GetPartyMembers()
	---@type table<integer, BRPlayer> @len 1-4
	local s_PartyMembers = {}

	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_JoinedByCode then
			table.insert(s_PartyMembers, l_BrPlayer)
		end
	end

	return s_PartyMembers
end

---Toggles the state of the lock
---@param p_BrPlayer BRPlayer
function BRTeam:ToggleLock(p_BrPlayer)
	self:SetLock(p_BrPlayer, not self.m_Locked)
end

---@param p_BrPlayer BRPlayer
---@param p_Value boolean
function BRTeam:SetLock(p_BrPlayer, p_Value)
	if self:Equals(p_BrPlayer.m_Team) and p_BrPlayer.m_IsTeamLeader then
		self.m_Locked = p_Value
		self:BroadcastState()
	end
end

---Applies team/squad ids to each player of the team
---@param p_TeamId TeamId|integer|nil
---@param p_SquadId SquadId|integer|nil
function BRTeam:ApplyTeamSquadIds(p_TeamId, p_SquadId)
	self.m_TeamId = p_TeamId or self.m_TeamId
	self.m_SquadId = p_SquadId or self.m_SquadId

	-- update team/squad ids for each player
	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:ApplyTeamSquadIds()
	end
end

---Checks if the team is full and has no space for more players
---@return boolean
function BRTeam:IsFull()
	return self:PlayerCount() >= self.m_PlayersPerTeam
end

---Checks if the team has any players
---@return boolean
function BRTeam:IsEmpty()
	return m_MapHelper:Empty(self.m_Players)
end

---Returns the number of players of the team
---@return integer
function BRTeam:PlayerCount()
	return m_MapHelper:Size(self.m_Players)
end

---Checks if the team has any alive players
---@param p_PlayerToIgnore BRPlayer|nil @(optional)
---@param p_NotManDownCheck boolean|nil @(optional)
function BRTeam:HasAlivePlayers(p_PlayerToIgnore, p_NotManDownCheck)
	p_NotManDownCheck = not (not p_NotManDownCheck)

	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_Player.alive and (p_PlayerToIgnore == nil or not l_BrPlayer:Equals(p_PlayerToIgnore)) then
			-- ensure its not in mandown state if the p_NotManDownCheck flag is enabled
			if p_NotManDownCheck then
				local s_Soldier = l_BrPlayer:GetSoldier()

				if s_Soldier ~= nil and not s_Soldier.isInteractiveManDown then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

---Returns the team leader
---@return BRPlayer|nil
function BRTeam:GetTeamLeader()
	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_IsTeamLeader then
			return l_BrPlayer
		end
	end

	return nil
end

---Assigns a new team leader if the team doesn't already have one
---@return BRPlayer|nil
function BRTeam:AssignLeader()
	-- check if there's a team leader already
	if self:GetTeamLeader() ~= nil then
		return nil
	end

	-- pick a player to assign as team leader
	local s_BrPlayer = m_MapHelper:Item(self.m_Players)

	if s_BrPlayer ~= nil then
		s_BrPlayer.m_IsTeamLeader = true
		return s_BrPlayer
	end

	return nil
end

---Checks if the team can be joined by id
---@return boolean
function BRTeam:CanBeJoinedById()
	-- if the team has only one player and no Custom team join strategy selected
	-- then it can't be joined by id
	if self:PlayerCount() == 1 then
		local s_BrPlayer = m_MapHelper:Item(self.m_Players)

		if s_BrPlayer ~= nil and s_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
			return false
		end
	end

	return true
end

---Sets the final placement of the team
---@param p_Placement integer
function BRTeam:SetPlacement(p_Placement)
	if self.m_Placement ~= nil and not self.m_Active then
		return
	end

	self.m_Placement = p_Placement
	self:BroadcastState()
end

-- Finishes every player of the team which may be in mandown state
-- and sends the related kill messages
---@param p_PlayerToIgnore BRPlayer
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

---Revives ManDown players of the winning team
function BRTeam:RevivePlayers()
	for _, l_BrPlayer in pairs(self.m_Players) do
		if l_BrPlayer.m_Player ~= nil and l_BrPlayer.m_Player.soldier ~= nil and l_BrPlayer.m_Player.soldier.isInteractiveManDown then
			m_Logger:Write("Reviving player: " .. l_BrPlayer.m_Player.name)
			l_BrPlayer.m_Player.soldier:FireEvent("Revive")
			l_BrPlayer.m_Player.soldier:SetPose(CharacterPoseType.CharacterPoseType_Stand, false, true)
		end
	end
end

-- Broadcasts the state of the team to all of its members
function BRTeam:BroadcastState()
	local s_TeamData = self:AsTable()

	for _, l_BrPlayer in pairs(self.m_Players) do
		l_BrPlayer:SendState(false, s_TeamData)
	end
end

---@class BRTeamTable
---@field Id string
---@field Locked boolean
---@field Placement integer
---@field Players BRSimplePlayerTable[]

---@return BRTeamTable
function BRTeam:AsTable()
	local s_Players = {}

	-- add the state for each player
	for _, l_BrPlayer in pairs(self.m_Players) do
		table.insert(s_Players, l_BrPlayer:AsTable(true))
	end

	return {
		Id = self.m_Id,
		Locked = self.m_Locked,
		Placement = self.m_Placement,
		Players = s_Players
	}
end

function BRTeam:Reset()
	-- deactivate team
	self.m_Active = false

	-- reset placement
	self.m_Placement = nil
end

---@param p_OtherTeam BRTeam
---@return boolean
function BRTeam:Equals(p_OtherTeam)
	return p_OtherTeam ~= nil and self.m_Id == p_OtherTeam.m_Id
end

---`==` metamethod
---@param p_OtherTeam BRTeam
---@return boolean
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
		NetEvents:SendToLocal(TeamManagerEvent.PutOnATeam, l_BrPlayer)
	end

	self.m_Players = {}

	-- if we have a voipchannel for this team, we want to close it
	if self.m_VoipChannel ~= nil then
		self:CloseVoipChannel()
	end
end

-- Garbage collector metamethod
function BRTeam:__gc()
	self:Destroy()
end
