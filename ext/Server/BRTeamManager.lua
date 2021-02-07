require "__shared/BRTeam"
require "__shared/BRPlayer"

class "BRTeamManager"

function BRTeamManager:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function BRTeamManager:RegisterVars()
    self.m_LastTeamId = 0
    self.m_Teams = {}
    self.m_Players = {}
end

function BRTeamManager:RegisterEvents()
    Events:Subscribe("Player:Authenticated", self, self.OnPlayerCreated)
    Events:Subscribe("Player:Destroyed", self, self.OnPlayerDestroyed)
end

function BRTeamManager:OnPlayerCreated(p_Player)
    print(string.format("TM: Creating BRPlayer for '%s'", p_Player.name))
    self.m_Players[p_Player.name] = BRPlayer(p_Player)
end

function BRTeamManager:OnPlayerDestroyed(p_Player)
    local l_BrPlayer = self.m_Players[p_Player.name]

    if l_BrPlayer ~= nil then
        print(string.format("TM: Destroying BRPlayer for '%s'", p_Player.name))
        l_BrPlayer:LeaveTeam()
        self.m_Players[p_Player.name] = nil
    end
end

-- Returns the team by it's id
function BRTeamManager:GetById(p_Id)
    for _, l_Team in ipairs(self.m_Teams) do
        if l_Team.m_Id == p_Id then
            return l_Team
        end
    end

    return nil
end

-- Returns the team by it's code
function BRTeamManager:GetByCode(p_Code)
    for _, l_Team in ipairs(self.m_Teams) do
        if l_Team.m_Code == p_Code then
            return l_Team
        end
    end

    return nil
end

-- Returns an existing team by it's code or creates a new one if none is found
function BRTeamManager:GetOrCreateByCode(p_Code)
    return self:GetByCode(p_Code) or self:CreateTeam(p_Code)
end

-- Returns the team that won the match.
-- Returns nill if more that one teams are currently alive.
function BRTeamManager:GetWinner()
    local l_Winner = nil
    local l_TeamsAlive = 0

    for _, l_Team in ipairs(self.m_Teams) do
        if l_Team:HasAlivePlayers() then
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
    -- assigns everyone as solo player for now
    for _, p_BrPlayer in pairs(self.m_Players) do
        if p_BrPlayer.m_Team == nil then
            local l_Team = self:CreateTeam()
            l_Team:AddPlayer(p_BrPlayer)
            table.insert(self.m_Teams, l_Team)
        end
    end
end

-- Creates a team
-- @param p_Code (optional)
function BRTeamManager:CreateTeam(p_Code)
    -- create team
    self.m_LastTeamId = self.m_LastTeamId + 1
    local l_Team = BRTeam(self.m_LastTeamId, p_Code)

    -- add it into the rest
    table.insert(self.m_Teams, l_Team)

    return l_Team
end

-- Removes a team
function BRTeamManager:RemoveTeam(p_Team)
    -- remove players from team
end

function BRTeamManager:AddPlayerToTeam(p_Player, p_Team)
    -- TODO
end

-- Returns the BRPlayer instance of a player
-- @param p_Player can be the username or the vanilla player object
function BRTeamManager:GetBrPlayer(p_Player)
    return self.m_Players[BRPlayer:GetPlayerName(p_Player)]
end

-- Kills every player
function BRTeamManager:KillAllPlayers()
    for _, l_Player in pairs(self.m_Players) do
        l_Player:Kill(true)
    end
end
