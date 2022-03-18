---@class VuBattleRoyaleHud
VuBattleRoyaleHud = class "VuBattleRoyaleHud"

---@type Logger
local m_Logger = Logger("VuBattleRoyaleHud", false)

---@type EscMenu
local m_EscMenu = require "UI/EscMenu"
---@type DeployScreen
local m_DeployScreen = require "UI/DeployScreen"
---@type HudUtils
local m_HudUtils = require "UI/Utils/HudUtils"
---@type BRPlayer
local m_BrPlayer = require "BRPlayer"
---@type TimerManager
local m_TimerManager = require "__shared/Utils/Timers"

---@return ModSetting
local function GetShowFPSSetting()
	local s_ShowFPSSetting = SettingsManager:GetSetting("ShowFPS")

	if s_ShowFPSSetting == nil then
		---@type SettingOptions
		local s_SettingOptions = SettingOptions()
		s_SettingOptions.displayName = "Show FPS"
		s_SettingOptions.showInUi = true
		s_ShowFPSSetting = SettingsManager:DeclareBool("ShowFPS", false, s_SettingOptions)
		s_ShowFPSSetting.value = false

		m_Logger:Write("GetShowFPSSetting created.")
	end

	return s_ShowFPSSetting
end

function VuBattleRoyaleHud:__init()
	---@type GameStates|integer
	self.m_GameState = GameStates.None
	self.m_Ticks = 0.0
	self.m_IsPlayerOnPlane = false

	self.m_IsLevelLoaded = false

	self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart
	self.m_PlayersPerTeam = ServerConfig.PlayersPerTeam

	---@type table<integer, table>
	self.m_Markers = {}

	---@type table<string, integer>
	self.m_ManDownMapMarkers = {}

	self.m_ShowInteractiveReviveMessage = false
	self.m_ShowFPSSetting = GetShowFPSSetting()
	self.m_FPSTimer = 0.0
	self.m_FPSCount = 0

	self:RegisterVars()
end

function VuBattleRoyaleHud:RegisterVars()
	self.m_HudOnPlayerPos = CachedJsExecutor("OnPlayerPos(%s)", nil)
	self.m_HudOnPlayerYaw = CachedJsExecutor("OnPlayerYaw(%s)", 0)
	self.m_HudOnPlayerIsOnPlane = CachedJsExecutor("OnPlayerIsOnPlane(%s)", false)
	self.m_HudOnPlanePos = CachedJsExecutor("OnPlanePos(%s)", nil)
	self.m_HudOnPlaneYaw = CachedJsExecutor("OnPlaneYaw(%s)", 0)
	self.m_HudOnUpdateCircles = CachedJsExecutor("OnUpdateCircles(%s)", nil)
	self.m_HudOnGameState = CachedJsExecutor("OnGameState('%s')", GameStatesStrings[GameStates.None])
	self.m_HudOnPlayersInfo = CachedJsExecutor("OnPlayersInfo(%s)", nil)
	self.m_HudOnLocalPlayerInfo = CachedJsExecutor("OnLocalPlayerInfo(%s)", nil)
	self.m_HudOnUpdateTimer = CachedJsExecutor("OnUpdateTimer(%s)", nil)
	self.m_HudOnMinPlayersToStart = CachedJsExecutor("OnMinPlayersToStart(%s)", nil)
	self.m_HudOnPlayerHealth = CachedJsExecutor("OnPlayerHealth(%s)", 0)
	self.m_HudOnPlayerArmor = CachedJsExecutor("OnPlayerArmor(%s)", 0)
	self.m_HudOnPlayerHelmet = CachedJsExecutor("OnPlayerHelmet(%s)", 0)
	self.m_HudOnPlayerPrimaryAmmo = CachedJsExecutor("OnPlayerPrimaryAmmo(%s)", 0)
	self.m_HudOnPlayerSecondaryAmmo = CachedJsExecutor("OnPlayerSecondaryAmmo(%s)", 0)
	self.m_HudOnPlayerFireLogic = CachedJsExecutor("OnPlayerFireLogic(%s)", 0)
	self.m_HudOnPlayerCurrentWeapon = CachedJsExecutor("OnPlayerCurrentWeapon('%s')", "")
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
	self.m_HudOnUpdateLevelName = CachedJsExecutor("OnUpdateLevelName('%s')", "")
end

