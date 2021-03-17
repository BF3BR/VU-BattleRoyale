class "Gunship"

require "__shared/Enums/CustomEvents"

local m_Logger = Logger("Gunship", true)

function Gunship:__init()
    self.m_IsInGunship = false
    self.m_IsInFreeFall = false
    self.m_CumulatedTime = 0
end

function Gunship:RegisterCallbacks()
    -- CameraEntityUs
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("694A231C-4439-461D-A7FF-764915FC3E7C"), 
        Guid("6B728CD3-EBD2-4D48-BF49-50A7CFAB0A30"), 
        self, self.OnCameraEntityData
    )

    -- CameraEntityRu
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("5D4B1096-3089-45A7-9E3A-422E15E0D8F6"), 
        Guid("A4281E60-7557-4BFF-ADD4-18D7E8780873"), 
        self, self.OnCameraEntityData
    )
end

function Gunship:OnCameraEntityData(p_Instance)
    p_Instance = CameraEntityData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.enabled = false
end

function Gunship:OnGunShipCamera()
    self:EnableCamera(true)
end

function Gunship:OnForceJumpOufOfGunship()
    if self.m_IsInGunship then
        NetEvents:SendLocal(GunshipEvents.JumpOut)
        self:EnableCamera(false)
    end
end

function Gunship:OnUpdatePassPreSim(p_DeltaTime)
    if not self.m_IsInFreeFall then
        return
    end
    self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
    if self.m_CumulatedTime < ServerConfig.ParachuteRaycastUpdateRate then
        return
    end
    self.m_CumulatedTime = 0

    local s_LocalPlayer = PlayerManager:GetLocalPlayer()
    if s_LocalPlayer == nil or s_LocalPlayer.soldier == nil then
        return
    end

    local s_LocalPlayerPos = s_LocalPlayer.soldier.transform.trans
    local s_GroundPosToCheck = s_LocalPlayerPos - Vec3(0, ServerConfig.ForceParachuteHeight, 0)
    local s_ForceParachute = RaycastManager:Raycast(s_LocalPlayerPos, s_GroundPosToCheck, RayCastFlags.CheckDetailMesh | RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter | RayCastFlags.DontCheckRagdoll)

    if s_ForceParachute ~= nil then
        m_Logger:Write("Open parachute now")
        self.m_IsInFreeFall = false
        NetEvents:SendLocal(GunshipEvents.OpenParachute)
    end
end

function Gunship:OnClientUpdateInput()
    if not self.m_IsInGunship then
        return
    end

    if InputManager:IsKeyDown(InputDeviceKeys.IDK_E) then
        NetEvents:SendLocal(GunshipEvents.JumpOut)
        self:EnableCamera(false)
    end
end

function Gunship:EnableCamera(p_Enable)
    local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
    local s_CameraEntity = s_CameraEntityIterator:Next()

    while s_CameraEntity do
        if s_CameraEntity.data.instanceGuid == Guid("B19E172D-24EB-4513-9844-53ECA80A4FF9") then
            s_CameraEntity = Entity(s_CameraEntity)

            if p_Enable then
                self.m_IsInGunship = true
                s_CameraEntity:FireEvent("TakeControl")
            else
                self.m_IsInGunship = false
                self.m_IsInFreeFall = true
                s_CameraEntity:FireEvent("ReleaseControl")
            end

            return
        end

        s_CameraEntity = s_CameraEntityIterator:Next()
    end
end

if g_Gunship == nil then
    g_Gunship = Gunship()
end

return g_Gunship
