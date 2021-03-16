local Airdrop = class "Airdrop"

local m_Logger = Logger("Airdrop", true)

function Airdrop:__init(p_Match)
    -- Save match reference
    self.m_Match = p_Match

    self.m_StartTransform = nil

    self.m_SpeedMultiplier = 1.5

    self.m_SetFlyPath = false
    self.m_CumulatedTime = 0

    self.m_Enabled = false

    self.m_VehicleEntity = nil

    self.m_TimeToDrop = nil
    self.m_DropTimer = 0.0
end

function Airdrop:OnEngineUpdate(p_DeltaTime)
    -- Drop timer
    if self.m_TimeToDrop ~= nil then
        self.m_DropTimer = self.m_DropTimer + p_DeltaTime

        if self.m_DropTimer >= self.m_TimeToDrop then
            m_Logger:Write("INFO: Airdrop dropped the item!")
            self.m_TimeToDrop = nil

            -- TODO: Drop the loot crate
        end
    end

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
    end
end

function Airdrop:Spawn(p_StartTransform, p_Enable, p_TimeToDrop)
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
                self.m_TimeToDrop = p_TimeToDrop
                m_Logger:Write("INFO: Time to drop: " .. p_TimeToDrop)
            else
                s_VehicleSpawnEntity:FireEvent("Unspawn")

                self.m_VehicleEntity = nil
                self.m_Enabled = false
                self.m_TimeToDrop = nil
            end
            return
        end

        s_VehicleSpawnEntity = s_VehicleSpawnEntityIterator:Next()
    end
end

function Airdrop:GetEnabled()
    return self.m_Enabled
end

function Airdrop:SetVehicleEntityTransform()
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

function Airdrop:SetLocatorEntityTransform()
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
