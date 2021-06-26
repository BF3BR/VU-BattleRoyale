class "VuBattleRoyaleHud"

require "__shared/Utils/CachedJsExecutor"
require "__shared/Utils/Timers"
require "__shared/Enums/GameStates"
require "__shared/Enums/UiStates"

local m_VanillaUIManager = require "VanillaUIManager"
local m_HudUtils = require "Utils/HudUtils"
local m_Logger = Logger("VuBattleRoyaleHud", true)

function VuBattleRoyaleHud:__init()
	self.m_GameState = GameStates.None
	self.m_Ticks = 0.0
	self.m_BrPlayer = nil
	self.m_IsPlayerOnPlane = false

	self.m_IsLevelLoaded = false

	self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart

	self.m_Markers = {}

	self:RegisterVars()
end

function VuBattleRoyaleHud:RegisterVars()
	self.m_HudOnPlayerPos = CachedJsExecutor("OnPlayerPos(%s)", nil)
	self.m_HudOnPlayerYaw = CachedJsExecutor("OnPlayerYaw(%s)", 0)
	self.m_HudOnPlayerIsOnPlane = CachedJsExecutor("OnPlayerIsOnPlane(%s)", false)
	self.m_HudOnPlanePos = CachedJsExecutor("OnPlanePos(%s)", nil)
	self.m_HudOnPlaneYaw = CachedJsExecutor("OnPlaneYaw(%s)", 0)
	self.m_HudOnUpdateCircles = CachedJsExecutor("OnUpdateCircles(%s)", nil)
	self.m_HudOnGameState = CachedJsExecutor("OnGameState('%s')", GameStates.None)
	self.m_HudOnPlayersInfo = CachedJsExecutor("OnPlayersInfo(%s)", nil)
	self.m_HudOnLocalPlayerInfo = CachedJsExecutor("OnLocalPlayerInfo(%s)", nil)
	self.m_HudOnUpdateTimer = CachedJsExecutor("OnUpdateTimer(%s)", nil)
	self.m_HudOnMinPlayersToStart = CachedJsExecutor("OnMinPlayersToStart(%s)", nil)
	self.m_HudOnPlayerHealth = CachedJsExecutor("OnPlayerHealth(%s)", 0)
	self.m_HudOnPlayerArmor = CachedJsExecutor("OnPlayerArmor(%s)", 0)
	self.m_HudOnPlayerPrimaryAmmo = CachedJsExecutor("OnPlayerPrimaryAmmo(%s)", 0)
	self.m_HudOnPlayerSecondaryAmmo = CachedJsExecutor("OnPlayerSecondaryAmmo(%s)", 0)
	self.m_HudOnPlayerFireLogic = CachedJsExecutor("OnPlayerFireLogic(%s)", 0)
	self.m_HudOnPlayerCurrentWeapon = CachedJsExecutor("OnPlayerCurrentWeapon('%s')", "")
	self.m_HudOnPlayerWeapons = CachedJsExecutor("OnPlayerWeapons(%s)", nil)
	self.m_HudOnUpdateTeamPlayers = CachedJsExecutor("OnUpdateTeamPlayers(%s)", nil)
	self.m_HudOnUpdateTeamLocked = CachedJsExecutor("OnUpdateTeamLocked(%s)", false)
	self.m_HudOnUpdateTeamId = CachedJsExecutor("OnUpdateTeamId('%s')", "-")
	self.m_HudOnUpdateTeamSize = CachedJsExecutor("OnUpdateTeamSize(%s)", 0)
	self.m_HudOnTeamJoinError = CachedJsExecutor("OnTeamJoinError(%s)", nil)
	self.m_HudOnNotifyInflictorAboutKillOrKnock = CachedJsExecutor("OnNotifyInflictorAboutKillOrKnock(%s)", nil)
	self.m_HudOnInteractiveMessageAndKey = CachedJsExecutor("OnInteractiveMessageAndKey(%s)", nil)
	self.m_HudOnGameOverScreen = CachedJsExecutor("OnGameOverScreen(%s)", nil)
	self.m_HudOnUpdatePlacement = CachedJsExecutor("OnUpdatePlacement(%s)", 99)
	self.m_HudOnSetUIState = CachedJsExecutor("OnSetUIState('%s')", UiStates.Loading)
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleHud:OnExtensionLoaded()
	WebUI:Init()
	WebUI:Show()