function VuBattleRoyaleHud:ResetVars()
	self.m_HudOnPlayerPos:ForceUpdate(nil)
	self.m_HudOnPlayerYaw:ForceUpdate(0)
	self.m_HudOnPlayerIsOnPlane:ForceUpdate(false)
	self.m_HudOnPlanePos:ForceUpdate(nil)
	self.m_HudOnPlaneYaw:ForceUpdate(0)
	self.m_HudOnUpdateCircles:ForceUpdate(nil)
	self.m_HudOnGameState:ForceUpdate(GameStatesStrings[GameStates.None])
	self.m_HudOnPlayersInfo:ForceUpdate(nil)
	self.m_HudOnLocalPlayerInfo:ForceUpdate(nil)
	self.m_HudOnUpdateTimer:ForceUpdate(nil)
	self.m_HudOnMinPlayersToStart:ForceUpdate(self.m_MinPlayersToStart)
	self.m_HudOnPlayerHealth:ForceUpdate(0)
	self.m_HudOnPlayerArmor:ForceUpdate(0)
	self.m_HudOnPlayerHelmet:ForceUpdate(0)
	self.m_HudOnPlayerPrimaryAmmo:ForceUpdate(0)
	self.m_HudOnPlayerSecondaryAmmo:ForceUpdate(0)
	self.m_HudOnPlayerFireLogic:ForceUpdate(0)
	self.m_HudOnPlayerCurrentWeapon:ForceUpdate("")
	-- self.m_HudOnUpdateTeamPlayers:ForceUpdate(nil)
	-- self.m_HudOnUpdateTeamLocked:ForceUpdate(false)
	-- self.m_HudOnUpdateTeamId:ForceUpdate("-")
	-- self.m_HudOnUpdateTeamSize:ForceUpdate(0)
	self.m_HudOnTeamJoinError:ForceUpdate(nil)
	self.m_HudOnNotifyInflictorAboutKillOrKnock:ForceUpdate(nil)
	self.m_HudOnInteractiveMessageAndKey:ForceUpdate(nil)
	self.m_HudOnGameOverScreen:ForceUpdate(nil)
	self.m_HudOnUpdatePlacement:ForceUpdate(99)
	-- self.m_HudOnSetUIState:ForceUpdate(UiStates.Loading)
end

-- =============================================
-- Events
-- =============================================

---VEXT Shared Extension:Loaded Event
function VuBattleRoyaleHud:OnExtensionLoaded()
	WebUI:Init()
	WebUI:Show()
end

---VEXT Shared Extension:Unloading Event
function VuBattleRoyaleHud:OnExtensionUnloading()
	self.m_IsLevelLoaded = false
	m_HudUtils:SetIsMapOpened(false)
	WebUI:ExecuteJS("OnOpenCloseMap(false);")
	self.m_HudOnSetUIState:Update(UiStates.Hidden)
end

---VEXT Client Level:Loaded Event
function VuBattleRoyaleHud:OnLevelLoaded()
	m_DeployScreen:OnLevelLoaded()
	m_TimerManager:Timeout(5.0, function() self:OnLevelFinalized() end)
end

---VEXT Shared Level:Destroy Event
function VuBattleRoyaleHud:OnLevelDestroy()
	self.m_IsLevelLoaded = false
	m_HudUtils:SetIsMapOpened(false)
	WebUI:ExecuteJS("OnOpenCloseMap(false);")
	self.m_HudOnSetUIState:Update(UiStates.Loading)
end

---VEXT Shared Engine:Update Event
function VuBattleRoyaleHud:OnEngineUpdate(p_DeltaTime)
	if self.m_ShowFPSSetting.value then
		if self.m_FPSTimer < 1.0 then
			self.m_FPSCount = self.m_FPSCount + 1
			self.m_FPSTimer = self.m_FPSTimer + p_DeltaTime
		else
			--TODO: send FPS to WebUI
			self.m_FPSTimer = 0.0
			self.m_FPSCount = 0
		end
	end

	if not self.m_IsLevelLoaded then
		self.m_HudOnUpdateLevelName:Update(SharedUtils:GetLevelName())
		return
	end

	if self.m_Ticks >= ServerConfig.HudUpdateRate then
		self.m_HudOnMinPlayersToStart:Update(self.m_MinPlayersToStart)
		self.m_HudOnUpdateTeamSize:Update(self.m_PlayersPerTeam)

		self:PushUpdatePlayersInfo()
		self:PushLocalPlayerTeam()
		self.m_Ticks = 0.0
	end

	self.m_Ticks = self.m_Ticks + p_DeltaTime
end

---Called from VEXT UpdateManager:Update
---UpdatePass.UpdatePass_PreFrame
function VuBattleRoyaleHud:OnUIDrawHud()
	if not self.m_IsLevelLoaded then
		return
	end

	self:PushManDownMapMarkers()
	--self:PushMarkerUpdate()
	self:PushLocalPlayerPos()
	self:PushLocalPlayerYaw()
	self:PushLocalPlayerAmmoArmorAndHealth()
	self:OnUpdatePlacement()
	self:OnUpdateTeamData()
