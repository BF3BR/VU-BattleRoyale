class "WeaponDropModifier"


local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"

function WeaponDropModifier:__init()
    self.m_CenterOffset = 1.2
    self.m_HeightOffset = -0.5
end

function WeaponDropModifier:OnPartitionLoaded(p_Partition, p_Registry)
    if p_Partition.name ~= "characters/soldiers/mpsoldier" then
        return
    end

    local s_SoldierBlueprint = SoldierBlueprint(p_Partition.primaryInstance)
    s_SoldierBlueprint:MakeWritable()

    self:AddWeaponDropComponents(s_SoldierBlueprint, p_Registry)

    -- TODO: Fix drop transforms, add config (or spawn pickups in vext)
end

function WeaponDropModifier:AddWeaponDropComponents(p_Blueprint, p_Registry)
    -- weapons in WeaponSlot 0 and 1 will be dropped as pickups for slot 0 or 1
    local s_PrimaryWeaponPickupAsset = PickupEntityAsset()
    s_PrimaryWeaponPickupAsset.data = self:CreatePickupEntityDataForSlot(0, 1)

    local s_PrimaryWeaponDropComponent = DropWeaponComponentData()
    s_PrimaryWeaponDropComponent.deathPickup = s_PrimaryWeaponPickupAsset
    s_PrimaryWeaponDropComponent.transform.trans = Vec3(self.m_CenterOffset, self.m_HeightOffset, 0)

    local s_SecondaryWeaponPickupAsset = PickupEntityAsset()
    s_SecondaryWeaponPickupAsset.data = self:CreatePickupEntityDataForSlot(1, 0)

    local s_SecondaryWeaponDropComponent = DropWeaponComponentData()
    s_SecondaryWeaponDropComponent.deathPickup = s_SecondaryWeaponPickupAsset
    s_SecondaryWeaponDropComponent.transform.trans = Vec3(-self.m_CenterOffset, self.m_HeightOffset, 0)

    -- gadgets in WeaponSlot 2 and 5 will be dropped as pickups for slot 2 or 5
    local s_PrimaryGadgetPickupAsset = PickupEntityAsset()
    s_PrimaryGadgetPickupAsset.data = self:CreatePickupEntityDataForSlot(2, 5)

    local s_PrimaryGadgetDropComponent = DropWeaponComponentData()
    s_PrimaryGadgetDropComponent.deathPickup = s_PrimaryGadgetPickupAsset
    s_PrimaryGadgetDropComponent.transform.trans = Vec3(0, self.m_HeightOffset, self.m_CenterOffset)

    local s_SecondaryGadgetPickupAsset = PickupEntityAsset()
    s_SecondaryGadgetPickupAsset.data = self:CreatePickupEntityDataForSlot(5, 2)

    local s_SecondaryGadgetDropComponent = DropWeaponComponentData()
    s_SecondaryGadgetDropComponent.deathPickup = s_SecondaryGadgetPickupAsset
    s_SecondaryGadgetDropComponent.transform.trans = Vec3(0, self.m_HeightOffset, -self.m_CenterOffset)

    -- grenade in WeaponSlot 6 and 8 will be dropped as pickups for slot 6 or 8
    local s_GrenadePickupAsset = PickupEntityAsset()
    s_GrenadePickupAsset.data = self:CreatePickupEntityDataForSlot(6, 8)

    local s_GrenadeDropComponent = DropWeaponComponentData()
    s_GrenadeDropComponent.deathPickup = s_GrenadePickupAsset
    s_GrenadeDropComponent.transform.trans = Vec3(0, self.m_HeightOffset, -self.m_CenterOffset * 2)

    -- Update runtimeComponentCount (the client will crash if this is wrong), erasing 1 component and adding 5 new ones
    local s_SoldierEntityData = SoldierEntityData(p_Blueprint.object)
    s_SoldierEntityData:MakeWritable()
    s_SoldierEntityData.runtimeComponentCount = s_SoldierEntityData.runtimeComponentCount + 4

    local s_SoldierBodyComponent = SoldierBodyComponentData(s_SoldierEntityData.components[1])
    s_SoldierBodyComponent:MakeWritable()

    -- The vanilla MP soldier s_DropWeaponComponent, uses KitPickupEntityData
    local s_DropWeaponComponent = DropWeaponComponentData(s_SoldierBodyComponent.components[11])

    -- Clone event connections to and/or from the default DropWeaponComponent and creates a similar one for our custom DropWeaponComponents
    m_ConnectionHelper:CloneConnections(p_Blueprint, s_DropWeaponComponent, s_PrimaryWeaponDropComponent)
    m_ConnectionHelper:CloneConnections(p_Blueprint, s_DropWeaponComponent, s_SecondaryWeaponDropComponent)
    m_ConnectionHelper:CloneConnections(p_Blueprint, s_DropWeaponComponent, s_PrimaryGadgetDropComponent)
    m_ConnectionHelper:CloneConnections(p_Blueprint, s_DropWeaponComponent, s_SecondaryGadgetDropComponent)
    m_ConnectionHelper:CloneConnections(p_Blueprint, s_DropWeaponComponent, s_GrenadeDropComponent)

    -- Erase the oringal DropWeaponComponent and add the custom ones
    s_SoldierBodyComponent.components:erase(11)
    s_SoldierBodyComponent.components:add(s_PrimaryWeaponDropComponent)
    s_SoldierBodyComponent.components:add(s_SecondaryWeaponDropComponent)
    s_SoldierBodyComponent.components:add(s_PrimaryGadgetDropComponent)
    s_SoldierBodyComponent.components:add(s_SecondaryGadgetDropComponent)
    s_SoldierBodyComponent.components:add(s_GrenadeDropComponent)

    -- Add the created entityData to our custom Registry
    p_Registry.entityRegistry:add(s_PrimaryWeaponPickupAsset.data)
    p_Registry.entityRegistry:add(s_SecondaryWeaponPickupAsset.data)
    p_Registry.entityRegistry:add(s_PrimaryGadgetPickupAsset.data)
    p_Registry.entityRegistry:add(s_SecondaryGadgetPickupAsset.data)
    p_Registry.entityRegistry:add(s_GrenadePickupAsset.data)
