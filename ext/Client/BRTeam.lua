class "Teammate"

function Teammate:__init(p_Name, p_State)
    self.m_Name = p_Name
    self.m_State = p_State or BRPlayerState.Alive
end

function Teammate:FromTable(p_TeammateTable)
    return Teammate(p_TeammateTable.Name, p_TeammateTable.State)
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

function BRTeam.static:FromTable(p_BrTeamTable)
    local l_Team = BRTeam(p_BrTeamTable.Id)

    for _, p_TeammateTable in ipairs(p_BrTeamTable.Players) do
        table.insert(l_Team.m_Players, Teammate:FromTable(p_TeammateTable))
    end

    return l_Team
end

