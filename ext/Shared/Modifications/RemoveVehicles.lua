class "RemoveVehicles"

function RemoveVehicles:__init()
    self.m_WorldPartData = ResourceManager:RegisterInstanceLoadHandler(
        Guid("8A1B5CE5-A537-49C6-9C44-0DA048162C94"),
        Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D"),
       self, 
       self.OnWorldPartData
    )
end

function RemoveVehicles:OnWorldPartData(p_Instance)
    p_Instance = WorldPartData(p_Instance)
    for i, l_Object in pairs(p_Instance.objects) do
        if l_Object:Is("ReferenceObjectData") then
            l_Object = ReferenceObjectData(l_Object)
            if l_Object.blueprint.instanceGuid ~= Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95") and
                l_Object.blueprint.instanceGuid ~= Guid("B57E136A-0E4D-4952-8823-98A20DFE8F44") then
                l_Object:MakeWritable()
                l_Object.excluded = true
            end
        end
    end
end

g_RemoveVehicles = RemoveVehicles()
