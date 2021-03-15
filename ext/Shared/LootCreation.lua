class "LootCreation"

require "__shared/Enums/CustomEvents"

local m_ConnectionHelper = require("__shared/Utils/ConnectionHelper")

local m_MedkitFiringData = FrostbiteDC{
    partitionGuid = Guid('B54E9BDA-1F2E-11E0-8602-946E2AD98284'),
    instanceGuid = Guid('F379D6B0-4592-4DC2-9186-5863D3D69C85'),
}

local m_MedkitHealingData = FrostbiteDC{
    partitionGuid = Guid('1D6061B2-2234-11E0-92F5-C9B649EF6972'),
    instanceGuid = Guid('A867A678-615B-3FA6-7AF5-0DEE6ED69EA0'),
}

local m_AmmobagFiringData = FrostbiteDC{
    partitionGuid = Guid('0343F80F-06CC-11E0-8BDF-D7443366E28A'),
    instanceGuid = Guid('5B73C5E2-127E-419B-95FB-A69D9F5CAA7B'),
}

local m_AmmobagResupplyData = FrostbiteDC{
    partitionGuid = Guid('04CD683B-1F1B-11E0-BBD1-F7235575FD24'),
    instanceGuid = Guid('4AE515CE-846D-6070-5F56-1285B7E8E187'),
}

function LootCreation:__init()
    self:RegisterEvents()
    self:RegisterVars()
end

function LootCreation:RegisterEvents()
    Events:Subscribe(LMS.RLT, self, self.OnRandomLootTransforms)
    NetEvents:Subscribe(LMS.RLT, self, self.OnRandomLootTransforms)
    
    m_MedkitFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
    m_AmmobagFiringData:RegisterLoadHandler(self, self.DisableAutoReplenish)
    m_MedkitHealingData:RegisterLoadHandler(self, self.SetHealingCapacity)
    m_AmmobagResupplyData:RegisterLoadHandler(self, self.SetResupplyCapacity)
end

function LootCreation:RegisterVars()
    self.m_PickupBlueprints = {} 
    self.m_RandomLootTransforms = {}
end

-- Patching medkit and ammobag
function LootCreation:DisableAutoReplenish(p_Instance)
    local s_FiringData = FiringFunctionData(p_Instance)
    s_FiringData:MakeWritable()
    s_FiringData.ammo.autoReplenishMagazine = false
end

function LootCreation:SetHealingCapacity(p_Instance)
    local s_HealingData = SupplySphereEntityData(p_Instance)
    s_HealingData:MakeWritable()
    s_HealingData.supplyData.healing.infiniteCapacity = false
    s_HealingData.supplyData.healing.supplyPointsCapacity = PickupsConfig.MedkitCapacity
end

function LootCreation:SetResupplyCapacity(p_Instance)
    local s_ResupplyData = SupplySphereEntityData(p_Instance)
    s_ResupplyData:MakeWritable()
    s_ResupplyData.supplyData.ammo.infiniteCapacity = false
    s_ResupplyData.supplyData.ammo.supplyPointsCapacity = PickupsConfig.AmmobagCapacity
end

-- Loot Creation
function LootCreation:OnRandomLootTransforms(p_Transforms)
    self.m_RandomLootTransforms = p_Transforms
    print("[LootCreation] Received loot transforms")
end

function LootCreation:OnWorldPartLoaded(p_WorldPartData, p_Registry)
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
        if l_Tier == 1 then
            goto skip_tier
        end

        local s_UseWeaponMesh = l_TierConfig.Mesh == nil

        local s_PickupEntityData = WeaponUnlockPickupEntityData()
        s_PickupEntityData.transform = l_TierConfig.MeshTransform or PickupsConfig.WeaponTransform
        s_PickupEntityData.interactionRadius = PickupsConfig.InteractionRadius
        s_PickupEntityData.useWeaponMesh = s_UseWeaponMesh
        s_PickupEntityData.mesh = (not s_UseWeaponMesh and l_TierConfig.Mesh:GetInstance()) or nil
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
        s_PickupEntityData.allowPickup = true
        s_PickupEntityData.contentIsStatic = true
        s_PickupEntityData.positionIsStatic = true
        s_PickupEntityData.ignoreNullWeaponSlots = false
        s_PickupEntityData.replaceAllContent = false
        s_PickupEntityData.removeWeaponOnDrop = false
        s_PickupEntityData.sendPlayerInEventOnPickup = true
        s_PickupEntityData.indexInBlueprint = 0
        s_PickupEntityData.isEventConnectionTarget = 2
        s_PickupEntityData.isPropertyConnectionTarget = 1
        
        for _, l_Weapon in pairs(l_TierConfig.Weapons) do
            local s_Attachments = l_Weapon.Attachments or { g_Attachments.NoOptics }

            for _,l_Attachment in pairs(s_Attachments) do
                s_PickupEntityData.weapons:add(WeaponUnlockPickupData())
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.weapon = l_Weapon.Type.Unlock:GetInstance()
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.slot = l_TierConfig.Slots[1]
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].altWeaponSlot = l_TierConfig.Slots[2]
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].linkedToWeaponSlot = -1
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].minAmmo = l_Weapon.Ammo
                s_PickupEntityData.weapons[#s_PickupEntityData.weapons].maxAmmo = l_Weapon.Ammo
                if l_Weapon.Type.Attachments[l_Attachment] ~= nil then
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.unlockAssets:add(l_Weapon.Type.Attachments[l_Attachment]:GetInstance())
                end
                if l_Attachment.Type ~= AttachmentType.Optic and l_Weapon.Type.Attachments[g_Attachments.NoOptics] ~= nil then
                    s_PickupEntityData.weapons[#s_PickupEntityData.weapons].unlockWeaponAndSlot.unlockAssets:add(l_Weapon.Type.Attachments[g_Attachments.NoOptics]:GetInstance())
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

        ::skip_tier::
    end
end

if g_LootCreation == nil then
	g_LootCreation = LootCreation()
end

return g_LootCreation
