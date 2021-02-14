require "__shared/Enums/BRPlayerState"
require "BRTeam"

class "LocalBRPlayer"

function LocalBRPlayer:__init()
    self.m_Armor = Armor:NoArmor()
    self.m_Kills = 0
    self.m_Score = 0
    self.m_Team = BRTeam()
end

class "OtherBRPlayer"

function OtherBRPlayer:__init(p_Name)
    self.m_Name = p_Name
    self.m_State = BRPlayerState.Alive
end
