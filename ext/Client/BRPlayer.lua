require "__shared/Enums/BRPlayerState"
require "__shared/Enums/TeamJoinStrategy"
require "__shared/Enums/CustomEvents"
require "__shared/Items/Armor"
require "BRTeam"

class "BRPlayer"

function BRPlayer:__init()
    self.m_Team = BRTeam()
    self.m_Armor = Armor:NoArmor()
    self.m_IsTeamLeader = false
    self.m_TeamJoinStrategy = TeamJoinStrategy.AutoJoin
    self.m_Kills = 0
    self.m_Score = 0

    self:RegisterEvents()
end

function BRPlayer:RegisterEvents()
    NetEvents:Subscribe(TeamManagerNetEvent.PlayerState, self, self.OnReceivePlayerState)
    NetEvents:Subscribe(TeamManagerNetEvent.PlayerArmorState, self, self.OnReceivePlayerState)
    NetEvents:Subscribe(TeamManagerNetEvent.PlayerTeamState, self, self.OnReceivePlayerState)
end

function BRPlayer:JoinTeam(p_Id)
    NetEvents:Send(TeamManagerNetEvent.RequestTeamJoin, p_Id)
end

function BRPlayer:LeaveTeam()
    NetEvents:Send(TeamManagerNetEvent.TeamLeave)
end

function BRPlayer:SetTeamJoinStrategy(p_Strategy)
    self.m_TeamJoinStrategy = p_Strategy
    NetEvents:Send(TeamManagerNetEvent.TeamJoinStrategy, p_Strategy)
end

function BRPlayer:ToggleLock()
    NetEvents:Send(TeamManagerNetEvent.TeamToggleLock)
end

function BRPlayer:OnReceivePlayerState(p_State)
    if p_State.Team ~= nil then
        self.m_Team:UpdateFromTable(p_State.Team)
    end

    if p_State.Armor ~= nil then
        self.m_Armor:UpdateFromTable(p_State.Armor)
    end

    if p_State.Data ~= nil then
        self.m_IsTeamLeader = p_State.Data.IsTeamLeader
        self.m_TeamJoinStrategy = p_State.Data.TeamJoinStrategy
        self.m_Kills = p_State.Data.Kills
        self.m_Score = p_State.Data.Score
    end
end
