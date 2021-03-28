require "__shared/Configs/ServerConfig"

class "Teammate"

function Teammate:__init(p_Name, p_State, p_IsTeamLeader, p_PosInSquad)
    self.m_Name = p_Name
    self.m_State = p_State or BRPlayerState.Alive -- TODO probably will be removed
    self.m_IsTeamLeader = p_IsTeamLeader or false
    self.m_PosInSquad = p_PosInSquad or 1
end

function Teammate:GetState()
    local l_Player = PlayerManager:GetPlayerByName(self.m_Name)
    if l_Player == nil or l_Player.soldier == nil or not l_Player.alive then
        return BRPlayerState.Dead
    elseif l_Player.soldier.isInteractiveManDown then
        return BRPlayerState.Down
    else
        return BRPlayerState.Alive
    end
end

function Teammate:GetColor(p_AsRgba)
    local l_Color = ServerConfig.PlayerColors[self.m_PosInSquad] or Vec4(1, 1, 1, 1)

    -- return color as Vec4
    if not p_AsRgba then
        return l_Color
    end

    -- return color as an rgba string
    return string.format("rgba(%s, %s, %s, %s)", l_Color.x * 255, l_Color.y * 255, l_Color.z * 255, l_Color.w)
end

function Teammate:FromTable(p_TeammateTable)
    return Teammate(p_TeammateTable.Name, p_TeammateTable.State, p_TeammateTable.IsTeamLeader, p_TeammateTable.PosInSquad)
end

function Teammate:AsTable()
    return {
        Name = self.m_Name,
        State = self:GetState(),
        IsTeamLeader = self.m_IsTeamLeader,
        PosInSquad = self.m_PosInSquad,
        Color = self:GetColor(true)
    }
end

class "BRTeam"

function BRTeam:__init(p_Id)
    -- the unique id of the team
    self.m_Id = p_Id or "-"

    -- indicates if the team let's random players to fill the remaining positions
    self.m_Locked = false

    -- the final placement of the team
    self.m_Placement = nil

    -- contains the players as Teammate[]
    self.m_Players = {}
end

function BRTeam:UpdateFromTable(p_BrTeamTable)
    self.m_Id = p_BrTeamTable.Id

    self.m_Locked = p_BrTeamTable.Locked
    self.m_Placement = p_BrTeamTable.Placement

    self.m_Players = {}
    for _, p_TeammateTable in ipairs(p_BrTeamTable.Players) do
        table.insert(self.m_Players, Teammate:FromTable(p_TeammateTable))
    end
end

function BRTeam.static:FromTable(p_BrTeamTable)
    local l_Team = BRTeam(p_BrTeamTable.Id)
    l_Team:UpdateFromTable(p_BrTeamTable)

    return l_Team
end

function BRTeam:PlayersTable()
    local l_PlayersData = {}
    for _, p_Teammate in ipairs(self.m_Players) do
        table.insert(l_PlayersData, p_Teammate:AsTable())
    end

    return l_PlayersData
end