end

---VEXT Client Client:UpdateInput Event
function VuBattleRoyaleHud:OnClientUpdateInput()
	if not self.m_IsLevelLoaded then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_F10)
		and self.m_GameState ~= GameStates.Plane and self.m_GameState ~= GameStates.PlaneToFirstCircle then
		if self.m_GameState ~= GameStates.Match and s_LocalPlayer.soldier ~= nil then
			m_DeployScreen:OpenDeployScreen()
			NetEvents:Send(PlayerEvents.Despawn)
		end
	end

	if InputManager:WentKeyDown(InputDeviceKeys.IDK_LeftCtrl) then
		-- We pass the state of the CTRL to the UI, if you hold it down
		-- you will split the items when you drop them from the inventory.
		WebUI:ExecuteJS("OnLeftCtrl(true);")
	end

	if InputManager:WentKeyUp(InputDeviceKeys.IDK_LeftCtrl) then
		-- We pass the state of the CTRL to the UI, if you hold it down
		-- you will split the items when you drop them from the inventory.
		WebUI:ExecuteJS("OnLeftCtrl(false);")
	end

	m_EscMenu:OnClientUpdateInput()
end

---VEXT Client Player:Respawn Event
---@param p_Player Player
function VuBattleRoyaleHud:OnPlayerRespawn(p_Player)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= p_Player or p_Player.soldier == nil then
		return
	end

	WebUI:ExecuteJS("OnMapShow(true);")
	self:PushLocalPlayerPos()
	self:PushLocalPlayerYaw()
	m_TimerManager:Timeout(0.75, function()
		m_HudUtils:ShowCrosshair(true)
	end)

	if self.m_GameState <= GameStates.Warmup then
		return
	end

	self:RegisterSoldierInteractionCallbacks(p_Player.soldier)
end

---VEXT Client Soldier:HealthAction Event
---@param p_Soldier SoldierEntity
---@param p_Action HealthStateAction|integer
function VuBattleRoyaleHud:OnSoldierHealthAction(p_Soldier, p_Action)
	if p_Soldier.teamId ~= TeamId.Team1 then
		-- on the client all mates are in Team1
		return
	end

	if p_Action == HealthStateAction.OnInteractiveManDown and p_Soldier.player ~= nil then
		m_Logger:Write("HealthStateAction OnInteractiveManDown for player: " .. p_Soldier.player.name)
		local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
		---@type SpatialEntity
		local s_Entity = s_EntityIterator:Next()

		while s_Entity do
			s_Entity = SpatialEntity(s_Entity)
			local s_MapMarkerEntityData = MapMarkerEntityData(s_Entity.data)

			if s_MapMarkerEntityData.sid == "ID_H_MAP_PREFABS_REVIVE_ME" and s_Entity.transform.trans == Vec3(-9999.0, -9999.0, -9999.0) then
				m_Logger:Write("MapMarkerEntity found - changing transform")
				self.m_ManDownMapMarkers[p_Soldier.player.name] = s_Entity.instanceId
				break
			end

			s_Entity = s_EntityIterator:Next()
		end
	end
end

-- =============================================
-- Custom Events
-- =============================================

-- =============================================
-- PlayerKilled Event
-- =============================================

---Custom Client ServerPlayer:Killed NetEvent
---@param p_PlayerName string
function VuBattleRoyaleHud:OnPlayerKilled(p_PlayerName)
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer == nil then
		return
	end

	local s_AliveSquadCount = 0
	local s_TeamPlayers = m_BrPlayer.m_Team:PlayersTable()
	local s_TeamMateDied = false

	if s_TeamPlayers ~= nil then
		for _, l_Teammate in ipairs(s_TeamPlayers) do
			if l_Teammate ~= nil then
				if l_Teammate.State ~= BRPlayerState.Dead then

					s_AliveSquadCount = s_AliveSquadCount + 1

					if s_AliveSquadCount == 2 or s_LocalPlayer.name ~= l_Teammate.Name then
						-- Your squad is still playing; cancel
						return
					end

					if p_PlayerName == l_Teammate.Name then
						s_TeamMateDied = true
					end
				end
			end
		end
	end

	if not s_TeamMateDied then
		return
	end

	if p_PlayerName == s_LocalPlayer.name and s_AliveSquadCount == 1 then
		-- If the local player dies and the AliveSquadCount is 1 (local player doesnt update that fast)
		s_AliveSquadCount = 0
	end

	if s_AliveSquadCount == 0 then
		self:OnGameOverScreen(false)
		return
	end
end

---Custom Client Player:BrokeShield NetEvent
---@param p_PlayerName string
function VuBattleRoyaleHud:OnPlayerBrokeShield(p_PlayerName)
	WebUI:ExecuteJS("OnShieldBreak();")
