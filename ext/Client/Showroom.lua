class "Showroom"

function Showroom:__init()
    self.m_ShowRoomBlueprint = ResourceManager:RegisterInstanceLoadHandler(
        Guid("51D7CE33-5181-11E0-A781-B6644A4BE024"),
        Guid("0EF06698-B9EA-4557-AFE0-78CA4575E726"), 
        self, 
        self.OnShowRoomBlueprint
    )

    self.m_ShowRoomCamera = ResourceManager:RegisterInstanceLoadHandler(
        Guid("08F255D1-499D-4090-B114-4CE8D1B3AC65"),
        Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19"), 
        self, 
        self.OnShowRoomCamera
    )

    self.m_CameraEnabled = false
end

function Showroom:OnShowRoomBlueprint(p_Instance)
    local s_Instance = ReferenceObjectData(p_Instance)
    --print(s_Instance.blueprintTransform)
end


function Showroom:OnShowRoomCamera(p_Instance)
    local s_Instance = CameraEntityData(p_Instance)
    s_Instance:MakeWritable()
    s_Instance.enabled = true
    s_Instance.priority = 1
end

function Showroom:EnableCamera()
    if self.m_CameraEnabled then
        return
    end

    local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
    local s_CameraEntity = s_CameraEntityIterator:Next()

    while s_CameraEntity do
        if s_CameraEntity.data.instanceGuid == Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19") then
            s_CameraEntity = Entity(s_CameraEntity)
            s_CameraEntity:FireEvent("TakeControl")
            self:SpawnCharacter()
            self.m_CameraEnabled = true
            return
        end

        s_CameraEntity = s_CameraEntityIterator:Next()
    end
end

if g_Showroom == nil then
    g_Showroom = Showroom()
end

return g_Showroom
