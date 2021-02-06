require '__shared/BRTeam'
require '__shared/BRPlayer'

class 'BRTeamManager'

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
    Events:Subscribe('Player:Created', self, self.OnPlayerCreated)
    Events:Subscribe('Player:Destroyed', self, self.OnPlayerDestroyed)
end

function BRTeamManager:OnPlayerCreated(p_Player)
    table.insert(self.m_Players, BRPlayer(p_Player))
end

function BRTeamManager:OnPlayerDestroyed(p_Player)
    local l_BrPlayer = self:GetBrPlayer(p_Player.name)
    l_BrPlayer:LeaveTeam()

    self.m_Players[p_Player.name] = nil
end

function BRTeamManager:GetById(p_Id)
    for _, l_Team in ipairs(self.m_Teams) do
        if l_Team.m_Id == p_Id then
            return l_Team
        end
    end

    return nil
end

function BRTeamManager:GetByCode(p_Code)
    for _, l_Team in ipairs(self.m_Teams) do
        if l_Team.m_Code == p_Code then
            return l_Team
        end
    end

    return nil
end

function BRTeamManager:GetOrCreateByCode(p_Code)
    return self:GetByCode(p_Code) or self:CreateTeam(p_Code)
end

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

function BRTeamManager:CreateTeam(p_Code)
    -- create team
    self.m_LastTeamId = self.m_LastTeamId + 1
    local l_Team = BRTeam(self.m_LastTeamId, p_Code)

    -- add it into the rest
    table.insert(self.m_Teams, l_Team)

    return l_Team
end

function BRTeamManager:RemoveTeam(p_Team)
    -- remove players from team
end

function BRTeamManager:AddPlayerToTeam(p_Player, p_Team)
    -- TODO
end

function BRTeamManager:GetBrPlayer(p_PlayerName)
    return self.m_Players[p_PlayerName]
end

function BRTeamManager:GetTeamByPlayer(p_Player)
    local l_Name = p_Player.name or p_Player.m_Player.name
    return self:GetTeamByPlayerName(l_Name)
end

function BRTeamManager:GetTeamByPlayerName(p_PlayerName)
    return self.m_Players[p_PlayerName].m_Team
end

function BRTeamManager:KillAllPlayers()
    for _, l_Player in pairs(self.m_Players) do
        l_Player:Kill(true)
    end
end
