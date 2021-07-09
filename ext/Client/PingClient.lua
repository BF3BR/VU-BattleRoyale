class "PingClient"

require "__shared/Enums/CustomEvents"
require "__shared/Enums/PingTypes"
require "__shared/Utils/EventRouter"

local m_Hud = require "Hud"
local m_Logger = Logger("PingClient", true)

function PingClient:__init()
	self:RegisterVars()
end

function PingClient:RegisterVars()
	self.m_BrPlayer = nil

	self.m_LastPing = Vec3(0, 0, 0)
	self.m_Color = Vec3(0, 0, 0)

	-- Pings for squadmates
	-- This is playerName, { position, cooldownTime }
	self.m_SquadPings = {}

	self.m_Opacity = 0.4

	self.m_PingColors = {
		Vec4(1, 0, 0, self.m_Opacity),
		Vec4(0, 1, 0, self.m_Opacity),
		Vec4(0, 0, 1, self.m_Opacity),
		Vec4(0.5, 0.5, 0.5, self.m_Opacity)
	}

	-- This is set by the server
	self.m_CooldownTime = 0.0

	self.m_DebugSize = 0.25

	self.m_RaycastLength = 2000.0

	-- Minimap Pinging related
	self.m_PingMethod = PingMethod.World
	self.m_Position_X = 0
	self.m_Position_Z = 0

	-- Should we send a ping (used for sync across UpdateState's)
	self.m_ShouldPing = false
	self.m_PingCooldownTime = 0.60

	self.m_PingType = PingType.Default
end

-- =============================================
-- Events
-- =============================================

function PingClient:OnLevelLoaded()
	self.m_SquadPings = {}
	self.m_ShouldPing = false
end

function PingClient:OnUIDrawHud(p_BrPlayer, p_DeltaTime)
	if self.m_BrPlayer == nil then
		if p_BrPlayer == nil then
			return
		end

		self.m_BrPlayer = p_BrPlayer
	end

	self.m_PingCooldownTime = self.m_PingCooldownTime - p_DeltaTime

	for l_PlayerName, l_PingInfo in pairs(self.m_SquadPings) do
		if l_PingInfo == nil then
			m_Logger:Write("invalid ping info")
			goto __on_ui_draw_hud_cont__
		end

		l_PingInfo[2] = l_PingInfo[2] - p_DeltaTime

		local s_PingId = l_PingInfo[1]
		local s_Cooldown = l_PingInfo[2]

		if s_Cooldown < 0.001 then
			m_Logger:Write("invalid cooldown")
			Events:Dispatch("Compass:RemoveMarker", tostring(l_PlayerName))
			m_Hud:RemoveMarker(tostring(l_PlayerName))
			self.m_SquadPings[l_PlayerName] = nil
			self:RemovePing(s_PingId)
			goto __on_ui_draw_hud_cont__
		end

		local s_Color = self:GetColorByPlayerName(l_PlayerName)

		if s_Color == nil then
			m_Logger:Write("invalid color for ping ID: " .. tostring(l_PlayerName))
			Events:Dispatch("Compass:RemoveMarker", tostring(l_PlayerName))
			m_Hud:RemoveMarker(tostring(l_PlayerName))
			self.m_SquadPings[l_PlayerName] = nil
			self:RemovePing(s_PingId)
			goto __on_ui_draw_hud_cont__
		end

		::__on_ui_draw_hud_cont__::
	end
end

function PingClient:OnClientUpdateInput()
	if self.m_BrPlayer == nil then
		return
	end

	if SpectatorManager:GetSpectating() then
		return
	end

	if self.m_PingCooldownTime > 0.0 then
		return
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_Q) then
		self.m_ShouldPing = true
		self.m_PingMethod = PingMethod.World
		self.m_PingType = PingType.Default
	elseif InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_2) then
		self.m_ShouldPing = true
		self.m_PingMethod = PingMethod.World
		self.m_PingType = PingType.Enemy
	end
end

