-- =============================================
-- Teammate Class
-- =============================================

---@class Teammate
local Teammate = class "Teammate"

---Creates a new Teammate
---@param p_Name string
---@param p_State BRPlayerState|integer
---@param p_IsTeamLeader boolean
---@param p_PosInSquad integer
function Teammate:__init(p_Name, p_State, p_IsTeamLeader, p_PosInSquad)
	self.m_Name = p_Name
	---@type BRPlayerState|integer
	self.m_State = p_State or BRPlayerState.Alive -- TODO probably will be removed
	self.m_IsTeamLeader = p_IsTeamLeader or false
	self.m_PosInSquad = p_PosInSquad or 1
end

---Returns the current player state
---@return BRPlayerState|integer
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

---Returns a color as Vec4 or as string in css format
---@param p_AsRgba boolean
---@return Vec4|string
function Teammate:GetColor(p_AsRgba)
	local s_Color = ServerConfig.PlayerColors[self.m_PosInSquad] or Vec4(1.0, 1.0, 1.0, 1.0)

	-- return color as Vec4
	if not p_AsRgba then
		return s_Color
	end

	-- return color as an rgba string
	return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

---Returns the current position as a table
---@return table<'x'|'y'|'z', number>
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

-- TODO: What is the range? (0-360)? Add to the comment
---Returns the yaw or nil
---@return integer|nil @Range
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

---Returns the health or zero
---@return number
function Teammate:GetHealth()
	local s_Player = PlayerManager:GetPlayerByName(self.m_Name)

	if s_Player == nil then
		return 0.0
	end

	if s_Player.soldier == nil then
		return 0.0
	end

	return s_Player.soldier.health
end

---Returns a new Teammate
---@param p_TeammateTable table
---@return Teammate
function Teammate:FromTable(p_TeammateTable)
	return Teammate(p_TeammateTable.Name, p_TeammateTable.State, p_TeammateTable.IsTeamLeader, p_TeammateTable.PosInSquad)
end

---Returns the Teammate as a table
---@return table
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
		Health = self:GetHealth(),
	}
end

-- =============================================
-- BRTeam Class
-- =============================================

---@class BRTeam
local BRTeam = class "BRTeam"

---Creates a new BRTeam. Your BRTeam.
---@param p_Id string|nil
function BRTeam:__init(p_Id)
	-- the unique id of the team
	self.m_Id = p_Id or "-"

	-- indicates if the team let's random players to fill the remaining positions
	self.m_Locked = false

	-- the final placement of the team
	---@type integer|nil
	self.m_Placement = nil

	-- contains the players as Teammate[]
	---@type Teammate[]
	self.m_Players = {}
end

---Updates the whole BRTeam
---@param p_BrTeamTable table
function BRTeam:UpdateFromTable(p_BrTeamTable)
	self.m_Id = p_BrTeamTable.Id

	self.m_Locked = p_BrTeamTable.Locked
	self.m_Placement = p_BrTeamTable.Placement

	self.m_Players = {}

	for _, p_TeammateTable in ipairs(p_BrTeamTable.Players) do
		table.insert(self.m_Players, Teammate:FromTable(p_TeammateTable))
	end
end

---Creates a new BRTeam from table
---@param p_BrTeamTable table
---@return BRTeam
function BRTeam.static:FromTable(p_BrTeamTable)
	---@type BRTeam
	local s_Team = BRTeam(p_BrTeamTable.Id)
	s_Team:UpdateFromTable(p_BrTeamTable)

	return s_Team
end

---Returns a table with all Teammates as tables
---@return table[]
function BRTeam:PlayersTable()
	local s_PlayersData = {}

	for _, l_Teammate in ipairs(self.m_Players) do
		table.insert(s_PlayersData, l_Teammate:AsTable())
	end

	return s_PlayersData
end
