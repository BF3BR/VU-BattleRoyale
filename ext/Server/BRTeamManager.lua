require "__shared/Enums/TeamManagerEvents"
require "BRTeam"
require "BRPlayer"

class "BRTeamManager"

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
    Events:Subscribe("Player:Authenticated", self, self.OnVanillaPlayerCreated)
    Events:Subscribe("Player:Destroyed", self, self.OnVanillaPlayerDestroyed)
    Events:Subscribe("TM:PutOnATeam", self, self.OnPutOnATeam)
    Events:Subscribe("TM:DestroyTeam", self, self.OnDestroyTeam)
    NetEvent:Subscribe(TeamManagerNetEvents.RequestTeamJoin, self, self.OnRequestTeamJoin)
    NetEvent:Subscribe(TeamManagerNetEvents.TeamLeave, self, self.OnLeaveTeam)
end

-- Returns the BRPlayer instance of a player
--
-- @param p_Player Player|BRPlayer|string
-- @return BRPlayer|nil
function BRTeamManager:GetPlayer(p_Player)
    return self.m_Players[BRPlayer:GetPlayerName(p_Player)]
end

-- Returns a team by it's id
--
-- @param p_Id string
-- @return BRTeam|nil
function BRTeamManager:GetTeam(p_Id)
    return self.m_Teams[p_Id]
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

    return l_Winner
end

-- Assigns a team to each player
function BRTeamManager:AssignTeams()
    for _, l_BrPlayer in pairs(self.m_Players) do
        if l_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
            if l_BrPlayer:LeaveTeam() then
                self:CreateTeam():AddPlayer(l_BrPlayer)
            end

            if l_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.NoJoin then
                l_BrPlayer.m_Team.m_Locked = true
            end
        end
    end
end

-- Creates a BRTeam
function BRTeamManager:CreateTeam()
    -- create team and add it's reference
    local l_Team = BRTeam(self:CreateId())
    self.m_Teams[l_Team.m_Id] = l_Team

    return l_Team
end

-- Removes a BRTeam
function BRTeamManager:RemoveTeam(p_Team)
    -- clear reference and destroy team
    self.m_Teams[p_Team.m_Id] = nil
    p_Team:Destroy()
end

-- Creates a BRPlayer instance for the specified player
function BRTeamManager:CreatePlayer(p_Player)
    local l_Name = p_Player.name

    -- check if BRPlayer already exists
    if self.m_Players[l_Name] ~= nil then
        return self.m_Players[l_Name]
    end

    -- create player
    local l_Player = BRPlayer(p_Player)
    self.m_Players[l_Name] = l_Player

    -- create a team and put the player in it
    local l_Team = self:CreateTeam():AddPlayer(l_Player)

    -- create and return the BRPlayer
    return l_Player
end

-- Removes a BRPlayer
function BRTeamManager:RemovePlayer(p_Player)
    local l_BrPlayer = self:GetPlayer(p_Player)

    if l_BrPlayer ~= nil then
        self.m_Players[l_BrPlayer:GetName()] = nil
        l_BrPlayer:Destroy()
    end
end

-- Kills every player
function BRTeamManager:KillAllPlayers()
    for _, l_BrPlayer in pairs(self.m_Players) do
        l_BrPlayer:Kill(true)
    end
end

-- Create a unique BRTeam id
function BRTeamManager:CreateId(p_Len)
    p_Len = p_Len or 4

    while true do
        local l_Id = MathUtils:RandomGuid():ToString("N"):sub(1, p_Len)
        if self.m_Teams[l_Id] == nil then
            return l_Id
        end
    end
end

function BRTeamManager:OnVanillaPlayerCreated(p_Player)
    print(string.format("TM: Creating BRPlayer for '%s'", p_Player.name))
    self:CreatePlayer(p_Player)
end

function BRTeamManager:OnVanillaPlayerDestroyed(p_Player)
    print(string.format("TM: Destroying BRPlayer for '%s'", p_Player.name))
    self:RemovePlayer(p_Player)
end

-- Puts the requested player to a newly created team
function BRTeamManager:OnPutOnATeam(p_BrPlayer)
    self:CreateTeam():AddPlayer(p_BrPlayer)
end

-- Destroys and removes the specified team
function BRTeamManager:OnDestroyTeam(p_Team)
    self:RemoveTeam(p_Team)
end

function BRTeamManager:OnRequestTeamJoin(p_Player, p_Id)
    local l_BrPlayer = self:GetPlayer(p_Player)
    local l_Team = self:GetTeam(p_Id)

    -- check if team/player not found
    if l_Team == nil or l_BrPlayer == nil then
        NetEvents:SendToLocal(TeamManagerNetEvents.TeamJoinDenied, p_Player, TeamManagerErrors.InvalidTeamId)
    end

    -- add player to the team
    if not l_Team:AddPlayer(l_BrPlayer) then
        NetEvents:SendToLocal(TeamManagerNetEvents.TeamJoinDenied, p_Player, TeamManagerErrors.TeamIsFull)
    end
end

function BRTeamManager:OnLeaveTeam(p_Player)
    local l_BrPlayer = self:GetPlayer(p_Player)
    l_BrPlayer:LeaveTeam()
end

g_BRTeamManager = BRTeamManager()