end

function VuBattleRoyaleHud:OnExtensionUnloading()
	self.m_IsLevelLoaded = false
	m_HudUtils:SetIsMapOpened(false)
	WebUI:ExecuteJS("OnOpenCloseMap(false);")
	self.m_HudOnSetUIState:Update(UiStates.Hidden)
end

function VuBattleRoyaleHud:OnLevelDestroy()
	self.m_IsLevelLoaded = false
	m_HudUtils:SetIsMapOpened(false)
	WebUI:ExecuteJS("OnOpenCloseMap(false);")
	self.m_HudOnSetUIState:Update(UiStates.Loading)
end

function VuBattleRoyaleHud:OnEngineUpdate(p_DeltaTime)
	if not self.m_IsLevelLoaded then
		return
	end

	if self.m_BrPlayer ~= nil and self.m_BrPlayer.m_Team ~= nil then
		self.m_HudOnUpdateTeamLocked:Update(self.m_BrPlayer.m_Team.m_Locked)
		self.m_HudOnUpdateTeamPlayers:Update(json.encode(self.m_BrPlayer.m_Team:PlayersTable()))
	end

	if self.m_Ticks >= ServerConfig.HudUpdateRate then
		self.m_HudOnMinPlayersToStart:Update(self.m_MinPlayersToStart)
		self:PushUpdatePlayersInfo()
		self:PushLocalPlayerTeam()
		self.m_Ticks = 0.0
	end

	self.m_Ticks = self.m_Ticks + p_DeltaTime
end

function VuBattleRoyaleHud:OnUIDrawHud(p_BrPlayer)
	if not self.m_IsLevelLoaded then
		return
	end

	if self.m_BrPlayer == nil then
		if p_BrPlayer == nil then
			return
		end

		self.m_BrPlayer = p_BrPlayer
	end

	--self:PushMarkerUpdate()
	self:PushLocalPlayerPos()
	self:PushLocalPlayerYaw()
	self:PushLocalPlayerAmmoArmorAndHealth()
	self:OnUpdatePlacement()
end

function VuBattleRoyaleHud:OnClientUpdateInput()
	if not self.m_IsLevelLoaded then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F10) then
		if (self.m_GameState ~= GameStates.Match and self.m_GameState ~= GameStates.Plane and self.m_GameState ~= GameStates.PlaneToFirstCircle)
		or s_LocalPlayer.soldier == nil then
			WebUI:ExecuteJS("ToggleDeployMenu(true);")
			m_HudUtils:ShowroomCamera(true)
			m_HudUtils:ShowCrosshair(false)
			m_HudUtils:OnEnableMouse()
			m_VanillaUIManager:EnableShowroomSoldier(true)
			m_HudUtils:SetIsInDeployScreen(true)
		end
	end

	if m_HudUtils:GetIsInEscMenu() then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_Escape) then
			self:OnResume()
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowUp)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_W) then
			WebUI:ExecuteJS("OnMenuArrowUp()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_ArrowDown)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_S) then
			WebUI:ExecuteJS("OnMenuArrowDown()")
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_Enter)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_NumpadEnter)
		or InputManager:WentKeyDown(InputDeviceKeys.IDK_Space) then
			WebUI:ExecuteJS("OnMenuEnter()")
		end
	end
end

function VuBattleRoyaleHud:OnPlayerRespawn(p_Player)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= p_Player or p_Player.soldier == nil then
		return
	end

	WebUI:ExecuteJS("OnMapShow(true)")
	self:PushLocalPlayerPos()
	self:PushLocalPlayerYaw()
	g_Timers:Timeout(0.75, function()
		m_HudUtils:ShowCrosshair(true)
	end)

	if self.m_GameState <= GameStates.Warmup then
		return
	end

	self:RegisterOnBeingInteractedCallbacks(p_Player.soldier)
end

-- =============================================
-- Custom Events
-- =============================================

-- =============================================
	-- GameState Events
-- =============================================

