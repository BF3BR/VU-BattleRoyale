class "VuBattleRoyaleHud"

require "__shared/Utils/CachedJsExecutor"
require "__shared/Utils/Timers"
require "__shared/Enums/GameStates"
require "__shared/Enums/UiStates"

local m_Showroom = require "Showroom"

function VuBattleRoyaleHud:__init()
    self.m_GameState = GameStates.None
    self.m_Ticks = 0.0
    self.m_BrPlayer = nil
    self.m_IsPlayerOnPlane = false

    self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart

    self.m_Markers = {}

    self:RegisterVars()
end

function VuBattleRoyaleHud:RegisterVars()
    self.m_HudOnPlayerPos = CachedJsExecutor("OnPlayerPos(%s)", nil)
    self.m_HudOnPlayerYaw = CachedJsExecutor("OnPlayerYaw(%s)", 0)
    self.m_HudOnPlayerIsInPlane = CachedJsExecutor("OnPlayerIsInPlane(%s)", false)
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

function VuBattleRoyaleHud:OnExtensionLoaded()
    WebUI:Init()
    WebUI:Show()
end

function VuBattleRoyaleHud:OnLevelFinalized(p_LevelName, p_GameMode)
    self.m_HudOnSetUIState:Update(UiStates.Game)
    WebUI:ExecuteJS("OnLevelFinalized('" .. p_LevelName .. "');")
end

function VuBattleRoyaleHud:OnLevelDestroy()
    self.m_HudOnSetUIState:Update(UiStates.Loading)
end

function VuBattleRoyaleHud:OnClientUpdateInput()
    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then
        return
    end

    if s_LocalPlayer.soldier == nil then
        return
    end

    if InputManager:WentKeyDown(InputDeviceKeys.IDK_F10) then
        if (self.m_GameState ~= GameStates.Match and self.m_GameState ~= GameStates.Plane and self.m_GameState ~= GameStates.PlaneToFirstCircle)
         or not s_LocalPlayer.soldier.alive then
            WebUI:ExecuteJS("ToggleDeployMenu(true);")
            m_Showroom:SetCamera(true)
        end
    end
end

function VuBattleRoyaleHud:OnEngineUpdate(p_DeltaTime)
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

function VuBattleRoyaleHud:OnGameStateChanged(p_GameState)
    if p_GameState == nil then
        return
    end

    self.m_GameState = p_GameState

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

        WebUI:ExecuteJS("ToggleDeployMenu(false);")

        self.m_HudOnSetUIState:Update(UiStates.Loading)
    elseif self.m_GameState == GameStates.Plane then
        self.m_HudOnSetUIState:Update(UiStates.Game)
    end

    self.m_HudOnGameState:Update(GameStatesStrings[p_GameState])
end

function VuBattleRoyaleHud:OnUIDrawHud(p_BrPlayer)
    if self.m_BrPlayer == nil then
        if p_BrPlayer == nil then
            return
        end

        self.m_BrPlayer = p_BrPlayer
    end

    self:PushLocalPlayerPos()
    self:PushLocalPlayerYaw()
    self:PushLocalPlayerAmmoArmorAndHealth()
    self:OnUpdatePlacement()
end

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

function VuBattleRoyaleHud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    if p_Action == UIInputAction.UIInputAction_MapSize and p_EventType ==
        UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapSizeChange();")
        p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
        return
    end

    if p_Action == UIInputAction.UIInputAction_MapZoom and p_EventType ==
        UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapZoomChange();")
        p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
        return
    end

    if p_Action == UIInputAction.UIInputAction_Tab and p_EventType ==
        UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapEnableMouse();")
        p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
        return
    end
end

function VuBattleRoyaleHud:OnPlayerRespawn(p_Player)
    WebUI:ExecuteJS("OnMapShow(true)")
    self:PushLocalPlayerPos()
    self:PushLocalPlayerYaw()
end

function VuBattleRoyaleHud:OnPhaseManagerUpdate(p_Data)
    self.m_HudOnUpdateCircles:Update(json.encode(p_Data))
end

function VuBattleRoyaleHud:OnOuterCircleMove(p_OuterCircle)
    self.m_HudOnUpdateCircles:Update(json.encode({OuterCircle = p_OuterCircle}))
end

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

function VuBattleRoyaleHud:PushLocalPlayerAmmoArmorAndHealth()
    if self.m_BrPlayer == nil then
        return
    end

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
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

function VuBattleRoyaleHud:OnTeamJoinDenied(p_Error)
    if p_Error == nil then
        return
    end

    self.m_HudOnTeamJoinError:ForceUpdate(p_Error)
end

function VuBattleRoyaleHud:OnGunShipCamera()
    self.m_HudOnPlayerIsInPlane:Update(true)
    self.m_IsPlayerOnPlane = true
end

function VuBattleRoyaleHud:OnJumpOutOfGunship()
    self.m_HudOnPlayerIsInPlane:Update(false)
    self.m_IsPlayerOnPlane = false
end

function VuBattleRoyaleHud:OnGunshipPosition(p_Trans)
    if p_Trans == nil  then
        self.m_HudOnPlanePos:Update(nil)
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
    end

    local s_YawRad = (math.atan(p_Trans.forward.z, p_Trans.forward.x) - (math.pi / 2)) % (2 * math.pi)
    local s_Floored = math.floor((180 / math.pi) * s_YawRad)

    if self.m_IsPlayerOnPlane then
        self.m_HudOnPlayerYaw:Update(s_Floored)
    end

    self.m_HudOnPlaneYaw:Update(s_Floored)
end

function VuBattleRoyaleHud:OnGunshipRemove(p_Trans)
    self.m_HudOnPlanePos:Update(nil)
    self.m_HudOnPlaneYaw:Update(nil)
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

function VuBattleRoyaleHud:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    local s_Screen = UIGraphAsset(p_Screen)
    if s_Screen.name == "UI/Flow/Screen/IngameMenuMP" then
        self.m_HudOnSetUIState:Update(UiStates.Hidden)
    elseif s_Screen.name == "UI/Flow/Screen/HudScreen" then
        self.m_HudOnSetUIState:Update(UiStates.Game)
    end
end

function VuBattleRoyaleHud:CreateMarker(p_Key, p_PositionX, p_PositionZ, p_Color)
    local s_Marker = {
        Key = p_Key,
        PositionX = p_PositionX,
        PositionZ = p_PositionZ,
        Color = p_Color
    }
    self.m_Markers[p_Key] = s_Marker
    WebUI:ExecuteJS(string.format('OnCreateMarker("%s", "%s", %s, %s)', s_Marker.Key, s_Marker.Color, s_Marker.PositionX, s_Marker.PositionZ))
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
