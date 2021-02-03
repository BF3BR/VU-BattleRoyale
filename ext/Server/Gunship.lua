local Gunship = class "Gunship"

function Gunship:__init(p_Match)
    -- Save match reference
	self.m_Match = p_Match
	
	self.m_StartTransform = nil

	self.m_SpeedMultiplier = 1.5

    self.m_JumpOutOfGunshipEvent = NetEvents:Subscribe("JumpOutOfGunship", self, self.OnJumpOutOfGunship)

    self.m_SetFlyPath = false
    self.m_CumulatedTime = 0

    self.m_Enabled = false
end

function Gunship:OnJumpOutOfGunship(p_Player)
    -- Get the Gunship transform
    local s_Transform = nil

    local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
    local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()

    while s_VehicleSpawnEntity do
        if s_VehicleSpawnEntity.data.instanceGuid == Guid("81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778") then
            s_VehicleSpawnEntity = SpatialEntity(s_VehicleSpawnEntity)
            s_Transform = s_VehicleSpawnEntity.transform
            s_Transform.trans = Vec3(s_Transform.trans.x, s_Transform.trans.y - 20, s_Transform.trans.z)

            break
        end

        s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
    end

    self.m_Match:SpawnPlayer(p_Player, s_Transform)
    p_Player.soldier.health = 200.0
end

function Gunship:OnEngineUpdate(p_DeltaTime)
    if not self.m_SetFlyPath then
        return
    end
    
    if self.m_StartTransform == nil then
        return
    end
	
	self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
	
    if self.m_CumulatedTime >= 0.1 then
        self.m_SetFlyPath = false
        self.m_CumulatedTime = 0
        self:SetLocatorEntityTransform()
        self:SetVehicleEntityTransform()
        NetEvents:BroadcastLocal("GunshipCamera")
    end
end

function Gunship:Spawn(p_StartTransform, p_Enable)
    if p_Enable == self.m_Enabled then
        return
    end

    local s_VehicleSpawnEntityIterator = EntityManager:GetIterator("ServerVehicleSpawnEntity")
    local s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()

    while s_VehicleSpawnEntity do
        if s_VehicleSpawnEntity.data.instanceGuid == Guid("5449C054-7A18-4696-8AA9-416A8B9A9CD0") then
            s_VehicleSpawnEntity = Entity(s_VehicleSpawnEntity)
            if p_Enable == true then
                if p_StartTransform == nil then
                    return
                end
                self.m_StartTransform = p_StartTransform

                s_VehicleSpawnEntity:FireEvent("Spawn")

                self.m_SetFlyPath = true
                self.m_Enabled = true
            else
                s_VehicleSpawnEntity:FireEvent("Unspawn")
                
                self.m_Enabled = false
            end
            return
        end

        s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
    end
end

function Gunship:SetVehicleEntityTransform()
    local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
    local s_VehicleEntity = s_VehicleEntityIterator:Next()

    while s_VehicleEntity do
        if s_VehicleEntity.data.instanceGuid == Guid("81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778") then
            s_VehicleEntity = SpatialEntity(s_VehicleEntity)
            s_VehicleEntity.transform = self.m_StartTransform
            break
		end
		
        s_VehicleEntity = s_VehicleEntityIterator:Next()
    end
end

function Gunship:SetLocatorEntityTransform()
    local s_LocatorEntityIterator = EntityManager:GetIterator("LocatorEntity")
    local s_LocatorEntity = s_LocatorEntityIterator:Next()

    while s_LocatorEntity do
		s_LocatorEntity = SpatialEntity(s_LocatorEntity)
		
		local s_DirectionTransform = self.m_StartTransform
		s_DirectionTransform.trans.x = s_DirectionTransform.trans.x - self.m_StartTransform.forward.x * self.m_SpeedMultiplier
		s_DirectionTransform.trans.z = s_DirectionTransform.trans.z - self.m_StartTransform.forward.z * self.m_SpeedMultiplier
		
        s_LocatorEntity.transform = s_DirectionTransform
        s_LocatorEntity = s_LocatorEntityIterator:Next()
    end
end

return Gunship
