class "VuBattleRoyaleHud"

require "__shared/Configs/ServerConfig"
require "__shared/Enums/GameStates"
require "CachedJsExecutor"

function VuBattleRoyaleHud:__init()
    self.m_HudOnPlayerYaw = CachedJsExecutor("OnPlayerYaw(%s)", 0)
    self.m_HudOnPlayerPos = CachedJsExecutor("OnPlayerPos(%s)", nil)
    self.m_HudOnUpdateCircles = CachedJsExecutor("OnUpdateCircles(%s)", nil)

    self.m_HudOnGameState = CachedJsExecutor("OnGameState('%s')", GameStates.None)
    self.m_GameState = GameStates.None

    self.m_HudOnPlayersInfo = CachedJsExecutor("OnPlayersInfo(%s)", nil)
    self.m_HudOnLocalPlayerInfo = CachedJsExecutor("OnLocalPlayerInfo(%s)", nil)

    self.m_HudOnUpdateTimer = CachedJsExecutor("OnUpdateTimer(%s)", nil)

    self.m_HudOnMinPlayersToStart = CachedJsExecutor("OnMinPlayersToStart(%s)", nil)

    self.m_HudOnPlayerHealth = CachedJsExecutor("OnPlayerHealth(%s)", 0)
    self.m_HudOnPlayerPrimaryAmmo = CachedJsExecutor("OnPlayerPrimaryAmmo(%s)", 0)
    self.m_HudOnPlayerSecondaryAmmo = CachedJsExecutor("OnPlayerSecondaryAmmo(%s)", 0)
    self.m_HudOnPlayerCurrentWeapon = CachedJsExecutor("OnPlayerCurrentWeapon('%s')", '')

    self.m_Ticks = 0.0
end

function VuBattleRoyaleHud:OnExtensionLoaded()
    WebUI:Init()
    WebUI:Hide()
end

function VuBattleRoyaleHud:OnLevelFinalized(p_LevelName, p_GameMode)
    WebUI:Show()
end

function VuBattleRoyaleHud:OnLevelDestroy()
    WebUI:Hide()
end


function VuBattleRoyaleHud:OnEngineUpdate(p_DeltaTime)
    if self.m_Ticks >= ServerConfig.HudUpdateTime then
        self.m_HudOnMinPlayersToStart:Update(ServerConfig.MinPlayersToStart)
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

    self.m_HudOnGameState:Update(GameStatesStrings[p_GameState])
end

function VuBattleRoyaleHud:OnUIDrawHud()
    self:PushLocalPlayerPos()
    self:PushLocalPlayerYaw()
    self:PushLocalPlayerAmmoAndHealth()
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
            ["kill"] = l_Player.kills,
            ["alive"] = l_Player.alive,
        })
    end
    self.m_HudOnPlayersInfo:Update(json.encode(s_PlayersObject))

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer ~= nil then
        local s_LocalPlayerTable = {
            ["id"] = s_LocalPlayer.id,
            ["name"] = s_LocalPlayer.name,
            ["kill"] = s_LocalPlayer.kills,
            ["alive"] = s_LocalPlayer.alive,
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
    self:OnUpdateTimer(p_Data.Duration)
end

function VuBattleRoyaleHud:OnOuterCircleMove(p_OuterCircle)
    self.m_HudOnUpdateCircles:Update(json.encode({OuterCircle = p_OuterCircle}))
end

function VuBattleRoyaleHud:OnUpdateTimer(p_Time)
    self.m_HudOnUpdateTimer:ForceUpdate(p_Time)
end

function VuBattleRoyaleHud:PushLocalPlayerAmmoAndHealth()
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

    print(s_LocalSoldier.health)

    self.m_HudOnPlayerHealth:Update(s_LocalSoldier.health)
    self.m_HudOnPlayerPrimaryAmmo:Update(s_LocalSoldier.weaponsComponent.currentWeapon.primaryAmmo)
    self.m_HudOnPlayerSecondaryAmmo:Update(s_LocalSoldier.weaponsComponent.currentWeapon.secondaryAmmo)
    self.m_HudOnPlayerCurrentWeapon:Update(s_LocalSoldier.weaponsComponent.currentWeapon.name)
    --self.m_HudOnPlayerCurrentSlot:Update(s_LocalSoldier.weaponsComponent.currentWeaponSlot)
    return
end

if g_VuBattleRoyaleHud == nil then
    g_VuBattleRoyaleHud = VuBattleRoyaleHud()
end

return g_VuBattleRoyaleHud
