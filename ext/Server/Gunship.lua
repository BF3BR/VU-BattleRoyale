local Gunship = class "Gunship"

require "__shared/Enums/CustomEvents"

function Gunship:__init(p_Match, p_TeamManager)
    -- Save Match and TeamManager reference
    self.m_Match = p_Match
    self.m_TeamManager = p_TeamManager

    self.m_StartTransform = nil

    self.m_SpeedMultiplier = 1.5

    -- TODO: Fix this (?)
    NetEvents:Subscribe(GunshipEvents.JumpOut, self, self.OnJumpOutOfGunship)

    self.m_SetFlyPath = false
    self.m_CumulatedTime = 0

    self.m_Enabled = false

    self.m_VehicleEntity = nil
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

    local s_BrPlayer = self.m_TeamManager:GetPlayer(p_Player)
    if s_BrPlayer == nil then
        return
    end

    s_BrPlayer:Spawn(s_Transform)
    NetEvents:SendToLocal(GunshipEvents.JumpOut, p_Player)
end

function Gunship:OnEngineUpdate(p_DeltaTime)
    if not self.m_SetFlyPath then
        if self.m_VehicleEntity ~= nil then
            NetEvents:BroadcastLocal(GunshipEvents.Position, self.m_VehicleEntity.transform)
            NetEvents:BroadcastLocal(GunshipEvents.Yaw, self.m_StartTransform)
        end

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
        NetEvents:BroadcastLocal(GunshipEvents.Camera)
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
                
                self.m_VehicleEntity = nil
                self.m_Enabled = false
            end
            return
        end

        s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
    end
end

function Gunship:GetEnabled()
    return self.m_Enabled
end

function Gunship:SetVehicleEntityTransform()
    local s_VehicleEntityIterator = EntityManager:GetIterator("ServerVehicleEntity")
    local s_VehicleEntity = s_VehicleEntityIterator:Next()

    while s_VehicleEntity do
        if s_VehicleEntity.data.instanceGuid == Guid("81ED68CF-5FDE-4C24-A6B4-C38FB8D4A778") then
            s_VehicleEntity = SpatialEntity(s_VehicleEntity)
            s_VehicleEntity.transform = self.m_StartTransform
            self.m_VehicleEntity = s_VehicleEntity
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
        
        local s_SpeedMultiplier = self.m_SpeedMultiplier
        local s_TickRate = SharedUtils:GetTickrate()
        if s_TickRate == 120.0 then
            s_SpeedMultiplier = s_SpeedMultiplier / 4
            s_DirectionTransform.trans.x = s_DirectionTransform.trans.x + self.m_StartTransform.forward.x * s_SpeedMultiplier
            s_DirectionTransform.trans.z = s_DirectionTransform.trans.z + self.m_StartTransform.forward.z * s_SpeedMultiplier
        elseif s_TickRate == 60.0 then
            s_SpeedMultiplier = s_SpeedMultiplier * 2
            s_DirectionTransform.trans.x = s_DirectionTransform.trans.x + self.m_StartTransform.forward.x * s_SpeedMultiplier
            s_DirectionTransform.trans.z = s_DirectionTransform.trans.z + self.m_StartTransform.forward.z * s_SpeedMultiplier
        else
            s_DirectionTransform.trans.x = s_DirectionTransform.trans.x - self.m_StartTransform.forward.x * s_SpeedMultiplier
            s_DirectionTransform.trans.z = s_DirectionTransform.trans.z - self.m_StartTransform.forward.z * s_SpeedMultiplier
        end

        s_LocatorEntity.transform = s_DirectionTransform
        s_LocatorEntity = s_LocatorEntityIterator:Next()
    end
end

return Gunship
