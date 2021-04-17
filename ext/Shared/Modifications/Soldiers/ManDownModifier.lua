class "ManDownModifier"

local m_Logger = Logger("ManDownModifier", true)
local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"
local m_RegistryManager = require("__shared/Logic/RegistryManager")

local m_ReviveCustomizeSoldierData = DC(Guid("4EF77C47-6512-11E0-9AE6-EF0E747BA479"), Guid("B407182A-1C98-13DE-49A3-EE7F7EADFB4D"))
local m_M9UnlockAsset = DC(Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"), Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B"))

local m_BeingInteracted_Inputs = { 
    "throttle", 
	"strafe", 
	"brake", 
	"handBrake", 
	"clutch", 
	"fireCountermeasure", 
	"altFire", 
	"cycleRadioChannel", 
	"selectMeleeWeapon", 
	"zoom", 
	"jump", 
	"changeVehicle", 
	"changeEntry", 
	"changePose", 
	"toggleParachute", 
	"changeWeapon", 
	"toggleCamera", 
	"sprint", 
	"mapZoom", 
	"gearUp", 
	"gearDown", 
	"threeDimensionalMap", 
	"giveOrder", 
	"prone" 
}

local m_SoldierInteraction_Inputs = {
    "throttle", 
    "strafe", 
    "brake", 
    "handBrake", 
    "clutch", 
    "yaw", 
    "pitch", 
    "roll", 
    "fire", 
    "fireCountermeasure", 
    "altFire", 
    "cycleRadioChannel", 
    "selectMeleeWeapon", 
    "zoom", 
    "jump", 
    "changeVehicle", 
    "changeEntry", 
    "changePose", 
    "toggleParachute", 
    "changeWeapon", 
    "reload", 
    "toggleCamera", 
    "sprint", 
    "mapZoom", 
    "gearUp", 
    "gearDown", 
    "threeDimensionalMap", 
    "giveOrder", 
    "prone"
}

function ManDownModifier:__init()

end

function ManDownModifier:RegisterCallbacks()
    m_ReviveCustomizeSoldierData:RegisterLoadHandler(self, self.OnReviveCustomizeSoldierData)
end

function ManDownModifier:OnReviveCustomizeSoldierData(p_CustomizeSoldierData)
    p_CustomizeSoldierData.activeSlot = WeaponSlot.WeaponSlot_0
end

function ManDownModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
    local s_Partition = p_SoldierBlueprint.partition
    local s_Registry = m_RegistryManager:GetRegistry()

    -- Might be better to hardcode this with an index map
    for i = #p_SoldierBlueprint.eventConnections, 1, -1 do
        if p_SoldierBlueprint.eventConnections[i].source:Is("SoldierEntityData") then
            if p_SoldierBlueprint.eventConnections[i].target:Is("PlayerFilterEntityData") then
                -- Remove revive sound connection 
                -- Should be looked over again, some PlayerFilterEntityData connections might be useful
                p_SoldierBlueprint.eventConnections:erase(i)
            elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("9DF212F6-73C1-4218-9110-2090EE95F730") then
                if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 901651067 then      -- (OnRevived)
                    p_SoldierBlueprint.eventConnections[i].sourceEvent.id = -563307660          -- (OnManDown)
                elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == -563307660 then -- (OnManDown)
                    p_SoldierBlueprint.eventConnections:erase(i)
                end
            elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("48117724-9949-43B4-BFE8-5F7D9492D1EF") then
                if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 901651067 then      -- (OnRevived)
                    p_SoldierBlueprint.eventConnections[i].sourceEvent.id = -563307660          -- (OnManDown)
                elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 2030068478 then -- (OnReviveAccepted)
                    p_SoldierBlueprint.eventConnections[i].sourceEvent.id = 901651067           -- (OnRevived)
                end
            elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("AD9FBC60-3ADE-42C4-80FB-647F3DD251C6")
            and p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 901651067 then         -- (OnRevived)
                p_SoldierBlueprint.eventConnections[i].sourceEvent.id = -563307660              -- (OnManDown)
            elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("8B5295FF-8770-4587-B436-1F2E71F97F35") then
                -- Adjust inputrestriction
                if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 901651067 then      -- (OnRevived)
                    p_SoldierBlueprint.eventConnections[i].targetEvent.id = 1928776733          -- (Deactivate)
                elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == 2030068478 then -- (OnReviveAccepted)
                    p_SoldierBlueprint.eventConnections[i].sourceEvent.id = -563307660          -- (OnManDown)
                    p_SoldierBlueprint.eventConnections[i].targetEvent.id = -559281700          -- (Activate)
                else
                    p_SoldierBlueprint.eventConnections:erase(i)
                end
            elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("7D3F4B44-9E51-444C-A5D7-9D33928A35C5")
            and p_SoldierBlueprint.eventConnections[i].sourceEvent.id == -563307660 then        -- (OnManDown)
                -- Leave the damage screen when going mandown
                p_SoldierBlueprint.eventConnections:erase(i)
            end
        end
    end

    p_SoldierBlueprint.eventConnections[3].targetEvent.id = 2008897511

    -- M9 kit for ManDownModifier
    local s_CustomizeSoldierData = self:CreateManDownCustomizeSoldierData()

    local s_CustomizeSoldierEntityData = CustomizeSoldierEntityData()
    s_CustomizeSoldierEntityData.isEventConnectionTarget = Realm.Realm_Server
    s_CustomizeSoldierEntityData.isPropertyConnectionTarget = Realm.Realm_None
    s_CustomizeSoldierEntityData.realm = Realm.Realm_Server
    s_CustomizeSoldierEntityData.customizeSoldierData = s_CustomizeSoldierData
    s_Registry.entityRegistry:add(s_CustomizeSoldierEntityData)

    -- Create EventSplitterEntities for custom events
    local s_StartEventSplitterEntityData = EventSplitterEntityData(Guid("34130787-22C3-0F9D-6AA7-4BC214FA1734"))
	s_StartEventSplitterEntityData.isEventConnectionTarget = 2
	s_StartEventSplitterEntityData.isPropertyConnectionTarget = 3
	s_StartEventSplitterEntityData.runOnce = false
	s_StartEventSplitterEntityData.realm = Realm.Realm_Client
    s_Registry.entityRegistry:add(s_StartEventSplitterEntityData)

	local s_FinishEventSplitterEntityData = EventSplitterEntityData(Guid("D0F06E9A-AE8B-E614-F8C3-54A47CF22565"))
	s_FinishEventSplitterEntityData.isEventConnectionTarget = 2
	s_FinishEventSplitterEntityData.isPropertyConnectionTarget = 3
	s_FinishEventSplitterEntityData.runOnce = false
	s_FinishEventSplitterEntityData.realm = Realm.Realm_Client
    s_Registry.entityRegistry:add(s_FinishEventSplitterEntityData)

    -- BeingInteracted 
    local s_BeingInteracted_InputRestrictionEntityData = self:_GetInputRestrictionData(m_BeingInteracted_Inputs, Guid("4FFD99D0-3E9B-2A8F-967E-3A0724A06BA7"))
    s_BeingInteracted_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
    s_BeingInteracted_InputRestrictionEntityData.isEventConnectionTarget = 1
    s_Registry.entityRegistry:add(s_BeingInteracted_InputRestrictionEntityData)

    local s_BeingInteracted_DelayEntityData = DelayEntityData(Guid("ED2D8D65-D942-60BC-20F2-0EE10307F6BC"))
	s_BeingInteracted_DelayEntityData.delay = 0.3
	s_BeingInteracted_DelayEntityData.realm = Realm.Realm_Server
	s_BeingInteracted_DelayEntityData.autoStart = false
	s_BeingInteracted_DelayEntityData.runOnce = false
	s_BeingInteracted_DelayEntityData.removeDuplicateEvents = false
	s_BeingInteracted_DelayEntityData.isEventConnectionTarget = 1
	s_BeingInteracted_DelayEntityData.isPropertyConnectionTarget = 3
    s_Registry.entityRegistry:add(s_BeingInteracted_DelayEntityData)

    -- SoldierInteraction
    local s_SoldierInteraction_InputRestrictionEntityData = self:_GetInputRestrictionData(m_SoldierInteraction_Inputs, Guid("3A0724A0-2A8F-3E9B-6BA7-4FFD99D0967E"))
    s_SoldierInteraction_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
    s_SoldierInteraction_InputRestrictionEntityData.isEventConnectionTarget = 1
    s_Registry.entityRegistry:add(s_SoldierInteraction_InputRestrictionEntityData)

    local s_SoldierInteraction_DelayEntityData = DelayEntityData(s_BeingInteracted_DelayEntityData:Clone(Guid("2854112F-E1D2-7BBE-D809-7315794B5271")))
    s_Registry.entityRegistry:add(s_SoldierInteraction_DelayEntityData)
    
    -- Add custom EntityData to SoldierEntity components
    local s_SoldierEntityData = SoldierEntityData(p_SoldierBlueprint.object)
    s_SoldierEntityData:MakeWritable()
    s_SoldierEntityData.maxHealth = 200
    s_SoldierEntityData.components:add(s_CustomizeSoldierEntityData)
    s_SoldierEntityData.components:add(s_StartEventSplitterEntityData)
    s_SoldierEntityData.components:add(s_FinishEventSplitterEntityData)
    s_SoldierEntityData.components:add(s_BeingInteracted_InputRestrictionEntityData)
	s_SoldierEntityData.components:add(s_BeingInteracted_DelayEntityData)
	s_SoldierEntityData.components:add(s_SoldierInteraction_InputRestrictionEntityData)
	s_SoldierEntityData.components:add(s_SoldierInteraction_DelayEntityData)

    local s_InteractionComponentData = EntityInteractionComponentData(s_Partition:FindInstance(Guid("9C51D42E-94F9-424A-89D2-CBBCA32F1BCE")))
    s_InteractionComponentData:MakeWritable()
    s_InteractionComponentData.allowInteractionWithSoldiers = true

    local s_InterfaceDescriptorData = InterfaceDescriptorData(s_Partition:FindInstance(Guid("9C158C06-AFDA-4CE5-8323-F41D356B2971")))
    s_InterfaceDescriptorData:MakeWritable()
    
    -- Add dynamicEvent outputs to InterfaceDescriptorData
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(-1956653754))  -- OnSoldierInteractionFinished
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(1783953429))   -- OnSoldierInteractionStarted
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(-1947428449))  -- OnSoldierInteractionCancelled
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(1565407255))   -- OnInteractionStopped
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(1572599007))   -- OnInteractionStarted
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(-1741104687))  -- OnBeingInteractedStarted
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(-1025749669))  -- OnBeingInteractedCancelled
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(1957374978))   -- OnBeingInteractedFinished
    s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(901651067))    -- OnRevived
                                
    -- Add connections between EntityInteractionComponentData and InterfaceDescriptionData
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, -1956653754, -1956653754, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, 1783953429, 1783953429, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, -1947428449, -1947428449, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, 1565407255, 1565407255, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, 1572599007, 1572599007, 3)

    -- Add connections between SoldierEntityData and InterfaceDescriptionData
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, -1741104687, -1741104687, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, -1025749669, -1025749669, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, 1957374978, 1957374978, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, 1957374978, -1001523010, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, 901651067, 901651067, 3)

    -- Add connections between SoldierEntityData and the custom EventSplitterEntityDatas
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_EventSplitterEntityDataStart, -1741104687, 1723395486, 2)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_EventSplitterEntityDataFinish, -1025749669, 1723395486, 2)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_EventSplitterEntityDataFinish, 1957374978, 1723395486, 2)

    -- BeingInteracted inputrestriction
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_InputRestrictionEntityData, -1741104687, -559281700, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_InputRestrictionEntityData, -1025749669, 1928776733, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_DelayEntityData, 1957374978, 5862146, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_BeingInteracted_DelayEntityData, s_BeingInteracted_InputRestrictionEntityData, 193453899, 1928776733, 3)

    -- SoldierInteraction inputrestriction
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, 1783953429, -559281700, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, -1947428449, 1928776733, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_DelayEntityData, -1956653754, 5862146, 3)
    m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierInteraction_DelayEntityData, s_SoldierInteraction_InputRestrictionEntityData, 193453899, 1928776733, 3)

    -- TODO: Add Input Restriction with Soldier:HealthAction on client
    local s_InputRestrictionEntityData = InputRestrictionEntityData(s_Partition:FindInstance(Guid("8B5295FF-8770-4587-B436-1F2E71F97F35")))
    s_InputRestrictionEntityData:MakeWritable()
    s_InputRestrictionEntityData.selectWeapon9 = true
    s_InputRestrictionEntityData.sprint = false
    s_InputRestrictionEntityData.changeWeapon = false
    s_InputRestrictionEntityData.zoom = false

    local s_CollisionData = CollisionData(s_Partition:FindInstance(Guid("5917C5BE-142C-498F-9EA0-CCC6211746D2")))
    s_CollisionData:MakeWritable()
    s_CollisionData.damageAtVerticalVelocity:add(ValueAtX())
    s_CollisionData.damageAtVerticalVelocity[#s_CollisionData.damageAtVerticalVelocity].x = 50
    s_CollisionData.damageAtVerticalVelocity[#s_CollisionData.damageAtVerticalVelocity].value = 200
    s_CollisionData.damageAtVerticalVelocity:add(ValueAtX())
    s_CollisionData.damageAtVerticalVelocity[#s_CollisionData.damageAtVerticalVelocity].x = 70
    s_CollisionData.damageAtVerticalVelocity[#s_CollisionData.damageAtVerticalVelocity].value = 300
  
    local s_VeniceSoldierHealthModuleData = VeniceSoldierHealthModuleData(s_Partition:FindInstance(Guid("705967EE-66D3-4440-88B9-FEEF77F53E77")))
    s_VeniceSoldierHealthModuleData:MakeWritable()
    s_VeniceSoldierHealthModuleData.interactiveManDown = true
    s_VeniceSoldierHealthModuleData.interactiveManDownThreshold = 100.0
    s_VeniceSoldierHealthModuleData.interactiveManDownPoseConstraints.standPose = false
    s_VeniceSoldierHealthModuleData.interactiveManDownPoseConstraints.crouchPose = false
    s_VeniceSoldierHealthModuleData.manDownStateHealthPoints = 100.0
    s_VeniceSoldierHealthModuleData.manDownStateTime = 110.0
    s_VeniceSoldierHealthModuleData.timeForCorpse = 1.0
    s_VeniceSoldierHealthModuleData.immortalTimeAfterSpawn = 0.0
    s_VeniceSoldierHealthModuleData.regenerationRate = 0.0
    s_VeniceSoldierHealthModuleData.binding.interactiveManDown.assetId = 357042550
    s_VeniceSoldierHealthModuleData.binding.revived.assetId = -1

    m_Logger:Write("ManDown state modified")
end

function ManDownModifier:_GetDynamicEvent(p_EventId)
    local s_DynamicEvent = DynamicEvent()
    s_DynamicEvent.id = p_EventId

    return s_DynamicEvent
end

function ManDownModifier:_GetInputRestrictionData(p_FieldsToDisable, p_Guid)
    local s_InputRestrictionEntityData = InputRestrictionEntityData(p_Guid)

    for _, l_Field in ipairs(p_FieldsToDisable) do
        s_InputRestrictionEntityData[l_Field] = false
    end

    return s_InputRestrictionEntityData
end

function ManDownModifier:CreateManDownCustomizeSoldierData()
    -- TODO: check default values
    local s_CoopManDownSoldierData = CustomizeSoldierData()
    s_CoopManDownSoldierData.restoreToOriginalVisualState = false
    s_CoopManDownSoldierData.clearVisualState = false
    s_CoopManDownSoldierData.overrideMaxHealth = -1.0
    s_CoopManDownSoldierData.overrideCriticalHealthThreshold = -1.0
    s_CoopManDownSoldierData.activeSlot = WeaponSlot.WeaponSlot_9
    s_CoopManDownSoldierData.removeAllExistingWeapons = false
    s_CoopManDownSoldierData.disableDeathPickup = false

    return s_CoopManDownSoldierData
end

if g_ManDownModifier == nil then
    g_ManDownModifier = ManDownModifier()
end

return g_ManDownModifier
