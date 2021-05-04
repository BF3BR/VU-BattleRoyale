class "WeaponDropModifier"

local m_LootBoxRigid = DC(Guid('2A3E4EB5-DE56-11DD-AE2C-D53D253AEF63'), Guid('3EDE3952-DE56-11DD-AE2C-D53D253AEF63'))

local m_Logger = Logger("WeaponDropModifier", true)

function WeaponDropModifier:RegisterCallbacks()
	m_LootBoxRigid:RegisterLoadHandler(self, self.OnLootBoxRigid)
end

-- =============================================
-- Events
-- =============================================

function WeaponDropModifier:OnRegisterEntityResources()
	local s_Blueprint = self:CreateBlueprint()
	local s_WorldPartData = WorldPartData(ResourceManager:SearchForInstanceByGuid(MapsConfig[LevelNameHelper:GetLevelName()].ConquestGameplayGuid))
	s_WorldPartData:MakeWritable()
	local s_Registry = RegistryContainer()
	for i = 100, 1, -1 do
		local s_ParentRepresentative = self:AddGameInteractionEntityData(s_Blueprint, i)
		s_WorldPartData.objects:add(s_ParentRepresentative)
		s_Registry.referenceObjectRegistry:add(s_ParentRepresentative)
	end
	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

-- =============================================
-- Callbacks
-- =============================================

-- Replace vanilla DropWeaponComponentData (drops a kit) with 5 DropWeaponComponentDatas that all drop a weapon
function WeaponDropModifier:OnSoldierBlueprintLoaded(p_SoldierBlueprint)

	-- Update runtimeComponentCount (the client will crash if this is wrong), erasing 1 component
	local s_SoldierEntityData = SoldierEntityData(p_SoldierBlueprint.object)
	s_SoldierEntityData:MakeWritable()
	s_SoldierEntityData.runtimeComponentCount = s_SoldierEntityData.runtimeComponentCount - 1

	local s_SoldierBodyComponent = SoldierBodyComponentData(s_SoldierEntityData.components[1])
	s_SoldierBodyComponent:MakeWritable()
	-- Erase the kit DropWeaponComponent
	s_SoldierBodyComponent.components:erase(11)

	m_Logger:Write("WeaponDropComponents removed from SoldierBlueprint")
end

function WeaponDropModifier:OnLootBoxRigid(p_Instance)
	p_Instance = RigidBodyData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.motionType = RigidBodyMotionType.RigidBodyMotionType_Fixed
end

-- =============================================
-- Functions
-- =============================================

function WeaponDropModifier:AddGameInteractionEntityData(p_Blueprint, i)
	local s_ParentRepresentative = ReferenceObjectData(MathUtils:RandomGuid())
	s_ParentRepresentative.blueprintTransform = LinearTransform()
	s_ParentRepresentative.blueprint = p_Blueprint
	s_ParentRepresentative.streamRealm = StreamRealm.StreamRealm_None
	s_ParentRepresentative.castSunShadowEnable = true
	s_ParentRepresentative.excluded = false
	s_ParentRepresentative.isEventConnectionTarget = 3
	s_ParentRepresentative.isPropertyConnectionTarget = 3
	s_ParentRepresentative.indexInBlueprint = 5555 + i

	return s_ParentRepresentative
end

