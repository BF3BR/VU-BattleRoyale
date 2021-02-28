require "__shared/Enums/TeamManagerEvents"
require "__shared/Enums/PhaseManagerEvents"
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
    Events:Subscribe("Player:Left", self, self.OnVanillaPlayerDestroyed)
    Events:Subscribe("Player:Killed", self, self.OnSendPlayerState)

    Events:Subscribe(TeamManagerCustomEvents.PutOnATeam, self, self.OnPutOnATeam)
    Events:Subscribe(TeamManagerCustomEvents.DestroyTeam, self, self.OnDestroyTeam)

    NetEvents:Subscribe(PhaseManagerNetEvents.InitialState, self, self.OnSendPlayerState)
    NetEvents:Subscribe(TeamManagerNetEvents.RequestTeamJoin, self, self.OnRequestTeamJoin)
    NetEvents:Subscribe(TeamManagerNetEvents.TeamLeave, self, self.OnLeaveTeam)
    NetEvents:Subscribe(TeamManagerNetEvents.TeamToggleLock, self, self.OnLockToggle)
    NetEvents:Subscribe(TeamManagerNetEvents.TeamJoinStrategy, self, self.OnTeamJoinStrategy)
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
        return p_TeamA:PlayersNumber() < p_TeamB:PlayersNumber()
    end)

    -- merge teams
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
    for _, l_BrTeam in pairs(self.m_Teams) do
        l_BrTeam.m_Active = true

        -- assign team/squad ids for each BRTeam
        if l_BrTeam:PlayersNumber() < 2 then
            l_BrTeam.m_TeamId = TeamId.Team1
            l_BrTeam.m_SquadId = SquadId.SquadNone
        else
            l_BrTeam.m_TeamId = math.floor(l_Index / 32) + 1
            l_BrTeam.m_SquadId = l_Index % 32 + 1

            l_Index = l_Index + 1
        end

        l_BrTeam:ApplyTeamSquadIds()
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
    local l_BrPlayer = BRPlayer(p_Player)
    self.m_Players[l_Name] = l_BrPlayer

    -- create a team and put the player in it
    self:CreateTeamWithPlayer(l_BrPlayer)

    -- create and return the BRPlayer
    return l_BrPlayer
end

-- Removes a BRPlayer
function BRTeamManager:RemovePlayer(p_Player)
    local l_BrPlayer = self:GetPlayer(p_Player)

    if l_BrPlayer ~= nil then
        self.m_Players[l_BrPlayer:GetName()] = nil
        l_BrPlayer:Destroy()
    end
end

function BRTeamManager:CreateTeamWithPlayer(p_BrPlayer)
    local l_Team = self:CreateTeam()

    if p_BrPlayer.m_TeamJoinStrategy == TeamJoinStrategy.Custom then
        l_Team.m_Locked = false
    else
        l_Team.m_Locked = true
    end

    l_Team:AddPlayer(p_BrPlayer)
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

function BRTeamManager:EndOfRound()
    -- put non custom team players back to their own teams
    for _, l_BrPlayer in pairs(self.m_Players) do
        if l_BrPlayer.m_TeamJoinStrategy ~= TeamJoinStrategy.Custom then
            if l_BrPlayer:LeaveTeam() then
                self:CreateTeamWithPlayer(l_BrPlayer)
            end
        end
    end

    -- deactivate teams
    for _, l_BrTeam in pairs(self.m_Teams) do
        l_BrTeam.m_Active = false
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
    self:CreateTeamWithPlayer(p_BrPlayer)
end

-- Destroys and removes the specified team
function BRTeamManager:OnDestroyTeam(p_Team)
    self:RemoveTeam(p_Team)
end

function BRTeamManager:OnRequestTeamJoin(p_Player, p_Id)
    local l_BrPlayer = self:GetPlayer(p_Player)
    local l_Team = self:GetTeam(p_Id)

    -- check if team/player not found
    if l_BrPlayer == nil or l_Team == nil or (not l_Team:CanBeJoinedById()) then
        NetEvents:SendToLocal(TeamManagerNetEvents.TeamJoinDenied, p_Player, TeamManagerErrors.InvalidTeamId)
        return
    end

    -- add player to the team
    if not l_Team:AddPlayer(l_BrPlayer) then
        NetEvents:SendToLocal(TeamManagerNetEvents.TeamJoinDenied, p_Player, TeamManagerErrors.TeamIsFull)
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

g_BRTeamManager = BRTeamManager()