function VuBattleRoyaleHud:OnGameStateChanged(p_GameState)
	if p_GameState == nil then
		return
	end

	self.m_GameState = p_GameState

	if not self.m_IsLevelLoaded then
		return
	end

	if self.m_GameState == GameStates.None or self.m_GameState == GameStates.Warmup then
		self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
			["msg"] = "Open team lobby",
			["key"] = "F10",
		}))
		self.m_HudOnSetUIState:Update(UiStates.Game)
	end

	if self.m_GameState == GameStates.WarmupToPlane then
		self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
			["msg"] = nil,
			["key"] = nil,
		}))

		m_HudUtils:SetIsInDeployScreen(false)
		WebUI:ExecuteJS("ToggleDeployMenu(false);")
		m_HudUtils:ShowroomCamera(false)
		m_VanillaUIManager:EnableShowroomSoldier(false)
		m_HudUtils:ExitSoundState()
		m_HudUtils:HUDEnterUIGraph()

		self.m_HudOnSetUIState:Update(UiStates.Loading)
	elseif self.m_GameState == GameStates.Plane then
		self.m_HudOnSetUIState:Update(UiStates.Game)
	end

	self.m_HudOnGameState:Update(GameStatesStrings[p_GameState])
end

function VuBattleRoyaleHud:OnGameOverScreen(p_IsWin)
	self.m_HudOnGameOverScreen:ForceUpdate(json.encode({
		["isWin"] = p_IsWin,
	}))
end

function VuBattleRoyaleHud:OnUpdatePlacement()
	if self.m_BrPlayer.m_Team.m_Placement == nil then
		return
	end

	self.m_HudOnUpdatePlacement:Update(self.m_BrPlayer.m_Team.m_Placement)
end

-- =============================================
	-- PhaseManager Events
-- =============================================

function VuBattleRoyaleHud:OnPhaseManagerUpdate(p_Data)
	self.m_HudOnUpdateCircles:Update(json.encode(p_Data))
end

function VuBattleRoyaleHud:OnOuterCircleMove(p_OuterCircle)
	self.m_HudOnUpdateCircles:Update(json.encode({OuterCircle = p_OuterCircle}))
end

-- =============================================
	-- Gunship Events
-- =============================================

function VuBattleRoyaleHud:OnGunshipEnable()
	self.m_HudOnPlayerIsOnPlane:Update(true)
	self.m_IsPlayerOnPlane = true
end

function VuBattleRoyaleHud:OnGunshipDisable()
	self.m_HudOnPlanePos:Update(nil)
	self.m_HudOnPlaneYaw:Update(nil)
end

function VuBattleRoyaleHud:OnJumpOutOfGunship()
	self.m_HudOnPlayerIsOnPlane:Update(false)
	self.m_IsPlayerOnPlane = false
end

function VuBattleRoyaleHud:OnGunshipPosition(p_Trans)
	if p_Trans == nil then
		self.m_HudOnPlanePos:Update(nil)
		return
	end

	local s_Table = {
		x = p_Trans.trans.x,
		y = p_Trans.trans.y,
		z = p_Trans.trans.z
	}

	if self.m_IsPlayerOnPlane then
		self.m_HudOnPlayerPos:Update(json.encode(s_Table))
	end

	self.m_HudOnPlanePos:Update(json.encode(s_Table))
end

function VuBattleRoyaleHud:OnGunshipYaw(p_Trans)
	if p_Trans == nil then
		self.m_HudOnPlaneYaw:Update(nil)
		return
	end

	local s_YawRad = (math.atan(p_Trans.forward.z, p_Trans.forward.x) - (math.pi / 2)) % (2 * math.pi)
	local s_Floored = math.floor((180 / math.pi) * s_YawRad)
	self.m_HudOnPlaneYaw:Update(s_Floored)
end

function VuBattleRoyaleHud:OnGunshipPlayerYaw(p_Yaw)
	local s_Yaw = math.floor((180 / math.pi) * p_Yaw) + 90
	self.m_HudOnPlayerYaw:Update(s_Yaw)
end

-- =============================================
	-- Some more Events
-- =============================================

function VuBattleRoyaleHud:OnUpdateTimer(p_Time)
	self.m_HudOnUpdateTimer:Update(math.floor(p_Time))
end