function WeaponDropModifier:CreateBlueprint()
	local s_GameInteractionEntityData = GameInteractionEntityData(Guid('07E16744-D9BC-DC08-E2CC-D64E52D5CE0F'))
	s_GameInteractionEntityData.useWithinRadius = 3.0
	s_GameInteractionEntityData.useWithinAngle = 360
	s_GameInteractionEntityData.testIfOccluded = false
	s_GameInteractionEntityData.maxUses = 0
	s_GameInteractionEntityData.allowInteractionViaRemoteEntry = false
	s_GameInteractionEntityData.delayBetweenUses = 0.1
	s_GameInteractionEntityData.teamId = TeamId.TeamNeutral
	s_GameInteractionEntityData.inputAction = EntryInputActionEnum.EIAInteract
	s_GameInteractionEntityData.holdToInteractTime = 0.0
	s_GameInteractionEntityData.interactionEntityType = InteractionEntityType.IET_None
	s_GameInteractionEntityData.interactionSid = "TO LOOT"
	s_GameInteractionEntityData.nameSid = " "
	s_GameInteractionEntityData.interactionVerticalOffset = 0.0
	s_GameInteractionEntityData.friendlyTextSid = "PICKUP LOOT"
	s_GameInteractionEntityData.enemyTextSid =  "PICKUP LOOT"
	s_GameInteractionEntityData.shrinkSnap = false
	s_GameInteractionEntityData.showAsCapturePoint = false
	s_GameInteractionEntityData.capturepointVerticalOffset = 0.2
	s_GameInteractionEntityData.isEventConnectionTarget = 2
	s_GameInteractionEntityData.isPropertyConnectionTarget = 3
	s_GameInteractionEntityData.indexInBlueprint = 0
	s_GameInteractionEntityData.transform = LinearTransform()

	local s_EventSplitterEntityData_OnInteraction = EventSplitterEntityData(Guid('1E1023F4-EACC-7E35-048B-58B3D32D51D0'))
	s_EventSplitterEntityData_OnInteraction.realm = Realm.Realm_ClientAndServer
	s_EventSplitterEntityData_OnInteraction.runOnce = false
	s_EventSplitterEntityData_OnInteraction.isEventConnectionTarget = 2
	s_EventSplitterEntityData_OnInteraction.isPropertyConnectionTarget = 3
	s_EventSplitterEntityData_OnInteraction.indexInBlueprint = 1

	local s_EventSplitterEntityData_OnInteractionInitiated = EventSplitterEntityData(Guid('9AB700BA-94F7-DBF6-362C-607316DC0C31'))
	s_EventSplitterEntityData_OnInteractionInitiated.realm = Realm.Realm_ClientAndServer
	s_EventSplitterEntityData_OnInteractionInitiated.runOnce = false
	s_EventSplitterEntityData_OnInteractionInitiated.isEventConnectionTarget = 0
	s_EventSplitterEntityData_OnInteractionInitiated.isPropertyConnectionTarget = 3
	s_EventSplitterEntityData_OnInteractionInitiated.indexInBlueprint = 2

	local s_EventSplitterEntityData_OnInteractionInterrupted = EventSplitterEntityData(Guid('0B8E9A4F-4E38-BE79-3EEA-B050909565B6'))
	s_EventSplitterEntityData_OnInteractionInterrupted.realm = Realm.Realm_ClientAndServer
	s_EventSplitterEntityData_OnInteractionInterrupted.runOnce = false
	s_EventSplitterEntityData_OnInteractionInterrupted.isEventConnectionTarget = 0
	s_EventSplitterEntityData_OnInteractionInterrupted.isPropertyConnectionTarget = 3
	s_EventSplitterEntityData_OnInteractionInterrupted.indexInBlueprint = 3

	local s_EventConnection_OnInteraction = EventConnection()
	s_EventConnection_OnInteraction.source = s_GameInteractionEntityData
	s_EventConnection_OnInteraction.target = s_EventSplitterEntityData_OnInteraction
	EventSpec(s_EventConnection_OnInteraction.sourceEvent).id = MathUtils:FNVHash("OnInteraction")
	EventSpec(s_EventConnection_OnInteraction.targetEvent).id = MathUtils:FNVHash("Impulse")
	s_EventConnection_OnInteraction.targetType = EventConnectionTargetType.EventConnectionTargetType_NetworkedClientAndServer

	local s_EventConnection_OnInteractionInitiated = EventConnection()
	s_EventConnection_OnInteractionInitiated.source = s_GameInteractionEntityData
	s_EventConnection_OnInteractionInitiated.target = s_EventSplitterEntityData_OnInteractionInitiated
	EventSpec(s_EventConnection_OnInteractionInitiated.sourceEvent).id = MathUtils:FNVHash("OnInteractionInitiated")
	EventSpec(s_EventConnection_OnInteractionInitiated.targetEvent).id = MathUtils:FNVHash("Impulse")
	s_EventConnection_OnInteractionInitiated.targetType = EventConnectionTargetType.EventConnectionTargetType_NetworkedClientAndServer

	local s_EventConnection_OnInteractionInterrupted = EventConnection()
	s_EventConnection_OnInteractionInterrupted.source = s_GameInteractionEntityData
	s_EventConnection_OnInteractionInterrupted.target = s_EventSplitterEntityData_OnInteractionInterrupted
	EventSpec(s_EventConnection_OnInteractionInterrupted.sourceEvent).id = MathUtils:FNVHash("OnInteractionInterrupted")
	EventSpec(s_EventConnection_OnInteractionInterrupted.targetEvent).id = MathUtils:FNVHash("Impulse")
	s_EventConnection_OnInteractionInterrupted.targetType = EventConnectionTargetType.EventConnectionTargetType_NetworkedClientAndServer

	local s_Blueprint = SpatialPrefabBlueprint(Guid('D5430E64-CA34-6AC5-8279-C2263C4D2E5A'))
	s_Blueprint.needNetworkId = true
	s_Blueprint.interfaceHasConnections = false
	s_Blueprint.alwaysCreateEntityBusClient = true
	s_Blueprint.alwaysCreateEntityBusServer = true
	s_Blueprint.objects:add(s_GameInteractionEntityData)
	s_Blueprint.objects:add(s_EventSplitterEntityData_OnInteraction)
	s_Blueprint.objects:add(s_EventSplitterEntityData_OnInteractionInitiated)
	s_Blueprint.objects:add(s_EventSplitterEntityData_OnInteractionInterrupted)
	s_Blueprint.eventConnections:add(s_EventConnection_OnInteraction)
	s_Blueprint.eventConnections:add(s_EventConnection_OnInteractionInitiated)
	s_Blueprint.eventConnections:add(s_EventConnection_OnInteractionInterrupted)

	local s_Registry = RegistryContainer()
	s_Registry.entityRegistry:add(s_GameInteractionEntityData)
	s_Registry.entityRegistry:add(s_EventSplitterEntityData_OnInteraction)
	s_Registry.entityRegistry:add(s_EventSplitterEntityData_OnInteractionInitiated)
	s_Registry.entityRegistry:add(s_EventSplitterEntityData_OnInteractionInterrupted)
	s_Registry.blueprintRegistry:add(s_Blueprint)

	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)

	return s_Blueprint
end

if g_WeaponDropModifier == nil then
	g_WeaponDropModifier = WeaponDropModifier()
end

return g_WeaponDropModifier