end

-- =============================================
-- GameState Events
-- =============================================

---Custom Client PlayerEvents.GameStateChanged NetEvent
---@param p_GameState GameStates|integer
function VuBattleRoyaleHud:OnGameStateChanged(p_GameState)
	if self.m_GameState == p_GameState then
		return
	end

	self.m_GameState = p_GameState

	if self.m_GameState == GameStates.None then
		WebUI:ExecuteJS("ResetAllValues();")
		self:ResetVars()
	end

	if not self.m_IsLevelLoaded then
		return
	end

	if self.m_GameState == GameStates.WarmupToPlane then
		self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
			["msg"] = nil,
			["key"] = nil,
		}))
		self.m_ShowInteractiveReviveMessage = false

		if not SpectatorManager:GetSpectating() then
			m_DeployScreen:CloseDeployScreen()
			self.m_HudOnSetUIState:Update(UiStates.Loading)
		end
	else
		self.m_HudOnSetUIState:Update(UiStates.Game)
	end

	self.m_HudOnGameState:Update(GameStatesStrings[p_GameState])
end

---Custom Client PlayerEvents.WinnerTeamUpdate NetEvent
---@param p_IsWin boolean
---@param p_Team table
function VuBattleRoyaleHud:OnGameOverScreen(p_IsWin, p_Team)
	self.m_HudOnGameOverScreen:ForceUpdate(json.encode({
		["isWin"] = p_IsWin,
		["team"] = p_Team,
	}))
end

-- =============================================
-- PhaseManager Events
-- =============================================

---Custom Client PhaseManagerEvent.Update Event
---@param p_Data table
function VuBattleRoyaleHud:OnPhaseManagerUpdate(p_Data)
	self.m_HudOnUpdateCircles:Update(json.encode(p_Data))
end

---Custom Client PhaseManagerEvent.CircleMove Event
---@param p_OuterCircle table
function VuBattleRoyaleHud:OnOuterCircleMove(p_OuterCircle)
	self.m_HudOnUpdateCircles:Update(json.encode({ OuterCircle = p_OuterCircle }))
end

-- =============================================
-- Gunship Events
-- =============================================

---Custom Client GunshipEvents.Enable NetEvent
function VuBattleRoyaleHud:OnGunshipEnable()
	WebUI:ExecuteJS("OnMapShow(true);") -- Just to be sure
	self.m_HudOnPlayerIsOnPlane:Update(true)
	self.m_IsPlayerOnPlane = true
end

---Custom Client GunshipEvents.Disable NetEvent
function VuBattleRoyaleHud:OnGunshipDisable()
	self.m_HudOnPlanePos:Update(nil)
	self.m_HudOnPlaneYaw:Update(nil)
end

---Custom Client GunshipEvents.JumpOut NetEvent
function VuBattleRoyaleHud:OnJumpOutOfGunship()
	WebUI:ExecuteJS("OnMapShow(true);") -- Just to be sure
	self.m_HudOnPlayerIsOnPlane:Update(false)
	self.m_IsPlayerOnPlane = false
end

---Called from GunshipClient
---@param p_Trans LinearTransform|nil
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

---Called from GunshipClient
---@param p_Trans LinearTransform|nil
function VuBattleRoyaleHud:OnGunshipYaw(p_Trans)
	if p_Trans == nil then
		self.m_HudOnPlaneYaw:Update(nil)
		return
	end

	---@type number
	local s_YawRad = (math.atan(p_Trans.forward.z, p_Trans.forward.x) - (math.pi / 2)) % (2 * math.pi)
	self.m_HudOnPlaneYaw:Update(math.floor((180 / math.pi) * s_YawRad))
end

---@param p_YawRad number
function VuBattleRoyaleHud:OnGunshipPlayerYaw(p_YawRad)
	local s_YawRad = p_YawRad % (2 * math.pi)
	self.m_HudOnPlayerYaw:Update(math.floor((180 / math.pi) * s_YawRad) + 90)
end

-- =============================================
-- Some more Events
-- =============================================

---Custom Client PlayerEvents.UpdateTimer NetEvent
---@param p_Time number|nil
function VuBattleRoyaleHud:OnUpdateTimer(p_Time)
	self.m_HudOnUpdateTimer:Update(math.floor(p_Time))
end

---Called from OnDamageConfirmPlayerDown or OnDamageConfirmPlayerKill in client init
---@param p_VictimName string
---@param p_IsKill boolean
function VuBattleRoyaleHud:OnDamageConfirmPlayerKill(p_VictimName, p_IsKill)
	if p_VictimName == nil or p_IsKill == nil then
		return
	end

	self.m_HudOnNotifyInflictorAboutKillOrKnock:ForceUpdate(json.encode({
		["name"] = p_VictimName,
		["kills"] = (m_BrPlayer.m_Kills or 0),
		["isKill"] = p_IsKill,
	}))
