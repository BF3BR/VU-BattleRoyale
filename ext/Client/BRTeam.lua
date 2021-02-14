class "BRTeam"

function BRTeam:__init()
    -- the unique id of the team
    self.m_Id = p_Id

    -- contains the players as [name] -> [OtherBRPlayer]
    self.m_Players = {}

    -- vanilla team/squad ids
    self.m_TeamId = TeamId.Team1
    self.m_SquadId = SquadId.SquadNone
end
