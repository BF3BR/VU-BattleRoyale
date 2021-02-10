class "Showroom"

function Showroom:__init()
    self.m_ShowRoomBlueprint = ResourceManager:RegisterInstanceLoadHandler(
        Guid("51D7CE33-5181-11E0-A781-B6644A4BE024"),
        Guid("0EF06698-B9EA-4557-AFE0-78CA4575E726"), 
        self, 
        self.OnShowRoomBlueprint
    )
end

function Showroom:OnShowRoomBlueprint(p_Instance)
    local s_Instance = ReferenceObjectData(p_Instance)
    --print(s_Instance.blueprintTransform)
end

function Showroom:EnableCamera()
    local s_CameraEntityIterator = EntityManager:GetIterator("ClientCameraEntity")
    local s_CameraEntity = s_CameraEntityIterator:Next()

    while s_CameraEntity do
        if s_CameraEntity.data.instanceGuid == Guid("528655FC-2653-4D5B-B55D-E6CBF997FC19") then
            s_CameraEntity = Entity(s_CameraEntity)

            --[[if p_Enable then
                self.m_IsInGunship = true
                
            else
                s_CameraEntity:FireEvent("ReleaseControl")
            end]]
            print("TakeControl")
            s_CameraEntity:FireEvent("TakeControl")

            return
        end

        s_CameraEntity = s_CameraEntityIterator:Next()
    end
end


if g_Showroom == nil then
    g_Showroom = Showroom()
end

return g_Showroom
