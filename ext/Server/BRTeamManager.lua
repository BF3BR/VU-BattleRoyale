require "__shared/BRTeam"
require "__shared/BRPlayer"

class "BRTeamManager"

function BRTeamManager:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function BRTeamManager:RegisterVars()
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

-- Create a unique BRTeam id
function BRTeamManager:CreateId()
    while true do
        local l_Id = MathUtils:RandomGuid():ToString('N'):sub(1, 4)
        if self.m_Teams[l_Id] == nil then return l_Id end
    end
end

-- Returns the team by it's id
function BRTeamManager:GetById(p_Id)
    return self.m_Teams[p_Id]
end

-- Returns the team that won the match.
-- Returns nill if more that one teams are currently alive.
function BRTeamManager:GetWinningTeam()
    local l_Winner = nil
    local l_TeamsAlive = 0

    for _, l_Team in pairs(self.m_Teams) do
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
    for _, l_BrPlayer in pairs(self.m_Players) do
        local l_Team = l_BrPlayer.m_Team or self:CreateTeam()

        l_Team:AddPlayer(l_BrPlayer)
        l_Team:SetTeamSquadIds(TeamId.Team1, SquadId.SquadNone)
    end
end

-- Creates a BRTeam
function BRTeamManager:CreateTeam()
    -- create team
    local l_Team = BRTeam(self:CreateId())

    -- add it into the rest
    self.m_Teams[l_Team.m_Id] = l_Team
    return l_Team
end

-- Removes a BRTeam
function BRTeamManager:RemoveTeam(p_Team)
    -- clear reference
    self.m_Teams[p_Team.m_Id] = nil

    p_Team:RemovePlayers()
    p_Team:Destroy()
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
