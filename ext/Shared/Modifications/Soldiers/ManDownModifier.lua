class "ManDownModifier"

local m_Logger = Logger("ManDownModifier", true)
local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"
local m_RegistryManager = require("__shared/Logic/RegistryManager")

local m_ReviveCustomizeSoldierData = DC(Guid("4EF77C47-6512-11E0-9AE6-EF0E747BA479"), Guid("B407182A-1C98-13DE-49A3-EE7F7EADFB4D"))
local m_M9UnlockAsset = DC(Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"), Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B"))
local m_M9FiringFunctionData = DC(Guid("94D0FEE8-E685-11DF-805B-F4FA4757ED08"), Guid("4CDDA2E9-C167-4F81-9958-835EAC8C65D7"))

local m_AimingConstraints = DC(Guid("0309271B-3E7A-11E0-8B89-BBAF7A9E99DB"), Guid("922C1DF4-0208-0A6D-2651-7EEA9A13C468"))

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

function ManDownModifier:RegisterCallbacks()
	m_ReviveCustomizeSoldierData:RegisterLoadHandler(self, self.OnReviveCustomizeSoldierData)
	m_AimingConstraints:RegisterLoadHandler(self, self.OnAimingConstraintsData)
	m_M9FiringFunctionData:RegisterLoadHandler(self, self.OnM9FiringFunctionData)
end

function ManDownModifier:DeregisterCallbacks()
	m_ReviveCustomizeSoldierData:Deregister()
	m_AimingConstraints:Deregister()
	m_M9FiringFunctionData:Deregister()
end

function ManDownModifier:OnReviveCustomizeSoldierData(p_CustomizeSoldierData)
	p_CustomizeSoldierData.activeSlot = WeaponSlot.WeaponSlot_0
end

function ManDownModifier:OnAimingConstraintsData(p_AimingConstraintEntityCommonData)
	p_AimingConstraintEntityCommonData.aimingConstraints.minPitch = -15.0
end

