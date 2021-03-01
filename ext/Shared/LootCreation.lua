class "LootCreation"

local m_ConnectionHelper = require("__shared/Utils/ConnectionHelper")

function LootCreation:__init()
    self:RegisterEvents()
    self:RegisterVars()
end

function LootCreation:RegisterEvents()
    Events:Subscribe('LMS:RLT', self, self.OnRandomLootTransforms)
    NetEvents:Subscribe('LMS:RLT', self, self.OnRandomLootTransforms)
end

function LootCreation:RegisterVars()
    self.m_PickupBlueprints = {} 
    self.m_RandomLootTransforms = {}
end

function LootCreation:OnRandomLootTransforms(p_Transforms)
    self.m_RandomLootTransforms = p_Transforms
    print("[LootCreation] Received loot transforms")
end

function LootCreation:OnWorldPartData(p_WorldPartData, p_Registry)
    self:CreateAndRegisterPickupBlueprints(p_Registry)

    for i, l_Data in pairs(self.m_RandomLootTransforms) do
        local s_PickupReferenceObjectData = ReferenceObjectData()
        s_PickupReferenceObjectData.blueprint = self.m_PickupBlueprints[l_Data.tier]
        s_PickupReferenceObjectData.blueprintTransform = l_Data.transform
        s_PickupReferenceObjectData.indexInBlueprint = 3 + i

        p_WorldPartData.objects:add(s_PickupReferenceObjectData)

        p_Registry.referenceObjectRegistry:add(s_PickupReferenceObjectData)
    end

    print("[LootCreation] Created loot spawns")
end

function LootCreation:CreateAndRegisterPickupBlueprints(p_Registry)
    for l_Tier, l_TierConfig in pairs(PickupsConfig.Tiers) do
        local s_PickupEntityData = WeaponUnlockPickupEntityData()
        s_PickupEntityData.transform = PickupsConfig.WeaponTransform
        s_PickupEntityData.interactionRadius = PickupsConfig.InteractionRadius
        s_PickupEntityData.randomlySelectOneWeapon = true
        s_PickupEntityData.minRandomClipAmmoPercent = 0
        s_PickupEntityData.maxRandomClipAmmoPercent = 0
        s_PickupEntityData.preferredWeaponSlot = 0
        s_PickupEntityData.timeToLive = 0.0
        s_PickupEntityData.minRandomSpareAmmoPercent = 0
        s_PickupEntityData.maxRandomSpareAmmoPercent = 0
        s_PickupEntityData.unspawnOnPickup = false
        s_PickupEntityData.forceWeaponSlotSelection = true
        s_PickupEntityData.hasAutomaticAmmoPickup = false
        s_PickupEntityData.unspawnOnAmmoPickup = false
        s_PickupEntityData.useWeaponMesh = true
        s_PickupEntityData.allowPickup = true
        s_PickupEntityData.contentIsStatic = false
        s_PickupEntityData.positionIsStatic = true
        s_PickupEntityData.ignoreNullWeaponSlots = false
        s_PickupEntityData.replaceAllContent = false
        s_PickupEntityData.removeWeaponOnDrop = false
        s_PickupEntityData.sendPlayerInEventOnPickup = true
        s_PickupEntityData.indexInBlueprint = 0
        s_PickupEntityData.isEventConnectionTarget = 2
        s_PickupEntityData.isPropertyConnectionTarget = 1
        
        for _, l_Weapon in pairs(l_TierConfig.Weapons) do
            if l_Weapon.Attachments == nil then
                s_PickupEntityData.weapons:add(WeaponUnlockPickupData())
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(ResourceManager:SearchForDataContainer(l_Weapon.Name))
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_0
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].altWeaponSlot = WeaponSlot.WeaponSlot_1
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].linkedToWeaponSlot = -1
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].minAmmo = l_Weapon.Ammo
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].maxAmmo = l_Weapon.Ammo
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].defaultToFullAmmo = false
            else
                for _, l_Unlock in pairs(l_Weapon.Attachments) do
                    s_PickupEntityData.weapons:add(WeaponUnlockPickupData())
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(ResourceManager:SearchForDataContainer(l_Weapon.Name))
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_0
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].altWeaponSlot = WeaponSlot.WeaponSlot_1
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].linkedToWeaponSlot = -1
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].minAmmo = l_Weapon.Ammo
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].maxAmmo = l_Weapon.Ammo
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].defaultToFullAmmo = false
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.unlockAssets:add(UnlockAssetBase(ResourceManager:SearchForDataContainer(l_Unlock)))
                end
            end
        end
       
        local s_MapMarkerEntityData = MapMarkerEntityData()
        s_MapMarkerEntityData.transform.trans = PickupsConfig.MarkerTransform
        --s_MapMarkerEntityData.baseTransform = PickupsConfig.MarkerTransform
        s_MapMarkerEntityData.sid = l_TierConfig.Message
        s_MapMarkerEntityData.showRadius = PickupsConfig.MarkerShowRadius
        s_MapMarkerEntityData.hideRadius = PickupsConfig.MarkerHideRadius
        s_MapMarkerEntityData.hudIcon = l_TierConfig.HudIcon
        s_MapMarkerEntityData.verticalOffset = 0.0
        s_MapMarkerEntityData.focusPointRadius = 80.0
        s_MapMarkerEntityData.useMarkerTransform = false
        s_MapMarkerEntityData.isVisible = true
        s_MapMarkerEntityData.snap = false
        s_MapMarkerEntityData.showAirTargetBox = true
        s_MapMarkerEntityData.isFocusPoint = true
        s_MapMarkerEntityData.indexInBlueprint = 1
        s_MapMarkerEntityData.isEventConnectionTarget = 2
        s_MapMarkerEntityData.isPropertyConnectionTarget = 3
    
        local s_SpatialPrefabBlueprint = SpatialPrefabBlueprint()
        s_SpatialPrefabBlueprint.needNetworkId = true
        s_SpatialPrefabBlueprint.interfaceHasConnections = false
        s_SpatialPrefabBlueprint.alwaysCreateEntityBusClient = true
        s_SpatialPrefabBlueprint.alwaysCreateEntityBusServer = true
        s_SpatialPrefabBlueprint.objects:add(s_PickupEntityData)
        s_SpatialPrefabBlueprint.objects:add(s_MapMarkerEntityData)

        m_ConnectionHelper:AddEventConnection(s_SpatialPrefabBlueprint, s_PickupEntityData, s_MapMarkerEntityData, 'OnPickup', 'HideMarker', 3)

        p_Registry.blueprintRegistry:add(s_SpatialPrefabBlueprint)
        p_Registry.entityRegistry:add(s_PickupEntityData)
        p_Registry.entityRegistry:add(s_MapMarkerEntityData)

        self.m_PickupBlueprints[l_Tier] = s_SpatialPrefabBlueprint
    end
end

if g_LootCreation == nil then
	g_LootCreation = LootCreation()
end

return g_LootCreation