function PingClient:OnUpdatePassPreSim(p_DeltaTime)
	-- If we do not need to ping dont worry about anything
	if not self.m_ShouldPing then
		return
	end

	m_Logger:Write("raycasting...")
	local s_RaycastHit = nil

	if self.m_PingMethod == PingMethod.World then
		s_RaycastHit = self:RaycastWorld()
	else
		s_RaycastHit = self:RaycastScreen()
	end

	self.m_ShouldPing = false

	if SpectatorManager:GetSpectating() then
		return
	end

	if s_RaycastHit == nil then
		m_Logger:Write("no raycast")
		return
	end

	self.m_PingCooldownTime = 0.60
	-- Send the server a client notification that we want to ping at this location
	NetEvents:Send(PingEvents.ClientPing, s_RaycastHit.position, self.m_PingType)
end

-- =============================================
-- Custom (Net-)Events
-- =============================================

function PingClient:OnPingNotify(p_PlayerName, p_Position, p_PingType)
	if self.m_BrPlayer == nil then
		return
	end

	m_Logger:Write("playerName: " .. tostring(p_PlayerName) .. " position: " .. p_Position.x .. ", " .. p_Position.y .. ", " .. p_Position.z)

	-- Send ping to compass
	local s_RgbaColor = self:GetRgbaColorByPlayerName(p_PlayerName)
	local s_PingId = self:GetPingId(p_PlayerName, p_PingType)
	m_Logger:Write(s_PingId)
	self:SetPingPosition(s_PingId, p_Position)
	Events:Dispatch("Compass:CreateMarker", tostring(p_PlayerName), Vec2(p_Position.x, p_Position.z), s_RgbaColor)
	m_Hud:CreateMarker(tostring(p_PlayerName), p_Position.x, p_Position.y, p_Position.z, s_RgbaColor)

	local s_PingInfo = self.m_SquadPings[p_PlayerName]

	if s_PingInfo == nil then
		-- No information currently exists
		self.m_SquadPings[p_PlayerName] = {
			s_PingId,
			self.m_CooldownTime
		}
		return
	end

	-- remove last ping if it was a different PingType
	if s_PingInfo[1] ~= s_PingId then
		self:RemovePing(s_PingInfo[1])
	end

	-- Update the structure
	local l_UpdatedCooldown = s_PingInfo[2] + self.m_CooldownTime

	if l_UpdatedCooldown > 3 * self.m_CooldownTime then
		l_UpdatedCooldown = 3 * self.m_CooldownTime
	end

	self.m_SquadPings[p_PlayerName] = {
		s_PingId,
		l_UpdatedCooldown
	}
end

function PingClient:OnPingRemoveNotify(p_PlayerName)
	m_Logger:Write("removing ping for player: " .. tostring(p_PlayerName))

	Events:Dispatch("Compass:RemoveMarker", tostring(p_PlayerName))
	m_Hud:RemoveMarker(tostring(p_PlayerName))
	self:RemovePing(self.m_SquadPings[p_PlayerName][1])
	self.m_SquadPings[p_PlayerName] = nil
end

function PingClient:OnPingUpdateConfig(p_CooldownTime)
	m_Logger:Write("cooldownTime: " .. p_CooldownTime)

	self.m_CooldownTime = p_CooldownTime
end

-- =============================================
-- WebUI Events
-- =============================================

function PingClient:OnWebUIPingFromMap(p_Coordinates)
	if p_Coordinates == nil then
		m_Logger:Error("No Coordinates received")
		return
	end

	local s_Coordinates = json.decode(p_Coordinates)
	self.m_Position_X = s_Coordinates.x
	self.m_Position_Z = s_Coordinates.y
	self.m_ShouldPing = true
	self.m_PingMethod = PingMethod.Screen
	self.m_PingType = PingType.Default
end

function PingClient:OnWebUIPingRemoveFromMap()
	NetEvents:SendLocal(PingEvents.RemoveClientPing)
end

-- =============================================
-- Functions
-- =============================================

function PingClient:RaycastWorld()
	local s_Transform = ClientUtils:GetCameraTransform()

	if s_Transform == nil then
		m_Logger:Write("invalid transform")
		return
	end

	local s_Direction = Vec3(-s_Transform.forward.x, -s_Transform.forward.y, -s_Transform.forward.z)

	local s_RayStart = s_Transform.trans
	local s_RayEnd = Vec3(s_Transform.trans.x + (s_Direction.x * self.m_RaycastLength),
						  s_Transform.trans.y + (s_Direction.y * self.m_RaycastLength),
						  s_Transform.trans.z + (s_Direction.z * self.m_RaycastLength))

	local s_RaycastHit = RaycastManager:Raycast(s_RayStart, s_RayEnd, RayCastFlags.DontCheckWater |
													RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)
	return s_RaycastHit