end

---Custom Client TeamManagerNetEvent.TeamJoinDenied NetEvent
---@param p_Error TeamManagerErrors|integer
function VuBattleRoyaleHud:OnTeamJoinDenied(p_Error)
	if p_Error == nil then
		return
	end

	self.m_HudOnTeamJoinError:ForceUpdate(p_Error)
end

-- =============================================
-- Hooks
-- =============================================

---VEXT Client UI:InputConceptEvent Hook
---@param p_HookCtx HookContext
---@param p_EventType UIInputActionEventType|integer
---@param p_Action UIInputAction|integer
function VuBattleRoyaleHud:OnInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	if p_EventType ~= UIInputActionEventType.UIInputActionEventType_Pressed then
		return
	end

	if p_Action == UIInputAction.UIInputAction_MapSize then
		if m_HudUtils:GetIsMapOpened() then
			m_HudUtils:SetIsMapOpened(false)
			WebUI:ExecuteJS("OnOpenCloseMap(false);")
			m_HudUtils:HUDEnterUIGraph()
			m_HudUtils:ShowCrosshair(true)
		else
			-- close the inventory before opening the minimap
			if m_HudUtils:GetIsInventoryOpened() then
				m_HudUtils:SetIsInventoryOpened(false)
				WebUI:ExecuteJS("OnInventoryOpen(false);")
			end

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

	if SpectatorManager:GetSpectating() then
		return
	end

	-- Open / Close Inventory UI
	if p_Action == UIInputAction.UIInputAction_Tab then
		-- make sure the player is in no other menu
		if not m_HudUtils:GetIsInOptionsMenu()
			and not m_HudUtils:GetIsInEscMenu()
			and not m_HudUtils:GetIsInDeployScreen() then
			if m_HudUtils:GetIsInventoryOpened() then
				m_HudUtils:SetIsInventoryOpened(false)
				WebUI:ExecuteJS("OnInventoryOpen(false);")
				m_HudUtils:HUDEnterUIGraph()
				m_HudUtils:ShowCrosshair(true)
			else
				-- if the minimap is opened we close it
				if m_HudUtils:GetIsMapOpened() then
					m_HudUtils:SetIsMapOpened(false)
					WebUI:ExecuteJS("OnOpenCloseMap(false);")
				end

				if not self.m_IsPlayerOnPlane then
					m_HudUtils:SetIsInventoryOpened(true)
					WebUI:ExecuteJS("OnInventoryOpen(true);")
					m_HudUtils:OnEnableMouse()
				end
			end

			p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
			return
		end
	end
end

---VEXT Client UI:PushScreen Hook
---@param p_HookCtx HookContext
---@param p_Screen Asset
function VuBattleRoyaleHud:OnUIPushScreen(p_HookCtx, p_Screen)
	if p_Screen.name == "UI/Flow/Screen/SpawnScreenPC"
		or p_Screen.name == "UI/Flow/Screen/SpawnScreenTicketCounterConquestScreen"
		or p_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD32Screen"
		or p_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen"
		or p_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD64Screen"
		or p_Screen.name == "UI/Flow/Screen/KillScreen"
		or p_Screen.name == "UI/Flow/Screen/SpawnButtonScreen" then
		p_HookCtx:Return()
	end
end

-- =============================================
-- WebUI Events
-- =============================================

---Custom Client WebUI:Deploy WebUI Event
---@param p_AppearanceName string
function VuBattleRoyaleHud:OnWebUIDeploy(p_AppearanceName)
	m_DeployScreen:CloseDeployScreen()

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil and s_LocalPlayer.soldier ~= nil then
		m_HudUtils:ShowCrosshair(true)
	end

	if self.m_GameState == GameStates.WarmupToPlane and SpectatorManager:GetSpectating() then
		self.m_HudOnSetUIState:Update(UiStates.Loading)
	end

	NetEvents:Send(PlayerEvents.PlayerDeploy, p_AppearanceName)
end

-- TODO: switch to enum
---Custom Client WebUI:TriggerMenuFunction WebUI Event
---@param p_Function string
function VuBattleRoyaleHud:OnWebUITriggerMenuFunction(p_Function)
	m_EscMenu:OnWebUITriggerMenuFunction(p_Function)
end

-- =============================================
-- Functions
-- =============================================

---Update Placement every frame
function VuBattleRoyaleHud:OnUpdatePlacement()
	if m_BrPlayer.m_Team.m_Placement == nil then
		return
	end

	self.m_HudOnUpdatePlacement:Update(m_BrPlayer.m_Team.m_Placement)
