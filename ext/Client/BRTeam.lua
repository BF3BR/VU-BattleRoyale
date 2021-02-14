class "BRTeam"

function BRTeam:__init(p_Id)
    -- the unique id of the team
    self.m_Id = p_Id or "-"

    -- contains the players as OtherBRPlayer[]
    self.m_Players = {}
end