end

function PingClient:RaycastScreen()
	local s_Position = Vec3(self.m_Position_X, 2000 ,self.m_Position_Z)

	if s_Position == nil then
		m_Logger:Write("invalid transform")
		return
	end

	local s_Direction = Vec3(0, -1, 0)

	local s_RayStart = s_Position
	local s_RayEnd = Vec3(s_Position.x + (s_Direction.x * self.m_RaycastLength),
							s_Position.y + (s_Direction.y * self.m_RaycastLength),
							s_Position.z + (s_Direction.z * self.m_RaycastLength))

	local s_RaycastHit = RaycastManager:Raycast(s_RayStart, s_RayEnd, RayCastFlags.DontCheckWater |
													RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	self.m_Position_X = 0
	self.m_Position_Z = 0

	return s_RaycastHit
end

function PingClient:GetPingId(p_PlayerName, p_PingType)
	local s_IndexOffset

	if p_PingType == PingType.Default then
		s_IndexOffset = 132
	elseif p_PingType == PingType.Enemy then
		s_IndexOffset = 136
	elseif p_PingType == PingType.Weapon then
		s_IndexOffset = 140
	elseif p_PingType == PingType.Ammo then
		s_IndexOffset = 144
	elseif p_PingType == PingType.Armor then
		s_IndexOffset = 148
	elseif p_PingType == PingType.Health then
		s_IndexOffset = 152
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer.name == p_PlayerName then
		return self.m_BrPlayer.m_PosInSquad + s_IndexOffset
	else
		local s_TeamPlayers = self.m_BrPlayer.m_Team:PlayersTable()

		if s_TeamPlayers ~= nil then
			for _, l_Teammate in ipairs(s_TeamPlayers) do
				if l_Teammate ~= nil then
					if p_PlayerName == l_Teammate.Name then
						return l_Teammate.PosInSquad + s_IndexOffset
					end
				end
			end
		end
	end

	return nil
end

function PingClient:SetPingPosition(p_IndexInBlueprint, p_Position)
	local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)

		if s_Entity.data ~= nil then
			local s_Data = MapMarkerEntityData(s_Entity.data)

			if s_Data.indexInBlueprint == p_IndexInBlueprint and s_Data.transform.trans == Vec3(-9999, -9999, -9999) then
				local s_Transform = LinearTransform()
				s_Transform.trans = p_Position
				s_Entity.transform = s_Transform
				m_Logger:Write("Set ping")
				return
			end
		end
		s_Entity = s_EntityIterator:Next()
	end
end

function PingClient:RemovePing(p_IndexInBlueprint)
	local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)

		if s_Entity.data ~= nil then
			local s_Data = MapMarkerEntityData(s_Entity.data)

			if s_Data.indexInBlueprint == p_IndexInBlueprint and s_Data.transform.trans == Vec3(-9999, -9999, -9999) then
				local s_Transform = LinearTransform()
				s_Transform.trans = Vec3(-9999, -9999, -9999)
				s_Entity.transform = s_Transform
				return
			end
		end
		s_Entity = s_EntityIterator:Next()
	end
end

function PingClient:GetColorByPlayerName(p_PlayerName)
	-- Validate player name
	if p_PlayerName == nil and self.m_BrPlayer == nil then
		return
	end

	local s_Teammates = self.m_BrPlayer.m_Team:PlayersTable()
	local s_Color = nil

	for _, l_Teammate in pairs(s_Teammates) do
		if l_Teammate.Name == p_PlayerName then
			s_Color = l_Teammate.ColorVec
			break
		end
	end

	if s_Color == nil then
		m_Logger:Write("Color not found!")
		return Vec4(0, 0, 0, 1)
	end

	return s_Color
end

function PingClient:GetRgbaColorByPlayerName(p_PlayerName)
	-- Validate player name
	if p_PlayerName == nil then
		return
	end

	-- Get original color
	local s_Color = self:GetColorByPlayerName(p_PlayerName)

	-- Convert to rgba string
	return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

if g_PingClient == nil then
	g_PingClient = PingClient()
end

return g_PingClient
