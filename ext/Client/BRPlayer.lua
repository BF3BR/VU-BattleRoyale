---@class BRPlayer
BRPlayer = class "BRPlayer"

local m_Logger = Logger("BRPlayer", false)

function BRPlayer:__init()
	---@type BRTeam
	self.m_Team = BRTeam()
	---@type BRInventory
	self.m_Inventory = BRInventory()
	self.m_IsTeamLeader = false
	---@type TeamJoinStrategy|integer
	self.m_TeamJoinStrategy = TeamJoinStrategy.AutoJoin
	self.m_PosInSquad = 1

	self:ResetVars()
	self:RegisterEvents()
end

function BRPlayer:ResetVars()
	self.m_Kills = 0
	self.m_Score = 0
end

function BRPlayer:RegisterEvents()
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerState, self, self.OnReceivePlayerState)
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerArmorState, self, self.OnReceivePlayerState)
	NetEvents:Subscribe(TeamManagerNetEvent.PlayerTeamState, self, self.OnReceivePlayerState)
end

-- =============================================
-- Events
-- =============================================

---Custom Client NetEvents:
---TeamManagerNetEvent.PlayerState
---TeamManagerNetEvent.PlayerArmorState
---TeamManagerNetEvent.PlayerTeamState
---@param p_State table
function BRPlayer:OnReceivePlayerState(p_State)
	if p_State.Team ~= nil then
		self.m_Team:UpdateFromTable(p_State.Team)
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

---Attempt to join a team
---@param p_Id string @Guid as string
function BRPlayer:JoinTeam(p_Id)
	NetEvents:Send(TeamManagerNetEvent.RequestTeamJoin, p_Id)
end

---Leave the current team
function BRPlayer:LeaveTeam()
	NetEvents:Send(TeamManagerNetEvent.TeamLeave)
end

---Change the team join behaviour
---@param p_Strategy TeamJoinStrategy|integer
function BRPlayer:SetTeamJoinStrategy(p_Strategy)
	self.m_TeamJoinStrategy = p_Strategy
	NetEvents:Send(TeamManagerNetEvent.TeamJoinStrategy, p_Strategy)
end

---Lock/ Unlock your team
function BRPlayer:ToggleLock()
	NetEvents:Send(TeamManagerNetEvent.TeamToggleLock)
end

---Returns the current player state
---@return BRPlayerState|integer
function BRPlayer:GetState()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil or s_LocalPlayer.soldier == nil or not s_LocalPlayer.alive then
		return BRPlayerState.Dead
	elseif s_LocalPlayer.soldier.isInteractiveManDown then
		return BRPlayerState.Down
	else
		return BRPlayerState.Alive
	end
end

---Returns the Armor in % (0-100)
---@return integer
function BRPlayer:GetArmorPercentage()
	---@type BRItemArmor
	local s_Armor = self.m_Inventory:GetSlot(InventorySlot.Armor)
	return s_Armor ~= nil and s_Armor:GetPercentage() or 0
end

---Returns the Helmet in % (0-100)
---@return integer
function BRPlayer:GetHelmetPercentage()
	---@type BRItemHelmet
	local s_Helmet = self.m_Inventory:GetSlot(InventorySlot.Helmet)
	return s_Helmet ~= nil and s_Helmet:GetPercentage() or 0
end

---Returns a color as Vec4 or as string in css format
---@param p_AsRgba boolean
---@return Vec4|string
function BRPlayer:GetColor(p_AsRgba)
	local s_Color = ServerConfig.PlayerColors[self.m_PosInSquad] or Vec4(1.0, 1.0, 1.0, 1.0)

	-- return color as Vec4
	if not p_AsRgba then
		return s_Color
	end

	-- return color as an rgba string
	return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

---VEXT Shared Level:Destroy Event
function BRPlayer:OnLevelDestroy()
	self:ResetVars()
	self.m_Inventory:Reset()
end

return BRPlayer()