end

---Update TeamData every frame
function VuBattleRoyaleHud:OnUpdateTeamData()
	if m_BrPlayer.m_Team == nil then
		return
	end

	self.m_HudOnUpdateTeamLocked:Update(m_BrPlayer.m_Team.m_Locked)
	self.m_HudOnUpdateTeamPlayers:Update(json.encode(m_BrPlayer.m_Team:PlayersTable()))
end

-- =============================================
-- Being Interacted Callbacks
-- =============================================

---If we revive a mate or get revived we need this for it to work
---@param p_Soldier SoldierEntity
function VuBattleRoyaleHud:RegisterSoldierInteractionCallbacks(p_Soldier)
	for i, l_Entity in pairs(p_Soldier.bus.entities) do
		if l_Entity.data ~= nil then
			if l_Entity.data.instanceGuid == Guid("34130787-22C3-0F9D-6AA7-4BC214FA1734") then
				l_Entity:RegisterEventCallback(self, self.OnSoldierInteractionStarted)
			elseif l_Entity.data.instanceGuid == Guid("D0F06E9A-AE8B-E614-F8C3-54A47CF22565") then
				l_Entity:RegisterEventCallback(self, self.OnSoldierInteractionFinished)
			end
		end
	end
end

---The soldier interaction started
---@param p_Entity Entity
---@param p_Event EntityEvent
function VuBattleRoyaleHud:OnSoldierInteractionStarted(p_Entity, p_Event)
	m_Logger:Write("The soldier interaction started")
	WebUI:ExecuteJS("OnInteractStart(5);")
end

---The soldier interaction finished
---@param p_Entity Entity
---@param p_Event EntityEvent
function VuBattleRoyaleHud:OnSoldierInteractionFinished(p_Entity, p_Event)
	m_Logger:Write("The soldier interaction finished")
	WebUI:ExecuteJS("OnInteractEnd();")
end

-- =============================================
-- Custom Level Finalized 'Event'
-- =============================================

---When we are done with loading we have to do this
function VuBattleRoyaleHud:OnLevelFinalized()
	if self.m_IsLevelLoaded then
		return
	end

	m_Logger:Write("OnLevelFinalized")
	self.m_IsLevelLoaded = true
	m_HudUtils:ExitSoundState()
	m_HudUtils:HUDEnterUIGraph()
	m_HudUtils:EnableTabScoreboard()
	m_HudUtils:EnableBlurEffect(false)
	m_HudUtils:StartupChat()
	WebUI:ExecuteJS("OnLevelFinalized('" .. SharedUtils:GetLevelName() .. "');")
	self:OnGameStateChanged(self.m_GameState)
	m_EscMenu:RegisterEscMenuCallbacks()
	m_HudUtils:OnEnableMouse()

	self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
		["msg"] = "Open team lobby",
		["key"] = "F10",
	}))
	self.m_HudOnSetUIState:Update(UiStates.Game)
end

-- =============================================
-- Custom OnSpatialRaycast "event" (called from CommonSpatialRaycast)
-- =============================================

---Gets called every UpdatePass_PreSim
---@param p_Entities SoldierEntity[]
function VuBattleRoyaleHud:OnSpatialRaycast(p_Entities)
	-- loop all entities
	for _, l_Entity in pairs(p_Entities) do
		-- filter out the SoldierEntities
		if l_Entity:Is("ClientSoldierEntity") then
			l_Entity = SoldierEntity(l_Entity)

			-- we found a teammate that we can revive
			if l_Entity.isInteractiveManDown and l_Entity.teamId == TeamId.Team1 then
				-- make sure this is not the local player
				if l_Entity.player ~= PlayerManager:GetLocalPlayer() then
					self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
						["msg"] = "Revive teammate",
						["key"] = "E",
					}))
					self.m_ShowInteractiveReviveMessage = true

					-- stop here
					return
				else
					-- fyi: p_Entities[1] is the soldier of the local player most of the time
					-- this is the local player and he is interactive mandown
					-- so he can't revive anyone else (even when he is close to a mate)
					-- thats why we break the for loop here
					break
				end
			end
		end
	end

	-- we found no teammate to revive
	if self.m_ShowInteractiveReviveMessage then
		self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
			["msg"] = nil,
			["key"] = nil,
		}))
		self.m_ShowInteractiveReviveMessage = false
	end
end

-- =============================================
-- Push HUD Information
-- =============================================