function VuBattleRoyaleHud:OnDamageConfirmPlayerKill(p_VictimName, p_IsKill)
	if self.m_BrPlayer == nil then
		return
	end

	if p_VictimName == nil or p_IsKill == nil then
		return
	end

	self.m_HudOnNotifyInflictorAboutKillOrKnock:ForceUpdate(json.encode({
		["name"] = p_VictimName,
		["kills"] = (self.m_BrPlayer.m_Kills or 0),
		["isKill"] = p_IsKill,
	}))
end

function VuBattleRoyaleHud:OnTeamJoinDenied(p_Error)
	if p_Error == nil then
		return
	end

	self.m_HudOnTeamJoinError:ForceUpdate(p_Error)
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleHud:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	if p_EventType ~= UIInputActionEventType.UIInputActionEventType_Pressed or SpectatorManager:GetSpectating() then
		return
	end

	if p_Action == UIInputAction.UIInputAction_MapSize then
		if m_HudUtils:GetIsMapOpened() then
			m_HudUtils:SetIsMapOpened(false)
			WebUI:ExecuteJS("OnOpenCloseMap(false);")
			m_HudUtils:HUDEnterUIGraph()
			m_HudUtils:ShowCrosshair(true)
		else
			m_HudUtils:SetIsMapOpened(true)
			WebUI:ExecuteJS("OnOpenCloseMap(true);")
			m_HudUtils:OnEnableMouse()
		end

		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_MapZoom then
		WebUI:ExecuteJS("OnMapZoomChange();")
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end

	if p_Action == UIInputAction.UIInputAction_ToggleMinimapType then
		WebUI:ExecuteJS("OnMapSwitchRotation();")
		p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
	end
end

-- =============================================
-- Functions
-- =============================================

-- =============================================
	-- Being Interacted Callbacks
-- =============================================

function VuBattleRoyaleHud:RegisterOnBeingInteractedCallbacks(p_Soldier)
	for i, l_Entity in pairs(p_Soldier.bus.entities) do
		if l_Entity.data ~= nil then
			if l_Entity.data.instanceGuid == Guid("34130787-22C3-0F9D-6AA7-4BC214FA1734") then
				l_Entity:RegisterEventCallback(self, self.OnBeingInteractedStarted)
			elseif l_Entity.data.instanceGuid == Guid("D0F06E9A-AE8B-E614-F8C3-54A47CF22565") then
				l_Entity:RegisterEventCallback(self, self.OnBeingInteractedFinished)
			end
		end
	end
end

function VuBattleRoyaleHud:OnBeingInteractedStarted(p_Entity, p_Event)
	m_Logger:Write("The interaction with the local player started")
	WebUI:ExecuteJS("OnInteractStart(5);")
end

function VuBattleRoyaleHud:OnBeingInteractedFinished(p_Entity, p_Event)
	m_Logger:Write("The interaction with the local player ended")
	WebUI:ExecuteJS("OnInteractEnd();")
end

-- =============================================
	-- Custom Level Finalized 'Event'
-- =============================================

function VuBattleRoyaleHud:OnLevelFinalized()
	if self.m_IsLevelLoaded then
		return
	end

	self.m_IsLevelLoaded = true
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
	m_HudUtils:EnableTabScoreboard()
	m_HudUtils:EnableBlurEffect(false)
	m_HudUtils:StartupChat()
	WebUI:ExecuteJS("OnLevelFinalized('" .. SharedUtils:GetLevelName() .. "');")
	self:OnGameStateChanged(self.m_GameState)
	self:RegisterEscMenuCallbacks()
	m_HudUtils:OnEnableMouse()
end

-- =============================================
	-- Esc Menu Callbacks
-- =============================================