end

function WeaponDropModifier:CreatePickupEntityDataForSlot(p_WeaponSlot, p_AltWeaponSlot)
    local s_PhysicsBlueprint = ObjectBlueprint(ResourceManager:SearchForDataContainer("Weapons/M16A4/M16A4KitPickup"))

    local s_DynamicWeaponPickupSlotData = DynamicWeaponPickupSlotData()
    s_DynamicWeaponPickupSlotData.weaponSlot = p_WeaponSlot
    s_DynamicWeaponPickupSlotData.altWeaponSlot = p_AltWeaponSlot
    s_DynamicWeaponPickupSlotData.linkedToWeaponSlot = -1

    local s_DynamicWeaponPickupEntityData = DynamicWeaponPickupEntityData()
    s_DynamicWeaponPickupEntityData.weaponSlots:add(s_DynamicWeaponPickupSlotData)
    s_DynamicWeaponPickupEntityData.physicsBlueprint = s_PhysicsBlueprint
    s_DynamicWeaponPickupEntityData.useWeaponMesh = true
    s_DynamicWeaponPickupEntityData.preferredWeaponSlot = -1
    s_DynamicWeaponPickupEntityData.allowPickup = true
    s_DynamicWeaponPickupEntityData.ignoreNullWeaponSlots = true
    s_DynamicWeaponPickupEntityData.forceWeaponSlotSelection = false
    s_DynamicWeaponPickupEntityData.displayInMiniMap = true
    s_DynamicWeaponPickupEntityData.interactionRadius = 2.5
    s_DynamicWeaponPickupEntityData.replaceAllContent = false
    s_DynamicWeaponPickupEntityData.removeWeaponOnDrop = false
    s_DynamicWeaponPickupEntityData.keepAmmoState = true
    s_DynamicWeaponPickupEntityData.positionIsStatic = false
    s_DynamicWeaponPickupEntityData.transform = LinearTransform(Vec3(1, 0, 0), Vec3(0, 1, 0), Vec3(0, 0, 1),Vec3(0, 0, -1000))

    return s_DynamicWeaponPickupEntityData
end

-- Singleton
if g_WeaponDropModifier == nil then
	g_WeaponDropModifier = WeaponDropModifier()
end

return g_WeaponDropModifier