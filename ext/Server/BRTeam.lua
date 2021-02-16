require "__shared/Helpers/MapHelper"
require "__shared/Enums/TeamManagerEvents"

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
function BRTeam:AddPlayer(p_BrPlayer)
    -- check if team is full
    if self:IsFull() then
        return false
    end

    -- check if player is already in a team
    if p_BrPlayer.m_Team ~= nil then
        -- check if already in this team
        if self:Equals(p_BrPlayer.m_Team) then
            return true
        end

        -- remove player from old team
        p_BrPlayer:LeaveTeam(true)
    end

    -- add player
    self.m_Players[p_BrPlayer:GetName()] = p_BrPlayer
    p_BrPlayer:SetTeam(self)
    return true
end

-- Removes a player from the team
function BRTeam:RemovePlayer(p_BrPlayer)
    -- check if player isn't a member of this team
    if p_BrPlayer.m_Team == nil or not self:Equals(p_BrPlayer.m_Team) then
        return
    end

    -- remove player reference
    self.m_Players[p_BrPlayer:GetName()] = nil

    -- check if team should be destroyed
    if MapHelper:Size(self.m_Players) < 1 then
        Events:DispatchLocal(TeamManagerCustomEvents.DestroyTeam, self)
        return
    end

    -- TODO send event to update team state
end

-- Removes all players from the team
function BRTeam:RemovePlayers(p_IgnoreDestroyEvent)
    -- remove players from the team
    for l_Name, l_BrPlayer in pairs(self.m_Players) do
        l_BrPlayer:LeaveTeam()
        self.m_Players[l_Name] = nil
    end

    self.m_Players = {}
end

function BRTeam:SendState()
    for _, l_BrPlayer in pairs(self.m_Players) do
        l_BrPlayer:SendState()
    end
end

function BRTeam:AsTable()

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
    -- TODO move this to config
    local MAX_NUMBER_OF_PLAYERS = 2

    return MapHelper:Size(self.m_Players) >= MAX_NUMBER_OF_PLAYERS
end

-- Checks if the team has any players
function BRTeam:HasPlayers()
    return not MapHelper:Empty(self.m_Players)
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

function BRTeam:Equals(p_OtherTeam)
    return p_OtherTeam ~= nil and self.m_Id == p_OtherTeam.m_Id
end

function BRTeam:__eq(p_OtherTeam)
    return self:Equals(p_OtherTeam)
end

function BRTeam:Destroy()
    self:RemovePlayers()
end

function BRTeam:__gc()
    self:Destroy()
end