function VuBattleRoyaleHud:RegisterEscMenuCallbacks()
	local s_EntityIterator = EntityManager:GetIterator('ClientUIGraphEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = Entity(s_Entity)

		if s_Entity.data ~= nil and s_Entity.data.instanceGuid == Guid("B9437F95-2EBC-4F22-A5F6-F4D0F1331A5E") then
			-- Registering the EventCallback on modreload => crash on first call
			s_Entity:RegisterEventCallback(self, self.OnEscapeMenuCallback)
		end

		s_Entity = s_EntityIterator:Next()
	end
end

function VuBattleRoyaleHud:OnEscapeMenuCallback(p_Entity, p_EntityEvent)
	if p_EntityEvent.eventId == MathUtils:FNVHash("EnterFromGame") then
		self:OnOpenEscapeMenu()
		return false
	elseif p_EntityEvent.eventId == MathUtils:FNVHash("ExitUIGraph") then
		self:OnResume()
	end
end


-- =============================================
	-- Open Escape Menu
-- =============================================

function VuBattleRoyaleHud:OnOpenEscapeMenu()
	m_HudUtils:OnEnableMouse()
	m_HudUtils:OnDisableGameInput()
	m_HudUtils:ShowCrosshair(false)
	m_HudUtils:EnableBlurEffect(true)
	m_HudUtils:SetIsInEscMenu(true)

	self.m_HudOnSetUIState:Update(UiStates.Menu)
	-- Add WebUI
end


-- =============================================
	-- Close Escape Menu
-- =============================================

function VuBattleRoyaleHud:OnResume()
	m_HudUtils:SetIsInEscMenu(false)
	m_HudUtils:DisableMenuVisualEnv()
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
	m_HudUtils:EnableTabScoreboard()
	m_HudUtils:EnableBlurEffect(false)
	m_HudUtils:StartupChat()
	self.m_HudOnSetUIState:Update(UiStates.Game)
end

-- =============================================
	-- Open Options
-- =============================================

function VuBattleRoyaleHud:OnOptions()
	m_HudUtils:SetIsInEscMenu(false)
	self.m_HudOnSetUIState:Update(UiStates.Hidden)
	local s_UIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	local s_UIGraphEntity = s_UIGraphEntityIterator:Next()

	while s_UIGraphEntity do
		if s_UIGraphEntity.data.instanceGuid == Guid("EDF20470-4AD7-44BC-96E1-9DF61989BE58") then
			s_UIGraphEntity = Entity(s_UIGraphEntity)
			s_UIGraphEntity:FireEvent("EnterOptions")
			return
		end

		s_UIGraphEntity = s_UIGraphEntityIterator:Next()
	end
end

-- =============================================
	-- Quit the game
-- =============================================

function VuBattleRoyaleHud:OnQuit()
	local s_Data = self:GetQuitEntityData()
	local s_QuitPopupGraphEntity = EntityManager:CreateEntity(s_Data, LinearTransform())
	s_QuitPopupGraphEntity:FireEvent('Quit')
end

function VuBattleRoyaleHud:GetQuitEntityData()
	local s_QuitPopupGraphAsset = UIGraphAsset()
	s_QuitPopupGraphAsset.modal = false
	s_QuitPopupGraphAsset.protectScreens = true
	s_QuitPopupGraphAsset.isWin32UIGraphAsset = true
	s_QuitPopupGraphAsset.isXenonUIGraphAsset = true
	s_QuitPopupGraphAsset.isPs3UIGraphAsset = true

	local s_InputNode = InstanceInputNode()
	s_InputNode.parentGraph = s_QuitPopupGraphAsset
	s_InputNode.name = 'Quit'
	s_InputNode.isRootNode = false
	s_InputNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_InputNode)

	local s_ActionNode = ActionNode()
	s_ActionNode.actionKey = MathUtils:FNVHash("QuitGame")
	s_ActionNode.inValue = UINodePort()
	s_ActionNode.out = UINodePort()
	s_ActionNode.appendIncomingParams = false
	s_ActionNode.name = 'Quit'
	s_ActionNode.isRootNode = false
	s_ActionNode.parentGraph = s_QuitPopupGraphAsset
	s_ActionNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_ActionNode)

	local s_InputToDialogNodeConnection = UINodeConnection()
	s_InputToDialogNodeConnection.sourceNode = s_InputNode
	s_InputToDialogNodeConnection.targetNode = s_ActionNode
	s_InputToDialogNodeConnection.sourcePort = s_InputNode.out
	s_InputToDialogNodeConnection.targetPort = s_ActionNode.inValue
	s_InputToDialogNodeConnection.numScreensToPop = 0
	s_QuitPopupGraphAsset.connections:add(s_InputToDialogNodeConnection)

	local s_OutputNode = InstanceOutputNode()
	s_OutputNode.inValue = UINodePort()
	s_OutputNode.id = MathUtils:FNVHash("QuitOrSuicide")
	s_OutputNode.destroyGraph = true
	s_OutputNode.name = "QuitOrSuicide"
	s_OutputNode.isRootNode = false
	s_OutputNode.parentGraph = s_QuitPopupGraphAsset
	s_OutputNode.parentIsScreen = false
	s_QuitPopupGraphAsset.nodes:add(s_OutputNode)

	local s_ActionToOutputNodeConnection = UINodeConnection()
	s_ActionToOutputNodeConnection.sourceNode = s_ActionNode
	s_ActionToOutputNodeConnection.targetNode = s_OutputNode
	s_ActionToOutputNodeConnection.sourcePort = s_ActionNode.out
	s_ActionToOutputNodeConnection.targetPort = s_OutputNode.inValue
	s_ActionToOutputNodeConnection.numScreensToPop = 1
	s_QuitPopupGraphAsset.connections:add(s_ActionToOutputNodeConnection)

	local s_QuitPopupGraphEntityData = UIGraphEntityData()
	s_QuitPopupGraphEntityData.graphAsset = s_QuitPopupGraphAsset
	s_QuitPopupGraphEntityData.popPreviousGraph = false

	return s_QuitPopupGraphEntityData
