class "BRTeam"

function BRTeam:__init(p_Id, p_Code)
    self.m_Id = p_Id or 0
    self.m_Code = p_Code or ""

    self.m_Players = {}
    self.m_TeamId = TeamId.Team1
    self.m_SquadId = SquadId.SquadNone
end

function BRTeam:AddPlayer(p_BrPlayer)
    -- TODO add team is full check
    -- if #self.m_Players >= TEAM_PLAYERS_N then
    --     return
    -- end

    -- check if member of a team
    if p_BrPlayer.m_Team ~= nil then
        -- check if already in this team
        if self:IsEqual(p_BrPlayer.m_Team) then
            return
        end

        -- remove player from old team
        p_BrPlayer.m_Team:RemovePlayer(p_BrPlayer)
    end

    -- add player
    table.insert(self.m_Players, p_BrPlayer)
    p_BrPlayer:SetTeam(self)
end

function BRTeam:RemovePlayer(p_BrPlayer)
    -- check if player isn't a member of this team
    if p_BrPlayer.m_Team == nil or not self:IsEqual(p_BrPlayer.m_Team) then
        return
    end

    -- remove player
    table.remove(self.m_Players, p_BrPlayer)
    p_BrPlayer:SetTeam(nil)
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