function ManDownModifier:OnM9FiringFunctionData(p_FiringFunctionData)
	p_FiringFunctionData.ammo.magazineCapacity = 0
	p_FiringFunctionData.ammo.numberOfMagazines = 0
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
				if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnRevived") then
					p_SoldierBlueprint.eventConnections[i].sourceEvent.id = MathUtils:FNVHash("OnManDown")
				elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnManDown") then
					p_SoldierBlueprint.eventConnections:erase(i)
				end
			elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("48117724-9949-43B4-BFE8-5F7D9492D1EF") then
				if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnRevived") then
					p_SoldierBlueprint.eventConnections[i].sourceEvent.id = MathUtils:FNVHash("OnManDown")
				elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnReviveAccepted") then
					p_SoldierBlueprint.eventConnections[i].sourceEvent.id = MathUtils:FNVHash("OnRevived")
				end
			elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("AD9FBC60-3ADE-42C4-80FB-647F3DD251C6")
			and p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnRevived") then
				p_SoldierBlueprint.eventConnections[i].sourceEvent.id = MathUtils:FNVHash("OnManDown")
			elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("8B5295FF-8770-4587-B436-1F2E71F97F35") then
				-- Adjust inputrestriction
				if p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnRevived") then
					p_SoldierBlueprint.eventConnections[i].targetEvent.id = MathUtils:FNVHash("Deactivate")
				elseif p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnReviveAccepted") then
					p_SoldierBlueprint.eventConnections[i].sourceEvent.id = MathUtils:FNVHash("OnManDown")
					p_SoldierBlueprint.eventConnections[i].targetEvent.id = MathUtils:FNVHash("Activate")
				else
					p_SoldierBlueprint.eventConnections:erase(i)
				end
			elseif p_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("7D3F4B44-9E51-444C-A5D7-9D33928A35C5")
			and p_SoldierBlueprint.eventConnections[i].sourceEvent.id == MathUtils:FNVHash("OnManDown") then
				-- Leave the damage screen when going mandown
				p_SoldierBlueprint.eventConnections:erase(i)
			end
		end
	end

	p_SoldierBlueprint.eventConnections[3].targetEvent.id = MathUtils:FNVHash("OnKilled")

	-- M9 kit for ManDownModifier
	local s_CustomizeSoldierData = self:CreateManDownCustomizeSoldierData()

	local s_CustomizeSoldierEntityData = CustomizeSoldierEntityData(Guid("9A576250-D263-39C2-3ADC-693356004B78"))
	s_CustomizeSoldierEntityData.isEventConnectionTarget = Realm.Realm_Server
	s_CustomizeSoldierEntityData.isPropertyConnectionTarget = Realm.Realm_None
	s_CustomizeSoldierEntityData.realm = Realm.Realm_Server
	s_CustomizeSoldierEntityData.customizeSoldierData = s_CustomizeSoldierData
	s_Registry.entityRegistry:add(s_CustomizeSoldierEntityData)

	-- Create EventSplitterEntities for custom events
	local s_StartEventSplitterEntityData = EventSplitterEntityData(Guid("34130787-22C3-0F9D-6AA7-4BC214FA1734"))
	s_StartEventSplitterEntityData.isEventConnectionTarget = Realm.Realm_ClientAndServer
	s_StartEventSplitterEntityData.isPropertyConnectionTarget = Realm.Realm_None
	s_StartEventSplitterEntityData.runOnce = false
	s_StartEventSplitterEntityData.realm = Realm.Realm_Client
	s_Registry.entityRegistry:add(s_StartEventSplitterEntityData)

	local s_FinishEventSplitterEntityData = EventSplitterEntityData(Guid("D0F06E9A-AE8B-E614-F8C3-54A47CF22565"))
	s_FinishEventSplitterEntityData.isEventConnectionTarget = Realm.Realm_ClientAndServer
	s_FinishEventSplitterEntityData.isPropertyConnectionTarget = Realm.Realm_None
	s_FinishEventSplitterEntityData.runOnce = false
	s_FinishEventSplitterEntityData.realm = Realm.Realm_Client
	s_Registry.entityRegistry:add(s_FinishEventSplitterEntityData)

	-- BeingInteracted
	local s_BeingInteracted_InputRestrictionEntityData = self:_GetInputRestrictionData(m_BeingInteracted_Inputs, Guid("4FFD99D0-3E9B-2A8F-967E-3A0724A06BA7"))
	s_BeingInteracted_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
	s_BeingInteracted_InputRestrictionEntityData.isEventConnectionTarget = Realm.Realm_Server
	s_Registry.entityRegistry:add(s_BeingInteracted_InputRestrictionEntityData)

	local s_BeingInteracted_DelayEntityData = DelayEntityData(Guid("ED2D8D65-D942-60BC-20F2-0EE10307F6BC"))
	s_BeingInteracted_DelayEntityData.delay = 0.3
	s_BeingInteracted_DelayEntityData.realm = Realm.Realm_Server
	s_BeingInteracted_DelayEntityData.autoStart = false
	s_BeingInteracted_DelayEntityData.runOnce = false
	s_BeingInteracted_DelayEntityData.removeDuplicateEvents = false
	s_BeingInteracted_DelayEntityData.isEventConnectionTarget = Realm.Realm_Server
	s_BeingInteracted_DelayEntityData.isPropertyConnectionTarget = Realm.Realm_None
	s_Registry.entityRegistry:add(s_BeingInteracted_DelayEntityData)

	-- SoldierInteraction
	local s_SoldierInteraction_InputRestrictionEntityData = self:_GetInputRestrictionData(m_SoldierInteraction_Inputs, Guid("3A0724A0-2A8F-3E9B-6BA7-4FFD99D0967E"))
	s_SoldierInteraction_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
	s_SoldierInteraction_InputRestrictionEntityData.isEventConnectionTarget = Realm.Realm_Server
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
	s_InteractionComponentData.isEventConnectionTarget = Realm.Realm_ClientAndServer

	local s_InterfaceDescriptorData = InterfaceDescriptorData(s_Partition:FindInstance(Guid("9C158C06-AFDA-4CE5-8323-F41D356B2971")))
	s_InterfaceDescriptorData:MakeWritable()

	-- Add dynamicEvent outputs to InterfaceDescriptorData
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnSoldierInteractionFinished")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnSoldierInteractionStarted")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnSoldierInteractionCancelled")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnInteractionStopped")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnInteractionStarted")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnBeingInteractedStarted")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnBeingInteractedCancelled")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnBeingInteractedFinished")))
	s_InterfaceDescriptorData.outputEvents:add(self:_GetDynamicEvent(MathUtils:FNVHash("OnRevived")))

	-- Add connections between EntityInteractionComponentData and InterfaceDescriptionData
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, "OnSoldierInteractionFinished", "OnSoldierInteractionFinished", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, "OnSoldierInteractionStarted", "OnSoldierInteractionStarted", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, "OnSoldierInteractionCancelled", "OnSoldierInteractionCancelled", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, "OnInteractionStopped", "OnInteractionStopped", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_InterfaceDescriptorData, "OnInteractionStarted", "OnInteractionStarted", 3)

	-- Add connections between SoldierEntityData and InterfaceDescriptionData
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, "OnBeingInteractedStarted", "OnBeingInteractedStarted", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, "OnBeingInteractedCancelled", "OnBeingInteractedCancelled", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, "OnBeingInteractedFinished", "OnBeingInteractedFinished", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_SoldierEntityData, "OnBeingInteractedFinished", "Revive", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_InterfaceDescriptorData, "OnRevived", "OnRevived", 3)

	-- Add connection between SoldierEntityData and CustomizeSoldierEntityData
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_CustomizeSoldierEntityData, "OnManDown", "Apply", 3)

	-- Add connections between SoldierEntityData and the custom EventSplitterEntityDatas
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_StartEventSplitterEntityData, "OnBeingInteractedStarted", "Impulse", 2)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_FinishEventSplitterEntityData, "OnBeingInteractedCancelled", "Impulse", 2)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_FinishEventSplitterEntityData, "OnBeingInteractedFinished", "Impulse", 2)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_StartEventSplitterEntityData, "OnSoldierInteractionStarted", "Impulse", 5)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_FinishEventSplitterEntityData, "OnSoldierInteractionCancelled", "Impulse", 5)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_FinishEventSplitterEntityData, "OnSoldierInteractionFinished", "Impulse", 5)

	-- BeingInteracted inputrestriction
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_InputRestrictionEntityData, "OnBeingInteractedStarted", "Activate", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_InputRestrictionEntityData, "OnBeingInteractedCancelled", "Deactivate", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierEntityData, s_BeingInteracted_DelayEntityData, "OnBeingInteractedFinished", "In", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_BeingInteracted_DelayEntityData, s_BeingInteracted_InputRestrictionEntityData, "Out", "Deactivate", 3)

	-- SoldierInteraction inputrestriction
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, "OnSoldierInteractionStarted", "Activate", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, "OnSoldierInteractionCancelled", "Deactivate", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_InteractionComponentData, s_SoldierInteraction_DelayEntityData, "OnSoldierInteractionFinished", "In", 3)
	m_ConnectionHelper:AddEventConnection(p_SoldierBlueprint, s_SoldierInteraction_DelayEntityData, s_SoldierInteraction_InputRestrictionEntityData, "Out", "Deactivate", 3)

	-- TODO: Add Input Restriction with Soldier:HealthAction on client
	local s_InputRestrictionEntityData = InputRestrictionEntityData(s_Partition:FindInstance(Guid("8B5295FF-8770-4587-B436-1F2E71F97F35")))
	s_InputRestrictionEntityData:MakeWritable()
	s_InputRestrictionEntityData.selectWeapon9 = true
	s_InputRestrictionEntityData.sprint = false
	s_InputRestrictionEntityData.changeWeapon = false
	s_InputRestrictionEntityData.zoom = false

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

	local s_SpottingComponentData = SpottingComponentData(s_Partition:FindInstance(Guid("105707CF-F84E-4A93-B18C-A8EDED291CC4")))
	s_SpottingComponentData:MakeWritable()
	s_SpottingComponentData.spottingFov = 1.0
	s_SpottingComponentData.onlyAllowedToHaveOneSpottedPlayer = true
	s_SpottingComponentData.coolDownHistoryTime = 10.0
	s_SpottingComponentData.coolDownAllowedSpotsWithinHistory = 1

	local s_SpottingTargetComponentData = SpottingTargetComponentData(s_Partition:FindInstance(Guid("167E50EE-AAC2-4C58-93C3-55CEA65911D1")))
	s_SpottingTargetComponentData:MakeWritable()
	s_SpottingTargetComponentData.activeSpottedTime = 2.0
	s_SpottingTargetComponentData.passiveSpottedTime = 1.0

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
	local s_CoopManDownSoldierData = CustomizeSoldierData(Guid("951F6BA2-6C36-AE64-38F8-15DB2FE3A7B4"))
	s_CoopManDownSoldierData.restoreToOriginalVisualState = false
	s_CoopManDownSoldierData.clearVisualState = false
	s_CoopManDownSoldierData.overrideMaxHealth = -1.0
	s_CoopManDownSoldierData.overrideCriticalHealthThreshold = -1.0

	local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
	s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(m_M9UnlockAsset:GetInstance())
	s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_9
	s_CoopManDownSoldierData.weapons:add(s_UnlockWeaponAndSlot)

	s_CoopManDownSoldierData.activeSlot = WeaponSlot.WeaponSlot_9
	s_CoopManDownSoldierData.removeAllExistingWeapons = false
	s_CoopManDownSoldierData.disableDeathPickup = false

	return s_CoopManDownSoldierData
