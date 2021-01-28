class "VuBattleRoyaleHud"

require ("CachedJsExecutor")

function VuBattleRoyaleHud:__init()
    self.m_HudOnPlayerYaw = CachedJsExecutor('OnPlayerYaw(%s)', 0)
    self.m_HudOnPlayerPos = CachedJsExecutor('OnPlayerPos(%s)', nil)
    self.m_HudOnUpdateCircles = CachedJsExecutor('OnUpdateCircles(%s)', nil)
end

function VuBattleRoyaleHud:OnExtensionLoaded()
    WebUI:Init()
    WebUI:Show()
end

function VuBattleRoyaleHud:OnEngineUpdate(p_DeltaTime) 

end

function VuBattleRoyaleHud:OnUIDrawHud() 
    self:PushLocalPlayerPos()
    self:PushLocalPlayerYaw()
end

function VuBattleRoyaleHud:PushLocalPlayerPos()
    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil then return end

    if s_LocalPlayer.alive == false then return end
    local s_LocalSoldier = s_LocalPlayer.soldier
    if s_LocalSoldier == nil then return end

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

function VuBattleRoyaleHud:OnInputConceptEvent(p_Hook, p_EventType, p_Action)
    if p_Action == UIInputAction.UIInputAction_MapSize and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
        WebUI:ExecuteJS("OnMapSizeChange()")
		p_Hook:Pass(UIInputAction.UIInputAction_None, p_EventType)
		return
    end
    
    if p_Action == UIInputAction.UIInputAction_MapZoom and p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
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
end

if g_VuBattleRoyaleHud == nil then
    g_VuBattleRoyaleHud = VuBattleRoyaleHud()
end

return g_VuBattleRoyaleHud
