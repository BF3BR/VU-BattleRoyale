class "GunshipModifier"


function GunshipModifier:__init()
    self:ResetVars()
    self:RegisterEvents()
end

function GunshipModifier:ResetVars()
    self.m_SpawnTransform = nil
end

function GunshipModifier:RegisterEvents()
    Events:Subscribe('VuBattleRoyale:GunshipStartTransform', self, self.SetStartTransform)
    NetEvents:Subscribe('VuBattleRoyale:GunshipStartTransform', self, self.SetStartTransform)
end

function GunshipModifier:SetStartTransform(p_Transform)  
    self.m_SpawnTransform = p_Transform:Clone()

    print("[GunshipModifier] Got start transform: "..tostring(self.m_SpawnTransform))
end

function GunshipModifier:OnSubWorldLoaded(p_SubWorldData, p_Common)
    local s_c130Blueprint = VehicleBlueprint(ResourceManager:SearchForDataContainer("Vehicles/XP5/C130/C130"))
    local s_VehicleSpawnReferenceObjectData = VehicleSpawnReferenceObjectData(MathUtils:RandomGuid())
    s_VehicleSpawnReferenceObjectData.blueprint = s_c130Blueprint
    s_VehicleSpawnReferenceObjectData.blueprintTransform = self.m_SpawnTransform
    s_VehicleSpawnReferenceObjectData.initialSpawnDelay = 0
    s_VehicleSpawnReferenceObjectData.spawnDelay = 0
    s_VehicleSpawnReferenceObjectData.maxCount = 0
    s_VehicleSpawnReferenceObjectData.maxCountSimultaneously = 1
    s_VehicleSpawnReferenceObjectData.totalCountSimultaneouslyOfType = 0
    s_VehicleSpawnReferenceObjectData.autoSpawn = false
    s_VehicleSpawnReferenceObjectData.setTeamOnSpawn = false
    s_VehicleSpawnReferenceObjectData.indexInBlueprint = p_Common:GetIndex()
	s_VehicleSpawnReferenceObjectData.isEventConnectionTarget = 2
	s_VehicleSpawnReferenceObjectData.isPropertyConnectionTarget = 2
    p_SubWorldData.objects:add(s_VehicleSpawnReferenceObjectData)
    p_Common.m_Registry.referenceObjectRegistry:add(s_VehicleSpawnReferenceObjectData)

    print("[GunshipModifier] Added Gunship spawn at "..tostring(self.m_SpawnTransform))
end


-- Singleton
if g_GunshipModifier == nil then
	g_GunshipModifier = GunshipModifier()
end

return g_GunshipModifier