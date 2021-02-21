class "PingClient"

require "__shared/Enums/PingEvents"
require "__shared/Utils/EventRouter"

function PingClient:__init()
    self.m_LastPing = Vec3(0, 0, 0)
    self.m_Color = Vec3(0, 0, 0)

    -- Pings for squadmates
    -- This is pingId, { position, cooldownTime }
    self.m_SquadPings = { }

    self.m_Opacity = 0.4

    self.m_PingColors = {
        Vec4(1, 0, 0, self.m_Opacity),
        Vec4(0, 1, 0, self.m_Opacity),
        Vec4(0, 0, 1, self.m_Opacity),
        Vec4(0.5, 0.5, 0.5, self.m_Opacity),
    }

    -- Events
    self.m_PingNotifyEvent = NetEvents:Subscribe(PingEvents.ServerPing, self, self.OnPingNotify)
    self.m_PingUpdateConfigEvent = NetEvents:Subscribe(PingEvents.UpdateConfig, self, self.OnPingUpdateConfig)
    self.m_UiDrawHudEvent = Events:Subscribe(EventRouterEvents.UIDrawHudCustom, self, self.OnUiDrawHud)
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)
    self.m_UpdateManagerUpdateEvent = Events:Subscribe("UpdateManager:Update", self, self.OnUpdateManagerUpdate)
    self.m_LevelLoadedEvent = Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)

    -- This is set by the server
    self.m_CooldownTime = 0.0

    self.m_DebugSize = 0.25

    self.m_RaycastLength = 2000.0
    -- Should we send a ping (used for sync across UpdateState's)
    self.m_ShouldPing = false

    -- Enable debug logging
    self.m_Debug = true

    -- Check if debug mode is enabled
    self.m_PingCommand = nil
    if self.m_Debug then
        self.m_PingCommand = Console:Register("ping", "ping", self, self.OnPing)
    end
end

function PingClient:__gc()
    -- Unsubscribe from events
    self.m_PingNotifyEvent:Unsubscribe()
    self.m_PingUpdateConfigEvent:Unsubscribe()
    self.m_UiDrawHudEvent:Unsubscribe()
    self.m_EngineUpdateEvent:Unsubscribe()
    self.m_UpdateManagerUpdateEvent:Unsubscribe()

    if self.m_Debug then
        -- Remove the console commands
        Console:Deregister(self.m_PingCommand)

        self.m_PingCommand = nil
    end
end

function PingClient:OnPing(p_Args)
    -- This should only be enabled if debug mode is enabled
    if not self.m_Debug then
        return
    end

    -- This should not happen, but we validate anyway for stability
    if self.m_PingCommand == nil then
        print("invalid ping command")
        return
    end

    self.m_ShouldPing = true
end

function PingClient:OnPingNotify(p_PingId, p_Position)
    if self.m_Debug then
        print("pingId: " .. p_PingId .. " position: " .. p_Position.x .. ", " .. p_Position.y .. ", " .. p_Position.z)
    end

    local s_PingInfo = self.m_SquadPings[p_PingId]
    if s_PingInfo == nil then
        -- No information currently exists
        self.m_SquadPings[p_PingId] = { p_Position, self.m_CooldownTime }
        return
    end

    -- Update the structure
    self.m_SquadPings[p_PingId] = { p_Position, s_PingInfo[2] + self.m_CooldownTime }
end

function PingClient:OnPingUpdateConfig(p_CooldownTime)
    if self.m_Debug then
        print("cooldownTime: " .. p_CooldownTime)
    end

    self.m_CooldownTime = p_CooldownTime
end

function PingClient:OnUiDrawHud()
    for l_PingId, l_PingInfo in pairs(self.m_SquadPings) do
        if l_PingInfo == nil then
            print("invalid ping info")
            goto __on_ui_draw_hud_cont__
        end

        local l_Position = l_PingInfo[1]
        local l_Cooldown = l_PingInfo[2]

        --print(l_Position)
        --print(l_Cooldown)

        if l_Cooldown < 0.001 then
            --print("invalid cooldown")
            goto __on_ui_draw_hud_cont__
        end

        local l_Color = self:GetColorByPingId(l_PingId)

        if self.m_Debug then
            DebugRenderer:DrawSphere(l_Position, self.m_DebugSize, l_Color, false, false)
            
            local l_Coordinates = ClientUtils:WorldToScreen(l_Position)
            if l_Coordinates == nil then
                goto __on_ui_draw_hud_cont__
            end

            DebugRenderer:DrawText2D(l_Coordinates.x, l_Coordinates.y, tostring(l_PingId), Vec4(1, 0, 0, 1), 1.1)

        end
        ::__on_ui_draw_hud_cont__::
    end
end

function PingClient:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    -- Update all of the cooldowns
    for l_PingId, l_Info in pairs(self.m_SquadPings) do
        if l_Info == nil then
            goto __on_engine_update_cont__
        end

        local l_Result = l_Info[2] - p_DeltaTime
        if l_Result < 0.001 then
            l_Result = 0.0
        end

        l_Info[2] = l_Result

        ::__on_engine_update_cont__::
    end
end

function PingClient:OnUpdateManagerUpdate(p_DeltaTime, p_Pass)
    -- Only do raycasts on presim
    if p_Pass ~= UpdatePass.UpdatePass_PreSim then
        return
    end

    -- If we do not need to ping dont worry about anything
    if not self.m_ShouldPing then
        return
    end

    print("raycasting...")

    local s_Transform = ClientUtils:GetCameraTransform()
    if s_Transform == nil then
        print("invalid transform")
        return
    end

    local s_Direction = Vec3(-s_Transform.forward.x, -s_Transform.forward.y, -s_Transform.forward.z)
    
    local s_RayStart = s_Transform.trans
    local s_RayEnd = Vec3(
        s_Transform.trans.x + (s_Direction.x * self.m_RaycastLength),
        s_Transform.trans.y + (s_Direction.y * self.m_RaycastLength),
        s_Transform.trans.z + (s_Direction.z * self.m_RaycastLength)
    )

    local s_RaycastHit = RaycastManager:Raycast(s_RayStart, s_RayEnd, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckRagdoll | RayCastFlags.CheckDetailMesh)
    if s_RaycastHit == nil then
        print("no raycast")
        return
    end

    -- Send the server a client notification that we want to ping at this location
    NetEvents:Send(PingEvents.ClientPing, s_RaycastHit.position)

    self.m_ShouldPing = false
end

function PingClient:OnLevelLoaded(p_LevelName, p_GameMode)
    self.m_SquadPings = { }
    self.m_ShouldPing = false
end

function PingClient:GetColorByPingId(p_PingId)
    -- Validate ping id
    if p_PingId == -1 then
        return
    end

    local s_Color = self.m_PingColors[math.fmod(p_PingId, #self.m_PingColors)]
    if s_Color == nil then
        return Vec3(0, 0, 0)
    end

    return s_Color
end

return PingClient
