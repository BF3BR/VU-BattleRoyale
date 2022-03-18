---@class PingClient
PingClient = class "PingClient"

---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"
---@type VuBattleRoyaleHud
local m_Hud = require "UI/Hud"
---@type BRPlayer
local m_BrPlayer = require "BRPlayer"
---@type Logger
local m_Logger = Logger("PingClient", false)

---@return ModSetting
local function GetPingKeySetting()
	local s_PingKeySetting = SettingsManager:GetSetting("PingKey")

	if s_PingKeySetting == nil then
		s_PingKeySetting = SettingsManager:DeclareKeybind("PingKey", InputDeviceKeys.IDK_Q, { displayName = "Ping Key", showInUi = true })
		s_PingKeySetting.value = InputDeviceKeys.IDK_Q

		m_Logger:Write("GetPingKeySetting created.")
	end

	return s_PingKeySetting
end

---@return ModSetting
local function GetEnemyPingOptionSetting()
	local s_EnemyPingOptionSetting = SettingsManager:GetSetting("PingEnemyOption")

	if s_EnemyPingOptionSetting == nil then
		---@type SettingOptions
		local s_SettingOptions = SettingOptions()
		s_SettingOptions.displayName = "Ping Enemy"
		s_SettingOptions.showInUi = true
		s_EnemyPingOptionSetting = SettingsManager:DeclareOption("PingEnemyOption", "Define MouseButton", { "Define MouseButton", "Define Key", "Press Ping-Key twice" }, false, s_SettingOptions)
		s_EnemyPingOptionSetting.value = "Define MouseButton"

		m_Logger:Write("GetEnemyPingOptionSetting created.")
	end

	return s_EnemyPingOptionSetting
end

---@return ModSetting
local function GetEnemyPingKeySetting()
	local s_EnemyPingKeySetting = SettingsManager:GetSetting("PingEnemyKey")

	if s_EnemyPingKeySetting == nil then
		s_EnemyPingKeySetting = SettingsManager:DeclareKeybind("PingEnemyKey", InputDeviceKeys.IDK_None, { displayName = "Ping Enemy Key", showInUi = true })
		s_EnemyPingKeySetting.value = InputDeviceKeys.IDK_None

		m_Logger:Write("GetEnemyPingKeySetting created.")
	end

	return s_EnemyPingKeySetting
end

---@return ModSetting
local function GetEnemyPingMouseButtonSetting()
	local s_EnemyPingButtonSetting = SettingsManager:GetSetting("PingEnemyMouseButton")

	if s_EnemyPingButtonSetting == nil then
		s_EnemyPingButtonSetting = SettingsManager:DeclareNumber("PingEnemyMouseButton", InputDeviceMouseButtons.IDB_Button_2, InputDeviceMouseButtons.IDB_Button_0, InputDeviceMouseButtons.IDB_Button_Undefined, { displayName = "Ping Enemy MouseButton", showInUi = true })
		s_EnemyPingButtonSetting.value = InputDeviceMouseButtons.IDB_Button_2

		m_Logger:Write("GetEnemyPingMouseButtonSetting created.")
	end

	return s_EnemyPingButtonSetting
end

function PingClient:OnExtensionLoaded()
	self:RegisterVars()
end

