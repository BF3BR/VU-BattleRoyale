class "Showroom"

function Showroom:RegisterCallbacks()
    -- ShowRoomBlueprint
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("51D7CE33-5181-11E0-A781-B6644A4BE024"),
        Guid("0EF06698-B9EA-4557-AFE0-78CA4575E726"), 
        self, self.OnShowRoomBlueprint
    )

    -- ShowRoomCamera
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("08F255D1-499D-4090-B114-4CE8D1B3AC65"),
        Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19"), 
        self, self.OnShowRoomCamera
    )
end

function Showroom:OnShowRoomBlueprint(p_Instance)
    local s_Instance = ReferenceObjectData(p_Instance)
end

function Showroom:OnShowRoomCamera(p_Instance)
    local s_Instance = CameraEntityData(p_Instance)
    s_Instance:MakeWritable()
    s_Instance.enabled = true
    s_Instance.priority = 999
end

function Showroom:SetCamera(p_Enable)
    local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
    local s_CameraEntity = s_CameraEntityIterator:Next()

    while s_CameraEntity do
        if s_CameraEntity.data.instanceGuid == Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19") then
            s_CameraEntity = Entity(s_CameraEntity)

            if p_Enable then
                s_CameraEntity:FireEvent("TakeControl")
            else
                s_CameraEntity:FireEvent("ReleaseControl")
            end
            return
        end

        s_CameraEntity = s_CameraEntityIterator:Next()
    end
end

if g_Showroom == nil then
    g_Showroom = Showroom()
end

return g_Showroom
