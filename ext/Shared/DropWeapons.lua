class 'DropWeapons'

function DropWeapons:__init()
    self.m_CenterOffset = 1.2
    self.m_HeightOffset = -0.5
    self.m_SubWorldDataLoaded = ResourceManager:RegisterInstanceLoadHandler(Guid('4D59552D-787F-402E-8FED-7B360186BD8A'), Guid('ED72C0EE-BAB1-4588-82AA-0BA8394EEEFB'), self, self.OnSubworldDataLoaded)
end

-- Wait for the gamemode subworld to load
function DropWeapons:OnSubworldDataLoaded(p_Instance)

    -- weapons in p_WeaponSlot 0 and 1 will be dropped as pickups for slot 0 or 1
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


    -- gadgets in p_WeaponSlot 2 and 5 will be dropped as pickups for slot 2 or 5
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

    -- grenade in p_WeaponSlot 6 and 8 will be dropped as pickups for slot 6 or 8
    local s_GrenadePickupAsset = PickupEntityAsset()
    s_GrenadePickupAsset.data = self:CreatePickupEntityDataForSlot(6, 8)

    local s_GrenadeDropComponent = DropWeaponComponentData()
    s_GrenadeDropComponent.deathPickup = s_GrenadePickupAsset
    s_GrenadeDropComponent.transform.trans = Vec3(0, self.m_HeightOffset, -self.m_CenterOffset*2)

    -- Add the components to the s_SoldierBlueprint and recreate the l_Connections required for a s_DropWeaponComponent
    local s_SoldierBlueprint = SoldierBlueprint(ResourceManager:SearchForDataContainer("Characters/Soldiers/MpSoldier"))
    s_SoldierBlueprint:MakeWritable()

    -- Update runtimeComponentCount (the client will crash if this is wrong), erasing 1 component and adding 5 new ones
    local s_SoldierEntityData = SoldierEntityData(s_SoldierBlueprint.object)
    s_SoldierEntityData:MakeWritable()
    s_SoldierEntityData.runtimeComponentCount = s_SoldierEntityData.runtimeComponentCount + 4

    local s_SoldierBodyComponent = SoldierBodyComponentData(s_SoldierEntityData.components[1])
    s_SoldierBodyComponent:MakeWritable()

    -- The vanilla MP soldier s_DropWeaponComponent, uses KitPickupEntityData
    local s_DropWeaponComponent = DropWeaponComponentData(s_SoldierBodyComponent.components[11])

    self:CloneConnections(s_SoldierBlueprint, s_DropWeaponComponent, s_PrimaryWeaponDropComponent)
    self:CloneConnections(s_SoldierBlueprint, s_DropWeaponComponent, s_SecondaryWeaponDropComponent)
    self:CloneConnections(s_SoldierBlueprint, s_DropWeaponComponent, s_PrimaryGadgetDropComponent)
    self:CloneConnections(s_SoldierBlueprint, s_DropWeaponComponent, s_SecondaryGadgetDropComponent)
    self:CloneConnections(s_SoldierBlueprint, s_DropWeaponComponent, s_GrenadeDropComponent)

    -- Erase the oringal s_DropWeaponComponent and add the custom ones
    s_SoldierBodyComponent.components:erase(11)
    s_SoldierBodyComponent.components:add(s_PrimaryWeaponDropComponent)
    s_SoldierBodyComponent.components:add(s_SecondaryWeaponDropComponent)
    s_SoldierBodyComponent.components:add(s_PrimaryGadgetDropComponent)
    s_SoldierBodyComponent.components:add(s_SecondaryGadgetDropComponent)
    s_SoldierBodyComponent.components:add(s_GrenadeDropComponent)

    local s_GamemodeSubWorld = SubWorldData(p_Instance)

    -- Add the created entityData to the entitys_Registry of the gamemode subworld
    local s_Registry = RegistryContainer()
    --s_Registry:MakeWritable()
    s_Registry.entityRegistry:add(s_PrimaryWeaponPickupAsset.data)
    s_Registry.entityRegistry:add(s_SecondaryWeaponPickupAsset.data)
    s_Registry.entityRegistry:add(s_PrimaryGadgetPickupAsset.data)
    s_Registry.entityRegistry:add(s_SecondaryGadgetPickupAsset.data)
    s_Registry.entityRegistry:add(s_GrenadePickupAsset.data)

    ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

function DropWeapons:CreatePickupEntityDataForSlot(p_WeaponSlot, p_AltWeaponSlot)

	local s_PhysicsBlueprint = ObjectBlueprint(ResourceManager:SearchForDataContainer("Weapons/M16A4/M16A4KitPickup"))

    local s_DynamicWeaponPickupSlotData = DynamicWeaponPickupSlotData()
    s_DynamicWeaponPickupSlotData.weaponSlot = p_WeaponSlot
    s_DynamicWeaponPickupSlotData.altWeaponSlot = p_AltWeaponSlot
    s_DynamicWeaponPickupSlotData.linkedToWeaponSlot = -1

    local s_DynamicWeaponPickupEntityData = DynamicWeaponPickupEntityData()
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
    s_DynamicWeaponPickupEntityData.weaponSlots:add(s_DynamicWeaponPickupSlotData)
    s_DynamicWeaponPickupEntityData.transform = LinearTransform(
        Vec3(1,  0,  0),
        Vec3(0,  1,  0),
        Vec3(0,  0,  1),
        Vec3(0,  0, -1000)
    )

    s_DynamicWeaponPickupEntityData.positionIsStatic = false

    return s_DynamicWeaponPickupEntityData
	
end

-- Clones l_Connections to and/or from the s_DropWeaponComponent and creates a similar one for our custom s_DropWeaponComponents
function DropWeapons:CloneConnections(p_Blueprint, p_OriginalData,  p_CustomData)

    for _, l_Connection in pairs(p_Blueprint.eventConnections) do
        
		if l_Connection.source == p_OriginalData then

            local s_Clone = EventConnection(l_Connection:Clone())
            s_Clone.source = p_CustomData

            p_Blueprint.eventConnections:add(s_Clone)
			
        end

        if l_Connection.target == p_OriginalData then
            
            local s_Clone = EventConnection(l_Connection:Clone())
            s_Clone.target = p_CustomData

            p_Blueprint.eventConnections:add(s_Clone)
			
        end
		
    end
	
end

g_DropWeapons = DropWeapons()