function VuBattleRoyaleHud:PushLocalPlayerPos()
	---@type Player|nil
	local s_Player = nil

	if SpectatorManager:GetSpectating() then
		s_Player = SpectatorManager:GetSpectatedPlayer()
	else
		s_Player = PlayerManager:GetLocalPlayer()
	end

	if s_Player == nil then
		return
	end

	---@type Vec3
	local s_Position = nil

	if s_Player.alive then
		local s_Soldier = s_Player.soldier

		if s_Soldier ~= nil then
			s_Position = s_Soldier.worldTransform.trans
		end
	else
		s_Position = ClientUtils:GetCameraTransform().trans
	end

	local s_Table = {
		x = s_Position.x,
		y = s_Position.y,
		z = s_Position.z
	}

	self.m_HudOnPlayerPos:Update(json.encode(s_Table))
end

function VuBattleRoyaleHud:PushLocalPlayerYaw()
	if SpectatorManager:GetSpectating() then
		local s_SpectatedPlayer = SpectatorManager:GetSpectatedPlayer()
		---@type Vec3
		local s_Forward = nil

		if s_SpectatedPlayer == nil or s_SpectatedPlayer.soldier == nil then
			s_Forward = ClientUtils:GetCameraTransform().forward * -1
		else
			s_Forward = s_SpectatedPlayer.soldier.worldTransform.forward
		end

		---@type number
		local s_YawRad = (math.atan(s_Forward.z, s_Forward.x) - (math.pi / 2)) % (2 * math.pi)
		self.m_HudOnPlayerYaw:Update(math.floor((180 / math.pi) * s_YawRad))
	else
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()

		if s_LocalPlayer == nil or (s_LocalPlayer.soldier == nil and s_LocalPlayer.corpse == nil) then
			return
		end

		local s_Camera = ClientUtils:GetCameraTransform()

		-- TODO: Put this in utils
		---@type number
		local s_YawRad = (math.atan(s_Camera.forward.z, s_Camera.forward.x) + (math.pi / 2)) % (2 * math.pi)
		self.m_HudOnPlayerYaw:Update(math.floor((180 / math.pi) * s_YawRad))
	end
end

function VuBattleRoyaleHud:PushUpdatePlayersInfo()
	---@type Player[]
	local s_Players = PlayerManager:GetPlayers()
	local s_PlayersObject = {}

	for _, l_Player in pairs(s_Players) do
		---@type BRPlayerState|integer
		local s_State = BRPlayerState.Dead

		if l_Player.alive then
			s_State = BRPlayerState.Alive
		end

		table.insert(s_PlayersObject, {
			["id"] = l_Player.id,
			["name"] = l_Player.name,
			["kill"] = 0,
			["state"] = s_State,
			["isTeamLeader"] = false,
		})
	end

	self.m_HudOnPlayersInfo:Update(json.encode(s_PlayersObject))

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	if s_LocalPlayer ~= nil then
		local s_LocalPlayerTable = {
			["id"] = s_LocalPlayer.id,
			["name"] = s_LocalPlayer.name,
			["kill"] = (m_BrPlayer.m_Kills or 0),
			["state"] = m_BrPlayer:GetState(),
			["isTeamLeader"] = m_BrPlayer.m_IsTeamLeader,
			["color"] = m_BrPlayer:GetColor(true),
		}
		self.m_HudOnLocalPlayerInfo:Update(json.encode(s_LocalPlayerTable))
	end
end

function VuBattleRoyaleHud:PushLocalPlayerAmmoArmorAndHealth()
	local s_Player = PlayerManager:GetLocalPlayer()

	if SpectatorManager:GetSpectating() then
		s_Player = SpectatorManager:GetSpectatedPlayer()
	end

	if s_Player == nil then
		return
	end

	if s_Player.alive == false then
		self.m_HudOnPlayerHealth:Update(0)
		return
	end

	local s_Soldier = s_Player.soldier

	if s_Soldier == nil then
		return
	end

	if s_Soldier.isInteractiveManDown then
		self.m_HudOnPlayerHealth:Update(s_Soldier.health)
	else
		self.m_HudOnPlayerHealth:Update(s_Soldier.health - 100)
	end

	self.m_HudOnPlayerArmor:Update(m_BrPlayer:GetArmorPercentage())
	self.m_HudOnPlayerHelmet:Update(m_BrPlayer:GetHelmetPercentage())

	if s_Soldier.weaponsComponent.currentWeapon then
		self.m_HudOnPlayerPrimaryAmmo:Update(s_Soldier.weaponsComponent.currentWeapon.primaryAmmo)
		self.m_HudOnPlayerSecondaryAmmo:Update(s_Soldier.weaponsComponent.currentWeapon.secondaryAmmo)
		self.m_HudOnPlayerFireLogic:Update(s_Soldier.weaponsComponent.currentWeapon.fireLogic)
		self.m_HudOnPlayerCurrentWeapon:Update(s_Soldier.weaponsComponent.currentWeapon.name)
	end
