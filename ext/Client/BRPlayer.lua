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
	self.m_PosInSquad = 1

	self:RegisterEvents()
end

function BRPlayer:RegisterEvents()
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerState, self, self.OnReceivePlayerState)
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerArmorState, self, self.OnReceivePlayerState)
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerTeamState, self, self.OnReceivePlayerState)
end

-- =============================================
-- Events
-- =============================================

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
		self.m_PosInSquad = p_State.Data.PosInSquad
	end
end

-- =============================================
-- Functions
-- =============================================

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

function BRPlayer:GetState()
	local l_Player = PlayerManager:GetLocalPlayer()
	if l_Player == nil or l_Player.soldier == nil or not l_Player.alive then
		return BRPlayerState.Dead
	elseif l_Player.soldier.isInteractiveManDown then
		return BRPlayerState.Down
	else
		return BRPlayerState.Alive
	end
end

function BRPlayer:GetColor(p_AsRgba)
	local l_Color = ServerConfig.PlayerColors[self.m_PosInSquad] or Vec4(1, 1, 1, 1)

	-- return color as Vec4
	if not p_AsRgba then
		return l_Color
	end

	-- return color as an rgba string
	return string.format("rgba(%s, %s, %s, %s)", l_Color.x * 255, l_Color.y * 255, l_Color.z * 255, l_Color.w)
end
