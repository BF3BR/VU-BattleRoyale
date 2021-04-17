class "PingClient"

require "__shared/Enums/CustomEvents"
require "__shared/Enums/PingTypes"
require "__shared/Utils/EventRouter"

local m_Hud = require "Hud"
local m_Logger = Logger("PingClient", true)

function PingClient:__init()
    self.m_LastPing = Vec3(0, 0, 0)
    self.m_Color = Vec3(0, 0, 0)

    -- Pings for squadmates
    -- This is pingId, { position, cooldownTime }
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

    -- Enable debug logging
    self.m_Debug = true
end

function PingClient:OnClientUpdateInput()
    if InputManager:WentKeyDown(InputDeviceKeys.IDK_Q) then
        self.m_ShouldPing = true
        self.m_PingMethod = PingMethod.World
    end
end

function PingClient:OnWebUIPingFromMap(p_Coordinates)
    if p_Coordinates == nil then
        m_Logger:Error("No Coordinates received")
        return
    end
    local s_Coordinates = json.decode(p_Coordinates)
    m_Logger:Write(s_Coordinates)
    self.m_Position_X = s_Coordinates.x
    self.m_Position_Z = s_Coordinates.y
    self.m_ShouldPing = true
    self.m_PingMethod = PingMethod.Screen
end

function PingClient:OnWebUIPingRemoveFromMap()
    NetEvents:SendLocal(PingEvents.RemoveClientPing)
end

function PingClient:OnPingNotify(p_PingId, p_Position)
    m_Logger:Write("pingId: " .. p_PingId .. " position: " .. p_Position.x .. ", " .. p_Position.y .. ", " .. p_Position.z)

    -- Send ping to compass
    local l_PingIdStr = tostring(math.floor(p_PingId))
    local l_Position2d = Vec2(p_Position.x, p_Position.z)
    local l_RgbaColor = self:GetRgbaColorByPingId(p_PingId)
    Events:Dispatch("Compass:CreateMarker", l_PingIdStr, l_Position2d, l_RgbaColor)
    m_Hud:CreateMarker(l_PingIdStr, p_Position.x, p_Position.y, p_Position.z, l_RgbaColor)

    local s_PingInfo = self.m_SquadPings[p_PingId]
    if s_PingInfo == nil then
        -- No information currently exists
        self.m_SquadPings[p_PingId] = {p_Position, self.m_CooldownTime}
        return
    end

    -- Update the structure
    local l_UpdatedCooldown = s_PingInfo[2] + self.m_CooldownTime
    if l_UpdatedCooldown > 3 * self.m_CooldownTime then
        l_UpdatedCooldown = 3 * self.m_CooldownTime
    end
    self.m_SquadPings[p_PingId] = {p_Position, l_UpdatedCooldown}
end

function PingClient:OnPingRemoveNotify(p_PingId)
    m_Logger:Write("removing ping with Id: " .. p_PingId)
    
    Events:Dispatch("Compass:RemoveMarker", tostring(math.floor(p_PingId)))
    m_Hud:RemoveMarker(tostring(math.floor(p_PingId)))
    self.m_SquadPings[p_PingId] = nil
end

function PingClient:OnPingUpdateConfig(p_CooldownTime)
    m_Logger:Write("cooldownTime: " .. p_CooldownTime)

    self.m_CooldownTime = p_CooldownTime
end

function PingClient:OnUIDrawHud()
    for l_PingId, l_PingInfo in pairs(self.m_SquadPings) do
        if l_PingInfo == nil then
            m_Logger:Write("invalid ping info")
            goto __on_ui_draw_hud_cont__
        end

        local l_Position = l_PingInfo[1]
        local l_Cooldown = l_PingInfo[2]

        if l_Cooldown < 0.001 then
            m_Logger:Write("invalid cooldown")
            Events:Dispatch("Compass:RemoveMarker", tostring(math.floor(l_PingId)))
            m_Hud:RemoveMarker(tostring(math.floor(l_PingId)))
            self.m_SquadPings[l_PingId] = nil
            goto __on_ui_draw_hud_cont__
        end

        local l_Color = self:GetColorByPingId(l_PingId)
        
        if l_Color == nil then
            m_Logger:Write("invalid color for ping ID: " .. l_PingId)
            Events:Dispatch("Compass:RemoveMarker", tostring(math.floor(l_PingId)))
            m_Hud:RemoveMarker(tostring(math.floor(l_PingId)))
            self.m_SquadPings[l_PingId] = nil
            goto __on_ui_draw_hud_cont__
        end
        
        if self.m_Debug then
            DebugRenderer:DrawSphere(l_Position, self.m_DebugSize, l_Color, false, false)

            local l_Coordinates = ClientUtils:WorldToScreen(l_Position)
            if l_Coordinates ~= nil then
                DebugRenderer:DrawText2D(l_Coordinates.x, l_Coordinates.y, tostring(l_PingId), Vec4(1, 0, 0, 1), 1.1)
            end
        end
        ::__on_ui_draw_hud_cont__::
    end
end

function PingClient:OnEngineUpdate(p_DeltaTime)
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

    if s_RaycastHit == nil then
        m_Logger:Write("no raycast")
        return
    end

    -- Send the server a client notification that we want to ping at this location
    NetEvents:Send(PingEvents.ClientPing, s_RaycastHit.position)
end

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

function PingClient:OnLevelLoaded(p_LevelName, p_GameMode)
    self.m_SquadPings = {}
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

function PingClient:GetRgbaColorByPingId(p_PingId)
    -- Validate ping id
    if p_PingId == -1 then
        return
    end

    -- Get original color
    local s_Color = self:GetColorByPingId(p_PingId)

    -- Convert to rgba string
    return string.format("rgba(%s, %s, %s, %s)", s_Color.x * 255, s_Color.y * 255, s_Color.z * 255, s_Color.w)
end

if g_PingClient == nil then
    g_PingClient = PingClient()
end

return g_PingClient