function PingClient:RegisterVars()
	-- Pings for squadmates
	-- This is playerName, { positionInSquad, cooldownTime }
	---@type table<string, table<integer, number>>
	self.m_SquadPings = {}

	self.m_Opacity = 0.4

	self.m_PingColors = {
		Vec4(1.0, 0.0, 0.0, self.m_Opacity),
		Vec4(0.0, 1.0, 0.0, self.m_Opacity),
		Vec4(0.0, 0.0, 1.0, self.m_Opacity),
		Vec4(0.5, 0.5, 0.5, self.m_Opacity)
	}

	-- This is set by the server
	self.m_CooldownTime = 0.0

	self.m_DebugSize = 0.25

	self.m_RaycastLength = 2000.0

	-- Minimap Pinging related
	---@type PingMethod|integer
	self.m_PingMethod = PingMethod.World
	self.m_Position_X = 0.0
	self.m_Position_Z = 0.0

	-- Should we send a ping (used for sync across UpdateState's)
	self.m_ShouldPing = false
	self.m_PingCooldownTime = 0.60

	---@type PingType|integer
	self.m_PingType = PingType.Default

	-- Time to hold key to display CommoRose
	self.m_TimeToDisplayCommoRose = 0.20
	self.m_DisplayCommoRoseTimer = 0.0
	self.m_IsCommoRoseOpened = false

	---@type PingType|integer
	self.m_CurrentTypeIndex = PingType.Default

	-- for the "Press Ping-Key twice" option
	self.m_ShouldPingSoon = false
	self.m_PingTimer = 0.0

	self.m_PingKeySetting = GetPingKeySetting()
	self.m_EnemyPingOptionSetting = GetEnemyPingOptionSetting()
	self.m_EnemyPingKeySetting = GetEnemyPingKeySetting()
	self.m_EnemyPingMouseButtonSetting = GetEnemyPingMouseButtonSetting()
end

-- =============================================
-- Events
-- =============================================

---VEXT Client Level:Loaded Event
function PingClient:OnLevelLoaded()
	self.m_SquadPings = {}
	self.m_ShouldPing = false
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreFrame
---@param p_DeltaTime number
function PingClient:OnUIDrawHud(p_DeltaTime)
	self.m_PingCooldownTime = self.m_PingCooldownTime - p_DeltaTime

	for l_PlayerName, l_PingInfo in pairs(self.m_SquadPings) do
		if l_PingInfo == nil then
			m_Logger:Write("invalid ping info")
			goto __on_ui_draw_hud_cont__
		end

		l_PingInfo[2] = l_PingInfo[2] - p_DeltaTime

		---@type integer
		local s_PingId = l_PingInfo[1]
		---@type number
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

---VEXT Client Client:UpdateInput Event
---@param p_DeltaTime number
function PingClient:OnClientUpdateInput(p_DeltaTime)
	if SpectatorManager:GetSpectating() then
		return
	end

	if self.m_PingCooldownTime > 0.0 then
		return
	end

	-- player pressed the ping key quick once, we delay it for 100ms so he can press it twice to change the type from Default to Enemy
	if self.m_ShouldPingSoon then
		self.m_PingTimer = self.m_PingTimer + p_DeltaTime

		if self.m_PingTimer > 0.2 then
			self.m_PingTimer = 0.0
			self.m_ShouldPingSoon = false
			self.m_ShouldPing = true
		end
	end

	if m_HudUtils:GetIsMapOpened() then
		return
	end

	if InputManager:IsKeyDown(self.m_PingKeySetting.value) then
		self.m_DisplayCommoRoseTimer = self.m_DisplayCommoRoseTimer + p_DeltaTime

		if self.m_DisplayCommoRoseTimer > self.m_TimeToDisplayCommoRose and not self.m_IsCommoRoseOpened then
			m_Hud:ShowCommoRose()
			self.m_IsCommoRoseOpened = true
			m_Logger:Write("ShowCommoRose")
			WebUI:EnableMouse()
		end
	elseif InputManager:WentKeyUp(self.m_PingKeySetting.value) and self.m_DisplayCommoRoseTimer ~= 0.0 then
		self.m_PingMethod = PingMethod.World

		-- didn't hold the ping key (Q) long enough
		if self.m_DisplayCommoRoseTimer < self.m_TimeToDisplayCommoRose then
			-- key went up a second time within 100ms so we do an enemy ping
			if self.m_ShouldPingSoon then
				self.m_ShouldPingSoon = false
				self.m_ShouldPing = true
				self.m_PingType = PingType.Enemy
				return
			end

			self.m_PingType = PingType.Default

			if self.m_EnemyPingOptionSetting.value == "Press Ping-Key twice" then
				self.m_ShouldPingSoon = true
			else
				self.m_ShouldPing = true
			end
		else
			self.m_ShouldPing = true
			self.m_PingType = self.m_CurrentTypeIndex
			self.m_CurrentTypeIndex = PingType.Default
		end

		InputManager:SetCursorPosition(WebUI:GetScreenWidth() / 2, WebUI:GetScreenHeight() / 2)
		WebUI:ResetMouse()
		m_Hud:HideCommoRose()
		self.m_IsCommoRoseOpened = false
		self.m_DisplayCommoRoseTimer = 0.0
	elseif InputManager:WentKeyDown(self.m_EnemyPingKeySetting.value) and self.m_EnemyPingOptionSetting.value == "Define Key" then
		self.m_ShouldPing = true
		self.m_PingMethod = PingMethod.World
		self.m_PingType = PingType.Enemy
	elseif InputManager:WentMouseButtonDown(self.m_EnemyPingMouseButtonSetting.value) and self.m_EnemyPingOptionSetting.value == "Define MouseButton" then
		self.m_ShouldPing = true
		self.m_PingMethod = PingMethod.World
		self.m_PingType = PingType.Enemy
	end
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreSim
---@param p_DeltaTime number
function PingClient:OnUpdatePassPreSim(p_DeltaTime)
	-- If we do not need to ping dont worry about anything
	if not self.m_ShouldPing then
		return
	end

	m_Logger:Write("raycasting...")
	---@type RayCastHit|nil
	local s_RaycastHit = nil

	if self.m_PingMethod == PingMethod.World then
		-- before raycasting we check if we should remove the last player ping instead
		if self:ShouldRemovePing() then
			self.m_ShouldPing = false
			NetEvents:SendLocal(PingEvents.RemoveClientPing)
			return
		end

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

---Custom Client PingEvents.ServerPing NetEvent
---@param p_PlayerName string
---@param p_Position Vec3
---@param p_PingType PingType|integer
function PingClient:OnPingNotify(p_PlayerName, p_Position, p_PingType)
	m_Logger:Write("playerName: " .. tostring(p_PlayerName) .. " position: " .. p_Position.x .. ", " .. p_Position.y .. ", " .. p_Position.z)

	-- Send ping to compass
	local s_RgbaColor = self:GetRgbaColorByPlayerName(p_PlayerName)
	local s_PingId = self:GetPingId(p_PlayerName, p_PingType)
	m_Logger:Write(s_PingId)
	self:SetPingPosition(s_PingId, p_Position)
	Events:Dispatch("Compass:CreateMarker", tostring(p_PlayerName), Vec2(p_Position.x, p_Position.z), s_RgbaColor, p_PingType)
	m_Hud:CreateMarker(tostring(p_PlayerName), p_Position.x, p_Position.y, p_Position.z, s_RgbaColor, p_PingType)

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
	---@type number
	local s_UpdatedCooldown = s_PingInfo[2] + self.m_CooldownTime

	if s_UpdatedCooldown > 3 * self.m_CooldownTime then
		s_UpdatedCooldown = 3 * self.m_CooldownTime
	end

	self.m_SquadPings[p_PlayerName] = {
		s_PingId,
		s_UpdatedCooldown
	}
end

---Custom Client PingEvents.RemoveServerPing NetEvent
---@param p_PlayerName string
function PingClient:OnPingRemoveNotify(p_PlayerName)
	m_Logger:Write("removing ping for player: " .. tostring(p_PlayerName))

	Events:Dispatch("Compass:RemoveMarker", tostring(p_PlayerName))
	m_Hud:RemoveMarker(tostring(p_PlayerName))

	if self.m_SquadPings[p_PlayerName] == nil then
		m_Logger:Write("Failed to remove ping for player: " .. tostring(p_PlayerName))
		return
	end

	self:RemovePing(self.m_SquadPings[p_PlayerName][1])
	self.m_SquadPings[p_PlayerName] = nil
end

---Custom Client PingEvents.UpdateConfig NetEvent
---@param p_CooldownTime number
function PingClient:OnPingUpdateConfig(p_CooldownTime)
	m_Logger:Write("cooldownTime: " .. p_CooldownTime)

	self.m_CooldownTime = p_CooldownTime
end

-- =============================================
-- WebUI Events
-- =============================================

---Custom Client WebUI:PingFromMap WebUI Event
---@param p_Coordinates string @json table
function PingClient:OnWebUIPingFromMap(p_Coordinates)
	if p_Coordinates == nil then
		m_Logger:Error("No Coordinates received")
		return
	end

	---@type table<string, number>
	local s_Coordinates = json.decode(p_Coordinates)
	self.m_Position_X = s_Coordinates.x
	self.m_Position_Z = s_Coordinates.y
	self.m_ShouldPing = true
	self.m_PingMethod = PingMethod.Screen
	self.m_PingType = PingType.Default
end

---Custom Client WebUI:PingRemoveFromMap WebUI Event
function PingClient:OnWebUIPingRemoveFromMap()
	NetEvents:SendLocal(PingEvents.RemoveClientPing)
end

---Custom Client WebUI:HoverCommoRose WebUI Event
---@param p_TypeIndex PingType|integer
function PingClient:OnWebUIHoverCommoRose(p_TypeIndex)
	self.m_CurrentTypeIndex = p_TypeIndex
end

-- =============================================
-- Functions
-- =============================================

---Raycast when we press Q
---@return RayCastHit|nil
function PingClient:RaycastWorld()
	local s_Transform = ClientUtils:GetCameraTransform()

	if s_Transform == nil then
		m_Logger:Write("invalid transform")
		return
	end

	local s_Direction = Vec3(-s_Transform.forward.x, -s_Transform.forward.y, -s_Transform.forward.z)

	local s_RayStart = s_Transform.trans + s_Direction
	local s_RayEnd = Vec3(s_Transform.trans.x + (s_Direction.x * self.m_RaycastLength),
		s_Transform.trans.y + (s_Direction.y * self.m_RaycastLength),
		s_Transform.trans.z + (s_Direction.z * self.m_RaycastLength))

	local s_RaycastHit = RaycastManager:Raycast(s_RayStart, s_RayEnd, RayCastFlags.DontCheckWater |
	RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)
	return s_RaycastHit
end

---Raycast when we click on the minimap
---@return RayCastHit|nil
function PingClient:RaycastScreen()
	local s_Position = Vec3(self.m_Position_X, 2000.0, self.m_Position_Z)

	if s_Position == nil then
		m_Logger:Write("invalid transform")
		return
	end

	local s_Direction = Vec3(0.0, -1.0, 0.0)

	local s_RayStart = s_Position
	local s_RayEnd = Vec3(s_Position.x + (s_Direction.x * self.m_RaycastLength),
		s_Position.y + (s_Direction.y * self.m_RaycastLength),
		s_Position.z + (s_Direction.z * self.m_RaycastLength))

	local s_RaycastHit = RaycastManager:Raycast(s_RayStart, s_RayEnd, RayCastFlags.DontCheckWater |
	RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)

	self.m_Position_X = 0.0
	self.m_Position_Z = 0.0

	return s_RaycastHit
end

---Returns the PingId that's needed to find the MapMarkerEntity in the EntityManager
---@param p_PlayerName string
---@param p_PingType PingType|integer
---@return integer
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
		return m_BrPlayer.m_PosInSquad + s_IndexOffset
	else
		local s_TeamPlayers = m_BrPlayer.m_Team:PlayersTable()

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

---Updates the position of the ping
---@param p_IndexInBlueprint integer
---@param p_Position Vec3
function PingClient:SetPingPosition(p_IndexInBlueprint, p_Position)
	local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
	---@type SpatialEntity|nil
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)

		if s_Entity.data ~= nil then
			local s_Data = MapMarkerEntityData(s_Entity.data)

			if s_Data.indexInBlueprint == p_IndexInBlueprint and s_Data.transform.trans == Vec3(-9999.0, -9999.0, -9999.0) then
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

