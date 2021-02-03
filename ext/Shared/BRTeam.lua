class "BRTeam"

function BRTeam:__init(p_Id, p_Code)
    self.m_Id = p_Id or 0
    self.m_Code = p_Code or ""

    self.m_Players = {}
    self.m_TeamId = TeamId.Team1
    self.m_SquadId = SquadId.SquadNone
end

function BRTeam:IsEqual(p_OtherTeam)
    -- return p_OtherTeam ~= nil and
    --     self.m_SquadId > 0 and
    --     self.m_TeamId == p_OtherTeam.m_TeamId and
    --     self.m_SquadId == p_OtherTeam.m_SquadId

    return p_OtherTeam ~= nil and self.m_Id == p_OtherTeam.m_Id
end

function BRTeam:__gc()
    self:Destroy()
end

function BRTeam:Destroy()
    self.m_Players = {}
end
