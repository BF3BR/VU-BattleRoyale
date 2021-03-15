class "VuBattleRoyaleHud"

require "__shared/Utils/CachedJsExecutor"
require "__shared/Configs/ServerConfig"
require "__shared/Utils/Timers"
require "__shared/Enums/GameStates"

local m_Showroom = require "Showroom"

function VuBattleRoyaleHud:__init()
    self.m_GameState = GameStates.None
    self.m_Ticks = 0.0
    self.m_BrPlayer = nil
    self.m_HudLoaded = false
    self.m_IsPlayerOnPlane = false
    self.m_StateTimer = nil

    self.m_MinPlayersToStart = ServerConfig.MinPlayersToStart

    self:RegisterVars()
end

function VuBattleRoyaleHud:RegisterVars()
    self.m_HudOnPlayerYaw = CachedJsExecutor("OnPlayerYaw(%s)", 0)
    self.m_HudOnPlayerPos = CachedJsExecutor("OnPlayerPos(%s)", nil)
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
    self.m_HudOnPlayerIsInPlane = CachedJsExecutor("OnPlayerIsInPlane(%s)", false)
    self.m_HudOnPlanePosition = CachedJsExecutor("OnPlanePosition(%s)", nil)
    self.m_HudOnNotifyInflictorAboutKillOrKnock = CachedJsExecutor("OnNotifyInflictorAboutKillOrKnock(%s)", nil)
    self.m_HudOnInteractiveMessageAndKey = CachedJsExecutor("OnInteractiveMessageAndKey(%s)", nil)
    self.m_HudOnGameOverScreen = CachedJsExecutor("OnGameOverScreen(%s)", nil)
    self.m_HudOnUpdatePlacement = CachedJsExecutor("OnUpdatePlacement(%s)", 99)
end

function VuBattleRoyaleHud:OnExtensionLoaded()
    WebUI:Init()
end

function VuBattleRoyaleHud:OnLevelFinalized(p_LevelName, p_GameMode)
    self.m_HudLoaded = true
    WebUI:Show()
end

function VuBattleRoyaleHud:OnLevelDestroy()
    WebUI:ExecuteJS("ResetVars();")
    WebUI:Hide()
end

function VuBattleRoyaleHud:OnClientUpdateInput()
    if not self.m_HudLoaded then
        return
    end

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
    if not self.m_HudLoaded then
        WebUI:Hide()
        return
    end
    
    if self.m_Ticks >= ServerConfig.HudUpdateRate then
        self.m_HudOnMinPlayersToStart:ForceUpdate(self.m_MinPlayersToStart)
        self:PushUpdatePlayersInfo()

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
    end

    if self.m_GameState == GameStates.WarmupToPlane then
        self.m_HudOnInteractiveMessageAndKey:ForceUpdate(json.encode({
            ["msg"] = nil,
            ["key"] = nil,
        }))

        WebUI:ExecuteJS("ToggleDeployMenu(false);")
    end

    self.m_HudOnGameState:Update(GameStatesStrings[p_GameState])
end

function VuBattleRoyaleHud:OnUIDrawHud(p_BrPlayer)
    if not self.m_HudLoaded then
        return
    end

    if self.m_BrPlayer == nil then
        if p_BrPlayer == nil then
            return
        end

        self.m_BrPlayer = p_BrPlayer
    end

    self:PushLocalPlayerPos()
    self:PushLocalPlayerYaw()
    self:PushLocalPlayerAmmoArmorAndHealth()
    self:PushLocalPlayerTeam()
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
		table.insert(s_PlayersObject, {
            ["id"] = l_Player.id,
            ["name"] = l_Player.name,
            ["kill"] = 0, -- TODO: Add BrPlayer (not local) kills
            ["alive"] = l_Player.alive,
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
            ["alive"] = s_LocalPlayer.alive,
            ["isTeamLeader"] = self.m_BrPlayer.m_IsTeamLeader,
        }
        self.m_HudOnLocalPlayerInfo:Update(json.encode(s_LocalPlayerTable))
    end
end

function VuBattleRoyaleHud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    if p_Action == UIInputAction.UIInputAction_MapSize and p_EventType ==
        UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapSizeChange()")
        p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
        return
    end

    if p_Action == UIInputAction.UIInputAction_MapZoom and p_EventType ==
        UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapSizeChange()")
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
    -- self:OnUpdateTimer(p_Data.Duration)
end

function VuBattleRoyaleHud:OnOuterCircleMove(p_OuterCircle)
    self.m_HudOnUpdateCircles:Update(json.encode({OuterCircle = p_OuterCircle}))
end

function VuBattleRoyaleHud:OnUpdateTimer(p_Time)
    --[[if self.m_StateTimer ~= nil then
        self.m_StateTimer:Destroy()
    end

    self.m_StateTimer = g_Timers:Timeout(p_Time)]]
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
        self.m_HudOnPlayerHealth:Update(s_LocalSoldier.health) -- - 100)
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

    self.m_HudOnUpdateTeamSize:Update(ServerConfig.PlayersPerTeam);

    if self.m_BrPlayer.m_Team ~= nil then
        self.m_HudOnUpdateTeamId:Update(self.m_BrPlayer.m_Team.m_Id);
        self.m_HudOnUpdateTeamLocked:Update(self.m_BrPlayer.m_Team.m_Locked);
        self.m_HudOnUpdateTeamPlayers:Update(json.encode(self.m_BrPlayer.m_Team:PlayersTable()))
    end
end

function VuBattleRoyaleHud:OnTeamJoinDenied(p_Error)
    if p_Error == nil then
        return
    end

    self.m_HudOnTeamJoinError:ForceUpdate(p_Error);
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
    if p_Trans == nil or not self.m_IsPlayerOnPlane then
        return
    end

    local s_Table = {
        x = p_Trans.trans.x,
        y = p_Trans.trans.y,
        z = p_Trans.trans.z
    }

    self.m_HudOnPlayerPos:Update(json.encode(s_Table))
end

function VuBattleRoyaleHud:OnGunshipYaw(p_Trans)
    if p_Trans == nil or not self.m_IsPlayerOnPlane then
        return
    end

    local s_YawRad = (math.atan(p_Trans.forward.z, p_Trans.forward.x) - (math.pi / 2)) % (2 * math.pi)
    self.m_HudOnPlayerYaw:Update(math.floor((180 / math.pi) * s_YawRad))
end

function VuBattleRoyaleHud:OnGameOverScreen(p_IsWin)
    self.m_HudOnGameOverScreen:ForceUpdate(json.encode({
        ["isWin"] = p_IsWin,
    }))
end

function VuBattleRoyaleHud:OnUpdatePlacement()
    print(self.m_BrPlayer.m_Team.m_Placement)
    self.m_HudOnUpdatePlacement:Update(self.m_BrPlayer.m_Team.m_Placement)
end

if g_VuBattleRoyaleHud == nil then
    g_VuBattleRoyaleHud = VuBattleRoyaleHud()
end

return g_VuBattleRoyaleHud
