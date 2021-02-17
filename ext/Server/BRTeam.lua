require "__shared/Helpers/MapHelper"
require "__shared/Enums/TeamManagerEvents"

-- TODO move this to config
local MAX_NUMBER_OF_PLAYERS = 2

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

    -- update client state
    if not p_IgnoreBroadcast then
        self:BroadcastState()
    end

    -- check if team should be destroyed
    if MapHelper:Size(self.m_Players) < 1 then
        Events:DispatchLocal(TeamManagerCustomEvents.DestroyTeam, self)
    end

    return true
end

function BRTeam:Merge(p_OtherTeam)
    -- if self:PlayersNumber() < p_OtherTeam:PlayersNumber() then
    --     p_OtherTeam:Merge(self)
    --     return
    -- end

    -- check if merge is possible
    if self:PlayersNumber() + p_OtherTeam:PlayersNumber() > MAX_NUMBER_OF_PLAYERS then
        return false
    end

    -- move all the players from the other team
    for _, l_BrPlayer in pairs(p_OtherTeam.m_Players) do
        self:AddPlayer(l_BrPlayer, true)
    end

    self:BroadcastState()

    return true
end

function BRTeam:ToggleLock()
    -- TODO maybe add a check for squad leader only
    self.m_Locked = not self.m_Locked
    self:BroadcastState()
end

-- Applies team/squad ids to each player of the team
function BRTeam:ApplyTeamSquadIds(p_TeamId, p_SquadId)
    self.m_TeamId = (p_TeamId ~= nil and p_TeamId) or self.m_TeamId
    self.m_SquadId = (p_SquadId ~= nil and p_SquadId) or self.m_SquadId

    -- update team/squad ids for each player
    for _, l_BrPlayer in pairs(self.m_Players) do
        l_BrPlayer:ApplyTeamSquadIds()
    end
end

-- Checks if the team is full and has no space for more players
function BRTeam:IsFull()
    return MapHelper:Size(self.m_Players) >= MAX_NUMBER_OF_PLAYERS
end

-- Checks if the team has any players
function BRTeam:IsEmpty()
    return MapHelper:Empty(self.m_Players)
end

function BRTeam:PlayersNumber()
    return MapHelper:Size(self.m_Players)
end

-- Checks if the team has any alive players
-- @param p_PlayerToIgnore (optional)
function BRTeam:HasAlivePlayers(p_PlayerToIgnore)
    for _, l_BrPlayer in pairs(self.m_Players) do
        if l_BrPlayer.m_Player.alive and (p_PlayerToIgnore == nil or not l_BrPlayer:Equals(p_PlayerToIgnore)) then
            return true
        end
    end

    return false
end

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
        Players = l_Players
    }
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
        Events:SendLocal(TeamManagerCustomEvents.PutOnATeam, l_BrPlayer)
    end

    self.m_Players = {}
end

-- garbage collector metamethod
function BRTeam:__gc()
    self:Destroy()
end
