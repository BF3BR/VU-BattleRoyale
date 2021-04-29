class "WeaponDropModifier"

local m_Logger = Logger("WeaponDropModifier", true)
local m_ConnectionHelper = require("__shared/Utils/ConnectionHelper")
local m_RegistryManager = require("__shared/Logic/RegistryManager")

-- Weapon drop offsets from the origin of the soldier
local m_CenterOffset = 1.2
local m_HeightOffset = -0.5

-- PhysicsBlueprint for all weapons: Weapons/M16A4/M16A4KitPickup
local m_PhysicsBlueprint = DC(Guid("625C2806-0CE7-11E0-915B-91EB202EAE87"), Guid("B9E3B4B8-062A-1DA8-E13D-8D7095F2A610"))

-- Replace vanilla DropWeaponComponentData (drops a kit) with 5 DropWeaponComponentDatas that all drop a weapon 
function WeaponDropModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	-- Drop weapons in WeaponSlot 0 and 1 as pickups for slot 0 or 1
	local s_PrimaryWeaponPickupAsset = PickupEntityAsset()
	s_PrimaryWeaponPickupAsset.data = self:CreatePickupEntityDataForSlot(0, 1)

	local s_PrimaryWeaponDropComponent = DropWeaponComponentData()
	s_PrimaryWeaponDropComponent.deathPickup = s_PrimaryWeaponPickupAsset
	s_PrimaryWeaponDropComponent.transform.trans = Vec3(m_CenterOffset, m_HeightOffset, 0)

	local s_SecondaryWeaponPickupAsset = PickupEntityAsset()
	s_SecondaryWeaponPickupAsset.data = self:CreatePickupEntityDataForSlot(1, 0)

	local s_SecondaryWeaponDropComponent = DropWeaponComponentData()
	s_SecondaryWeaponDropComponent.deathPickup = s_SecondaryWeaponPickupAsset
	s_SecondaryWeaponDropComponent.transform.trans = Vec3(-m_CenterOffset, m_HeightOffset, 0)

	-- Drop gadgets in WeaponSlot 2 and 5 as pickups for slot 2 or 5
	local s_PrimaryGadgetPickupAsset = PickupEntityAsset()
	s_PrimaryGadgetPickupAsset.data = self:CreatePickupEntityDataForSlot(2, 5)

	local s_PrimaryGadgetDropComponent = DropWeaponComponentData()
	s_PrimaryGadgetDropComponent.deathPickup = s_PrimaryGadgetPickupAsset
	s_PrimaryGadgetDropComponent.transform.trans = Vec3(0, m_HeightOffset, m_CenterOffset)

	local s_SecondaryGadgetPickupAsset = PickupEntityAsset()
	s_SecondaryGadgetPickupAsset.data = self:CreatePickupEntityDataForSlot(5, 2)

	local s_SecondaryGadgetDropComponent = DropWeaponComponentData()
	s_SecondaryGadgetDropComponent.deathPickup = s_SecondaryGadgetPickupAsset
	s_SecondaryGadgetDropComponent.transform.trans = Vec3(0, m_HeightOffset, -m_CenterOffset)

	-- Drop grenades in WeaponSlot 6 and 8 as pickups for slot 6 or 8
	local s_GrenadePickupAsset = PickupEntityAsset()
	s_GrenadePickupAsset.data = self:CreatePickupEntityDataForSlot(6, 8)

	local s_GrenadeDropComponent = DropWeaponComponentData()
	s_GrenadeDropComponent.deathPickup = s_GrenadePickupAsset
	s_GrenadeDropComponent.transform.trans = Vec3(0, m_HeightOffset, -m_CenterOffset * 2)

	-- Update runtimeComponentCount (the client will crash if this is wrong), erasing 1 component and adding 5 new ones
	local s_SoldierEntityData = SoldierEntityData(p_SoldierBlueprint.object)
	s_SoldierEntityData:MakeWritable()
	s_SoldierEntityData.runtimeComponentCount = s_SoldierEntityData.runtimeComponentCount + 4

	local s_SoldierBodyComponent = SoldierBodyComponentData(s_SoldierEntityData.components[1])
	s_SoldierBodyComponent:MakeWritable()

	-- The vanilla MP soldier DropWeaponComponent (using KitPickupEntityData, drops a kit instead of weapons)
	local s_DropWeaponComponent = DropWeaponComponentData(s_SoldierBodyComponent.components[11])
	m_ConnectionHelper:CloneConnections(p_SoldierBlueprint, s_DropWeaponComponent, s_PrimaryWeaponDropComponent)
	m_ConnectionHelper:CloneConnections(p_SoldierBlueprint, s_DropWeaponComponent, s_SecondaryWeaponDropComponent)
	m_ConnectionHelper:CloneConnections(p_SoldierBlueprint, s_DropWeaponComponent, s_PrimaryGadgetDropComponent)
	m_ConnectionHelper:CloneConnections(p_SoldierBlueprint, s_DropWeaponComponent, s_SecondaryGadgetDropComponent)
	m_ConnectionHelper:CloneConnections(p_SoldierBlueprint, s_DropWeaponComponent, s_GrenadeDropComponent)

	-- Erase the kit DropWeaponComponent and add the custom ones
	s_SoldierBodyComponent.components:erase(11)
	s_SoldierBodyComponent.components:add(s_PrimaryWeaponDropComponent)
	s_SoldierBodyComponent.components:add(s_SecondaryWeaponDropComponent)
	s_SoldierBodyComponent.components:add(s_PrimaryGadgetDropComponent)
	s_SoldierBodyComponent.components:add(s_SecondaryGadgetDropComponent)
	s_SoldierBodyComponent.components:add(s_GrenadeDropComponent)

	-- Add the created entityData to the registry
	local s_Registry = m_RegistryManager:GetRegistry()
	s_Registry.entityRegistry:add(s_PrimaryWeaponPickupAsset.data)
	s_Registry.entityRegistry:add(s_SecondaryWeaponPickupAsset.data)
	s_Registry.entityRegistry:add(s_PrimaryGadgetPickupAsset.data)
	s_Registry.entityRegistry:add(s_SecondaryGadgetPickupAsset.data)
	s_Registry.entityRegistry:add(s_GrenadePickupAsset.data)

	m_Logger:Write("WeaponDropComponents added to SoldierBlueprint")
end

function WeaponDropModifier:CreatePickupEntityDataForSlot(p_WeaponSlot, p_AltWeaponSlot)
	local s_DynamicWeaponPickupSlotData = DynamicWeaponPickupSlotData()
	s_DynamicWeaponPickupSlotData.weaponSlot = p_WeaponSlot
	s_DynamicWeaponPickupSlotData.altWeaponSlot = p_AltWeaponSlot
	s_DynamicWeaponPickupSlotData.linkedToWeaponSlot = -1

	local s_DynamicWeaponPickupEntityData = DynamicWeaponPickupEntityData()
	s_DynamicWeaponPickupEntityData.physicsBlueprint = m_PhysicsBlueprint:GetInstance()
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
	s_DynamicWeaponPickupEntityData.weaponSlots:add(s_DynamicWeaponPickupSlotData)

	return s_DynamicWeaponPickupEntityData
end

if g_WeaponDropModifier == nil then
	g_WeaponDropModifier = WeaponDropModifier()
end

return g_WeaponDropModifier