end

function ManDownModifier:OnWorldPartLoaded(p_WorldPartData, p_Registry)
	for i = 1, 4 do
		local s_MapMarkerEntityData = MapMarkerEntityData()
		s_MapMarkerEntityData.transform.trans = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.baseTransform = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.sid = "ID_H_MAP_PREFABS_REVIVE_ME"
		s_MapMarkerEntityData.showRadius = 9999
		s_MapMarkerEntityData.hideRadius = 0
		s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_Revive
		s_MapMarkerEntityData.verticalOffset = 1.0
		s_MapMarkerEntityData.focusPointRadius = 0.0
		s_MapMarkerEntityData.useMarkerTransform = false
		s_MapMarkerEntityData.isVisible = true
		s_MapMarkerEntityData.snap = true
		s_MapMarkerEntityData.showAirTargetBox = true
		s_MapMarkerEntityData.isFocusPoint = false
		s_MapMarkerEntityData.indexInBlueprint = 1
		s_MapMarkerEntityData.isEventConnectionTarget = 2
		s_MapMarkerEntityData.isPropertyConnectionTarget = 3

		local s_SpatialPrefabBlueprint = SpatialPrefabBlueprint()
		s_SpatialPrefabBlueprint.needNetworkId = true
		s_SpatialPrefabBlueprint.interfaceHasConnections = false
		s_SpatialPrefabBlueprint.alwaysCreateEntityBusClient = true
		s_SpatialPrefabBlueprint.alwaysCreateEntityBusServer = true
		s_SpatialPrefabBlueprint.objects:add(s_MapMarkerEntityData)

		p_Registry.blueprintRegistry:add(s_SpatialPrefabBlueprint)
		p_Registry.entityRegistry:add(s_MapMarkerEntityData)


		local s_MapMarkerReferenceObjectData = ReferenceObjectData()
		s_MapMarkerReferenceObjectData.blueprint = s_SpatialPrefabBlueprint
		s_MapMarkerReferenceObjectData.blueprintTransform = LinearTransform()
		s_MapMarkerReferenceObjectData.indexInBlueprint = 128 + i

		p_WorldPartData.objects:add(s_MapMarkerReferenceObjectData)

		p_Registry.referenceObjectRegistry:add(s_MapMarkerReferenceObjectData)
	end
	m_Logger:Write("Created mandown mapmarkers")
end

return ManDownModifier()