end

-- =============================================
	-- Push HUD Information
-- =============================================

function VuBattleRoyaleHud:PushLocalPlayerPos()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer.alive == false then
		return
	end

	local s_LocalSoldier = s_LocalPlayer.soldier

	if s_LocalSoldier == nil then
		return
	end

	local s_SoldierLinearTransform = s_LocalSoldier.worldTransform
	local s_Position = s_SoldierLinearTransform.trans
	local s_Table = {
		x = s_Position.x,
		y = s_Position.y,
		z = s_Position.z
	}

	self.m_HudOnPlayerPos:Update(json.encode(s_Table))
	return
end

function VuBattleRoyaleHud:PushLocalPlayerYaw()
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil or (s_LocalPlayer.soldier == nil and s_LocalPlayer.corpse == nil) then
		return
	end

	local s_Camera = ClientUtils:GetCameraTransform()

	-- TODO: Put this in utils
	local s_YawRad = (math.atan(s_Camera.forward.z, s_Camera.forward.x) + (math.pi / 2)) % (2 * math.pi)
	self.m_HudOnPlayerYaw:Update(math.floor((180 / math.pi) * s_YawRad))
	return
end

function VuBattleRoyaleHud:PushUpdatePlayersInfo()
	local s_Players = PlayerManager:GetPlayers()
	local s_PlayersObject = {}

	for _, l_Player in pairs(s_Players) do
		local l_State = 3

		if l_Player.alive then
			l_State = 1
		end

		table.insert(s_PlayersObject, {
			["id"] = l_Player.id,
			["name"] = l_Player.name,
			["kill"] = 0,
			["state"] = l_State,
			["isTeamLeader"] = false,
		})
	end

	self.m_HudOnPlayersInfo:Update(json.encode(s_PlayersObject))

	if self.m_BrPlayer == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil then
		local s_LocalPlayerTable = {
			["id"] = s_LocalPlayer.id,
			["name"] = s_LocalPlayer.name,
			["kill"] =  (self.m_BrPlayer.m_Kills or 0),
			["state"] = self.m_BrPlayer:GetState(),
			["isTeamLeader"] = self.m_BrPlayer.m_IsTeamLeader,
			["color"] = self.m_BrPlayer:GetColor(true),
		}
		self.m_HudOnLocalPlayerInfo:Update(json.encode(s_LocalPlayerTable))
	end
end

