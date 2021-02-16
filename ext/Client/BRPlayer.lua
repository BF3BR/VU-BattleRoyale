require "__shared/Enums/BRPlayerState"
require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/TeamManagerEvents"
require "__shared/Items/Armor"
require "BRTeam"

class "BRPlayer"

function BRPlayer:__init()
    self.m_Team = BRTeam()
    self.m_Armor = Armor:NoArmor()
    self.m_TeamJoinStrategy = TeamJoinStrategy.AutoJoin
    self.m_Kills = 0
    self.m_Score = 0

    self:RegisterEvents()
end

function BRPlayer:RegisterEvents()
    NetEvents:Subscribe("TM:PlayerState", self, self.OnPlayerState)
    NetEvents:Subscribe("TM:PlayerArmorState", self, self.OnPlayerState)
    NetEvents:Subscribe("TM:PlayerTeamState", self, self.OnPlayerState)
end

function BRPlayer:JoinTeam(p_Id)
    NetEvents:Send(TeamManagerNetEvents.RequestTeamJoin, p_Id)
end

function BRPlayer:LeaveTeam()
    NetEvents:Send(TeamManagerNetEvents.TeamLeave)
end

function BRPlayer:SetTeamJoinStrategy(p_Strategy)
    self.m_TeamJoinStrategy = p_Strategy
    NetEvents:Send(TeamManagerNetEvents.TeamJoinStrategy, p_Strategy)
end

function BRPlayer:OnPlayerState(p_State)
    if p_State.Team ~= nil then
        self.m_Team = BRTeam:FromTable(p_State.Team)
    end

    if p_State.Armor ~= nil then
        self.m_Armor = Armor:FromTable(p_State.Armor)
    end

    if p_State.Data ~= nil then
        self.m_Kills = p_State.Kills
        self.m_Score = p_State.Score
    end
end
