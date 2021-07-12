require "__shared/Configs/ServerConfig"

-- =============================================
-- Teammate Class
-- =============================================

class "Teammate"

function Teammate:__init(p_Name, p_State, p_IsTeamLeader, p_PosInSquad)
	self.m_Name = p_Name
	self.m_State = p_State or BRPlayerState.Alive -- TODO probably will be removed
	self.m_IsTeamLeader = p_IsTeamLeader or false
	self.m_PosInSquad = p_PosInSquad or 1
end

function Teammate:GetState()
	local s_Player = PlayerManager:GetPlayerByName(self.m_Name)

	if s_Player == nil or s_Player.soldier == nil or not s_Player.alive then
		return BRPlayerState.Dead
	elseif s_Player.soldier.isInteractiveManDown then
		return BRPlayerState.Down
	else
		return BRPlayerState.Alive
	end
end

function Teammate:GetColor(p_AsRgba)
	local s_Color = ServerConfig.PlayerColors[self.m_PosInSquad] or Vec4(1, 1, 1, 1)

	-- return color as Vec4
	if not p_AsRgba then
		return s_Color
	end

	-- return color as an rgba string
	return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

function Teammate:GetPosition()
	local s_Player = PlayerManager:GetPlayerByName(self.m_Name)

	if s_Player == nil then
		return nil
	end

	if s_Player.soldier == nil then
		return
	end

	return {
		x = s_Player.soldier.transform.trans.x,
		y = s_Player.soldier.transform.trans.y,
		z = s_Player.soldier.transform.trans.z
	}
end

function Teammate:GetYaw()
	local s_Player = PlayerManager:GetPlayerByName(self.m_Name)

	if s_Player == nil then
		return nil
	end

	if s_Player.soldier == nil then
		return nil
	end

	local s_YawRad = (math.atan(s_Player.soldier.worldTransform.forward.z, s_Player.soldier.worldTransform.forward.x) - (math.pi / 2)) % (2 * math.pi)
	return math.floor((180 / math.pi) * s_YawRad)
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
		Color = self:GetColor(true),
		ColorVec = self:GetColor(false),
		Position = self:GetPosition(),
		Yaw = self:GetYaw(),
	}
end

-- =============================================
-- BRTeam Class
-- =============================================

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
	local s_Team = BRTeam(p_BrTeamTable.Id)
	s_Team:UpdateFromTable(p_BrTeamTable)

	return s_Team
end

function BRTeam:PlayersTable()
	local s_PlayersData = {}

	for _, l_Teammate in ipairs(self.m_Players) do
		table.insert(s_PlayersData, l_Teammate:AsTable())
	end

	return s_PlayersData
end
