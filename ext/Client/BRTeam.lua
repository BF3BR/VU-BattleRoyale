class "Teammate"

function Teammate:__init(p_Name, p_State, p_IsTeamLeader)
    self.m_Name = p_Name
    self.m_State = p_State or BRPlayerState.Alive
    self.m_IsTeamLeader = p_IsTeamLeader or false
end

function Teammate:FromTable(p_TeammateTable)
    return Teammate(p_TeammateTable.Name, p_TeammateTable.State, p_TeammateTable.IsTeamLeader)
end

function Teammate:AsTable()
    return {
        Name = self.m_Name,
        State = self.m_State,
        IsTeamLeader = self.m_IsTeamLeader,
    }
end

class "BRTeam"

function BRTeam:__init(p_Id)
    -- the unique id of the team
    self.m_Id = p_Id or "-"

    -- indicates if the team let's random players to fill the remaining positions
    self.m_Locked = false

    -- contains the players as Teammate[]
    self.m_Players = {}
end

function BRTeam:UpdateFromTable(p_BrTeamTable)
    self.m_Id = p_BrTeamTable.Id

    self.m_Locked = p_BrTeamTable.Locked

    self.m_Players = {}
    for _, p_TeammateTable in ipairs(p_BrTeamTable.Players) do
        table.insert(self.m_Players, Teammate:FromTable(p_TeammateTable))
    end
end

function BRTeam.static:FromTable(p_BrTeamTable)
    local l_Team = BRTeam(p_BrTeamTable.Id)

    l_Team.m_Locked = p_BrTeamTable.Locked

    for _, p_TeammateTable in ipairs(p_BrTeamTable.Players) do
        table.insert(l_Team.m_Players, Teammate:FromTable(p_TeammateTable))
    end

    return l_Team
end

function BRTeam:PlayersTable()
    local l_PlayersData = {}
    for _, p_Teammate in ipairs(self.m_Players) do
        table.insert(l_PlayersData, p_Teammate:AsTable())
    end

    return l_PlayersData
end