function VuBattleRoyaleHud:PushLocalPlayerAmmoArmorAndHealth()
	if self.m_BrPlayer == nil then
		return
	end
	
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if SpectatorManager:GetSpectating() then
		s_LocalPlayer = SpectatorManager:GetSpectatedPlayer()
	end

	if s_LocalPlayer == nil then
		return
	end

	if s_LocalPlayer.alive == false then
		self.m_HudOnPlayerHealth:Update(0)
		return
	end

	local s_LocalSoldier = s_LocalPlayer.soldier

	if s_LocalSoldier == nil then
		return
	end

	local s_Inventory = { }

	for l_Index, l_Weapon in pairs(s_LocalSoldier.weaponsComponent.weapons) do
		if l_Weapon ~= nil then
			s_Inventory[l_Index] = l_Weapon.name
		end
	end

	if s_LocalSoldier.isInteractiveManDown then
		self.m_HudOnPlayerHealth:Update(s_LocalSoldier.health)
	else
		self.m_HudOnPlayerHealth:Update(s_LocalSoldier.health - 100)
	end

	self.m_HudOnPlayerArmor:Update(self.m_BrPlayer.m_Armor:GetPercentage())
	self.m_HudOnPlayerPrimaryAmmo:Update(s_LocalSoldier.weaponsComponent.currentWeapon.primaryAmmo)
	self.m_HudOnPlayerSecondaryAmmo:Update(s_LocalSoldier.weaponsComponent.currentWeapon.secondaryAmmo)
	self.m_HudOnPlayerFireLogic:Update(s_LocalSoldier.weaponsComponent.currentWeapon.fireLogic)
	self.m_HudOnPlayerCurrentWeapon:Update(s_LocalSoldier.weaponsComponent.currentWeapon.name)
	self.m_HudOnPlayerWeapons:Update(json.encode(s_Inventory))
	--self.m_HudOnPlayerCurrentSlot:Update(s_LocalSoldier.weaponsComponent.currentWeaponSlot)
	return
end

function VuBattleRoyaleHud:PushLocalPlayerTeam()
	if self.m_BrPlayer == nil then
		return
	end

	self.m_HudOnUpdateTeamSize:Update(ServerConfig.PlayersPerTeam)

	if self.m_BrPlayer.m_Team ~= nil then
		self.m_HudOnUpdateTeamId:Update(self.m_BrPlayer.m_Team.m_Id)
	end
end

function VuBattleRoyaleHud:PushMarkerUpdate()
	for _, l_Marker in pairs(self.m_Markers) do
		if l_Marker == nil then
			return
		end

		local s_WorldToScreen = ClientUtils:WorldToScreen(Vec3(l_Marker.PositionX, l_Marker.PositionY, l_Marker.PositionZ))

		if s_WorldToScreen == nil then
			return
		end

		WebUI:ExecuteJS(string.format('OnUpdateMarker("%s", %s, %s)', l_Marker.Key, s_WorldToScreen.x, s_WorldToScreen.y))
	end
end

-- =============================================
	-- Create / Remove Marker
-- =============================================

function VuBattleRoyaleHud:CreateMarker(p_Key, p_PositionX, p_PositionY, p_PositionZ, p_Color)
	--[[local s_WorldToScreen = ClientUtils:WorldToScreen(Vec3(p_PositionX, p_PositionY, p_PositionZ))
	if s_WorldToScreen == nil then
		return
	end]]

	local s_Marker = {
		Key = p_Key,
		PositionX = p_PositionX,
		PositionY = p_PositionY,
		PositionZ = p_PositionZ,
		Color = p_Color,
		WorldToScreenX = 0,
		WorldToScreenY = 0,
	}

	print("CreateMarker: " .. p_Key)

	self.m_Markers[p_Key] = s_Marker
	WebUI:ExecuteJS(
		string.format(
			'OnCreateMarker("%s", "%s", %s, %s, %s, %s)',
			s_Marker.Key,
			s_Marker.Color,
			s_Marker.PositionX,
			s_Marker.PositionZ,
			s_Marker.WorldToScreenX,
			s_Marker.WorldToScreenY
		)
	)
end

function VuBattleRoyaleHud:RemoveMarker(p_Key)
	if self.m_Markers[p_Key] == nil then
		return
	end

	self.m_Markers[p_Key] = nil
	WebUI:ExecuteJS(string.format('OnRemoveMarker("%s")', p_Key))
end

if g_VuBattleRoyaleHud == nil then
	g_VuBattleRoyaleHud = VuBattleRoyaleHud()
end

return g_VuBattleRoyaleHud