end

function VuBattleRoyaleHud:PushLocalPlayerTeam()
	self.m_HudOnUpdateTeamSize:Update(self.m_PlayersPerTeam)

	if m_BrPlayer.m_Team ~= nil then
		self.m_HudOnUpdateTeamId:Update(m_BrPlayer.m_Team.m_Id)
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

function VuBattleRoyaleHud:PushManDownMapMarkers()
	for l_PlayerName, l_EntityInstanceId in pairs(self.m_ManDownMapMarkers) do
		local s_Player = PlayerManager:GetPlayerByName(l_PlayerName)

		if s_Player ~= nil and s_Player.soldier ~= nil and s_Player.soldier.isInteractiveManDown then
			local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
			---@type SpatialEntity|nil
			local s_Entity = s_EntityIterator:Next()

			while s_Entity do
				s_Entity = SpatialEntity(s_Entity)

				if s_Entity.instanceId == l_EntityInstanceId then
					s_Entity.transform = s_Player.soldier.transform
					break
				end

				s_Entity = s_EntityIterator:Next()
			end
		else
			local s_EntityIterator = EntityManager:GetIterator('ClientMapMarkerEntity')
			---@type SpatialEntity|nil
			local s_Entity = s_EntityIterator:Next()

			while s_Entity do
				s_Entity = SpatialEntity(s_Entity)

				if s_Entity.instanceId == l_EntityInstanceId then
					s_Entity.transform = LinearTransform(Vec3(), Vec3(), Vec3(), Vec3(-9999.0, -9999.0, -9999.0))
					self.m_ManDownMapMarkers[l_PlayerName] = nil
					break
				end

				s_Entity = s_EntityIterator:Next()
			end
		end
	end
end

function VuBattleRoyaleHud:OpenInventory()
	-- make sure the player is in no other menu
	if not m_HudUtils:GetIsInOptionsMenu()
		and not m_HudUtils:GetIsInEscMenu()
		and not m_HudUtils:GetIsInDeployScreen() then
		m_Logger:Write("Open Inventory")

		-- if the minimap is opened we close it
		if m_HudUtils:GetIsMapOpened() then
			m_HudUtils:SetIsMapOpened(false)
			WebUI:ExecuteJS("OnOpenCloseMap(false);")
		end

		if not self.m_IsPlayerOnPlane then
			m_HudUtils:SetIsInventoryOpened(true)
			WebUI:ExecuteJS("OnInventoryOpen(true);")
			m_HudUtils:OnEnableMouse()
		end
	end
end

-- =============================================
-- Create / Remove Marker
-- =============================================

---comment
---@param p_PlayerName string
---@param p_PositionX number
---@param p_PositionY number
---@param p_PositionZ number
---@param p_Color string @rgba css format
---@param p_PingType PingType|integer
function VuBattleRoyaleHud:CreateMarker(p_PlayerName, p_PositionX, p_PositionY, p_PositionZ, p_Color, p_PingType)
	--[[local s_WorldToScreen = ClientUtils:WorldToScreen(Vec3(p_PositionX, p_PositionY, p_PositionZ))
	if s_WorldToScreen == nil then
		return
	end]]

	local s_Marker = {
		Key = p_PlayerName,
		PositionX = p_PositionX,
		PositionY = p_PositionY,
		PositionZ = p_PositionZ,
		Color = p_Color,
		WorldToScreenX = 0,
		WorldToScreenY = 0,
		Type = p_PingType,
	}

	self.m_Markers[p_PlayerName] = s_Marker
	WebUI:ExecuteJS(
		string.format(
			'OnCreateMarker("%s", "%s", %s, %s, %s, %s, %s)',
			s_Marker.Key,
			s_Marker.Color,
			s_Marker.PositionX,
			s_Marker.PositionZ,
			s_Marker.WorldToScreenX,
			s_Marker.WorldToScreenY,
			s_Marker.Type
		)
	)
end

---@param p_PlayerName string
function VuBattleRoyaleHud:RemoveMarker(p_PlayerName)
	if self.m_Markers[p_PlayerName] == nil then
		return
	end

	self.m_Markers[p_PlayerName] = nil
	WebUI:ExecuteJS(string.format('OnRemoveMarker("%s")', p_PlayerName))
end

function VuBattleRoyaleHud:ShowCommoRose()
	WebUI:ExecuteJS("OnShowCommoRose()")
end

function VuBattleRoyaleHud:HideCommoRose()
	WebUI:ExecuteJS("OnHideCommoRose()")
end

function VuBattleRoyaleHud:OnAirdropDropped()
	WebUI:ExecuteJS("OnAirdropDropped()")
end

return VuBattleRoyaleHud()