---@return boolean
function PingClient:ShouldRemovePing()
	if self.m_PingType ~= PingType.Default then
		return false
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		-- shouldn't happen
		return false
	end

	-- check if we actually have a ping
	if self.m_SquadPings[s_LocalPlayer.name] ~= nil then
		-- loop all ClientMapMarkerEntities and search the local player ones
		local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
		---@type SpatialEntity|nil
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = SpatialEntity(s_Entity)

			if s_Entity.data ~= nil then
				local s_Data = MapMarkerEntityData(s_Entity.data)

				-- check if this is the local player ping
				if s_Data.indexInBlueprint == self.m_SquadPings[s_LocalPlayer.name][1] then
					local s_PingScreenPosition = ClientUtils:WorldToScreen(s_Entity.transform.trans)

					if s_PingScreenPosition == nil then
						return false
					end

					-- check if the ping is close to the center (relative to the screenheight)
					if s_PingScreenPosition:Distance(ClientUtils:GetWindowSize() / 2) < (WebUI:GetScreenHeight() / 15) then
						m_Logger:Write("Removing ping instead of creating a new one.")
						return true
					end

					return false
				end
			end

			s_Entity = s_EntityIterator:Next()
		end
	end

	return false
end

---Removes the ping by moving it to the default position
---@param p_IndexInBlueprint integer
function PingClient:RemovePing(p_IndexInBlueprint)
	local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
	---@type SpatialEntity|nil
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)

		if s_Entity.data ~= nil then
			local s_Data = MapMarkerEntityData(s_Entity.data)

			if s_Data.indexInBlueprint == p_IndexInBlueprint and s_Data.transform.trans == Vec3(-9999.0, -9999.0, -9999.0) then
				local s_Transform = LinearTransform()
				s_Transform.trans = Vec3(-9999.0, -9999.0, -9999.0)
				s_Entity.transform = s_Transform
				return
			end
		end

		s_Entity = s_EntityIterator:Next()
	end
end

---Returns a color as Vec4
---@param p_PlayerName string
---@return Vec4
function PingClient:GetColorByPlayerName(p_PlayerName)
	local s_Teammates = m_BrPlayer.m_Team:PlayersTable()
	---@type Vec4|nil
	local s_Color = nil

	for _, l_Teammate in pairs(s_Teammates) do
		if l_Teammate.Name == p_PlayerName then
			s_Color = l_Teammate.ColorVec
			break
		end
	end

	if s_Color == nil then
		m_Logger:Write("Color not found!")
		return Vec4(0.0, 0.0, 0.0, 1.0)
	end

	return s_Color
end

---Returns a css rgba color as string
---@param p_PlayerName string
---@return string
function PingClient:GetRgbaColorByPlayerName(p_PlayerName)
	-- Get original color
	local s_Color = self:GetColorByPlayerName(p_PlayerName)

	-- Convert to rgba string
	return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

return PingClient()
