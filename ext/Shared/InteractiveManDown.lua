class "InteractiveManDown"

local m_EventConnections = require "__shared/Utils/Connections/EventConnections"

function InteractiveManDown:__init()
    self.m_NewSoldierEntityDataGuid = MathUtils:RandomGuid()
    self.m_CoopManDownM9Guid = MathUtils:RandomGuid()
end

function InteractiveManDown:RegisterCallbacks()
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
        Guid("9C51D42E-94F9-424A-89D2-CBBCA32F1BCE"), 
        self, self.OnEntityInteractionComponentData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
        Guid("705967EE-66D3-4440-88B9-FEEF77F53E77"), 
        self, self.OnVeniceSoldierHealthModuleData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
        Guid("A9FFE6B4-257F-4FE8-A950-B323B50D2112"), 
        self, self.OnSoldierEntityData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("4EF77C47-6512-11E0-9AE6-EF0E747BA479"),
        Guid("B407182A-1C98-13DE-49A3-EE7F7EADFB4D"), 
        self, self.OnReviveCustomizeSoldierData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
        Guid("8B5295FF-8770-4587-B436-1F2E71F97F35"),
        self, self.OnInputRestrictionData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
        Guid("5917C5BE-142C-498F-9EA0-CCC6211746D2"), 
        self, self.OnCollisionData
    )
end


function InteractiveManDown:OnInputRestrictionData(p_Instance)
    p_Instance = InputRestrictionEntityData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.selectWeapon9 = true
    p_Instance.sprint = false
    p_Instance.changeWeapon = false
    p_Instance.zoom = false
end

function InteractiveManDown:OnCollisionData(p_Instance)
    p_Instance = CollisionData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.damageAtVerticalVelocity:add(ValueAtX())
    p_Instance.damageAtVerticalVelocity[#p_Instance.damageAtVerticalVelocity].x = 50
    p_Instance.damageAtVerticalVelocity[#p_Instance.damageAtVerticalVelocity].value = 200
    p_Instance.damageAtVerticalVelocity:add(ValueAtX())
    p_Instance.damageAtVerticalVelocity[#p_Instance.damageAtVerticalVelocity].x = 70
    p_Instance.damageAtVerticalVelocity[#p_Instance.damageAtVerticalVelocity].value = 300
end

-- allow the interaction with soldiers which are in the interactiveManDown state on the EntityInteractionComponentData
function InteractiveManDown:OnEntityInteractionComponentData(p_Instance)
    p_Instance = EntityInteractionComponentData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.allowInteractionWithSoldiers = true
end

-- enable the interactiveManDown state and disable the stand and crouch pose
-- also disable the immortalTimeAfterSpawn and edit the healthpoints 
function InteractiveManDown:OnVeniceSoldierHealthModuleData(p_Instance)
    p_Instance = VeniceSoldierHealthModuleData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.interactiveManDown = true
    PoseConstraintsData(p_Instance.interactiveManDownPoseConstraints).standPose = false
    PoseConstraintsData(p_Instance.interactiveManDownPoseConstraints).crouchPose = false
    p_Instance.manDownStateHealthPoints = 100.0
    p_Instance.interactiveManDownThreshold = 100.0
    p_Instance.timeForCorpse = 1.0
    p_Instance.immortalTimeAfterSpawn = 0.0
    p_Instance.manDownStateTime = 110.0
    p_Instance.regenerationRate = 0.0
    AntRef(SoldierHealthModuleBinding(p_Instance.binding).interactiveManDown).assetId = 357042550
    AntRef(SoldierHealthModuleBinding(p_Instance.binding).revived).assetId = -1
end

function InteractiveManDown:OnReviveCustomizeSoldierData(p_Instance)
    p_Instance = CustomizeSoldierData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.activeSlot = WeaponSlot.WeaponSlot_0
end

function InteractiveManDown:OnSoldierEntityData(p_Instance)
    -- M9 kit for interactiveManDown
    local s_ManDownCustomizeSoldierData = self:CreateManDownCustomizeSoldierData()
    -- CustomizeSoldierEntityData that will use the M9 Kit and connect it to the interactiveManDown
    local s_CustomizeSoldierEntityData = self:CreateManDownCustomizeSoldierEntityData(s_ManDownCustomizeSoldierData)

    local s_BeingInteracted_DelayEntityData = self:CreateDelayEntityData(Guid("ED2D8D65-D942-60BC-20F2-0EE10307F6BC"))
    local s_BeingInteracted_InputRestrictionEntityData = self:CreateBeingInteractedInputRestrictionEntityData()

    local s_EntityInteractionComponentData = EntityInteractionComponentData(
                                                 ResourceManager:FindInstanceByGuid(
                                                     Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
                                                     Guid("9C51D42E-94F9-424A-89D2-CBBCA32F1BCE")))
													 
	local s_SoldierInteraction_DelayEntityData = self:CreateDelayEntityData(Guid("2854112F-E1D2-7BBE-D809-7315794B5271"))
    local s_SoldierInteraction_InputRestrictionEntityData = self:CreateSoldierInterationInputRestrictionEntityData()

    -- Create EventSplitterEntities for custom events
    local s_EventSplitterEntityDataStart = EventSplitterEntityData(Guid('34130787-22C3-0F9D-6AA7-4BC214FA1734'))
	s_EventSplitterEntityDataStart.isEventConnectionTarget = 2
	s_EventSplitterEntityDataStart.isPropertyConnectionTarget = 3
	s_EventSplitterEntityDataStart.runOnce = false
	s_EventSplitterEntityDataStart.realm = Realm.Realm_Client
	
	local s_EventSplitterEntityDataFinish = EventSplitterEntityData(Guid('D0F06E9A-AE8B-E614-F8C3-54A47CF22565'))
	s_EventSplitterEntityDataFinish.isEventConnectionTarget = 2
	s_EventSplitterEntityDataFinish.isPropertyConnectionTarget = 3
	s_EventSplitterEntityDataFinish.runOnce = false
	s_EventSplitterEntityDataFinish.realm = Realm.Realm_Client

    -- create EventConnection so it is connected to interactiveManDown
    p_Instance = SoldierEntityData(p_Instance)
    p_Instance:MakeWritable()

    -- changing Max Health to 200hp
    p_Instance.maxHealth = 200

    local s_ManDownConnection = m_EventConnections:Create(p_Instance, s_CustomizeSoldierEntityData, -563307660,
                                                               206074481, 3)
    local s_BeingInteractedStartedImpulseConnection = m_EventConnections:Create(p_Instance, s_EventSplitterEntityDataStart, -1741104687,
                                                               1723395486, 2)
	local s_BeingInteractedCancelledImpulseConnection = m_EventConnections:Create(p_Instance, s_EventSplitterEntityDataFinish, -1025749669,
                                                               1723395486, 2)
	local s_BeingInteractedFinishedImpulseConnection = m_EventConnections:Create(p_Instance, s_EventSplitterEntityDataFinish, 1957374978,
                                                               1723395486, 2)
    -- being interacted inputrestriction
    local s_BeingInteractedStartedInputRestrictionConnection = m_EventConnections:Create(p_Instance, s_BeingInteracted_InputRestrictionEntityData, -1741104687,
                                                               -559281700, 3)
	local s_BeingInteractedCancelledInputRestrictionConnection = m_EventConnections:Create(p_Instance, s_BeingInteracted_InputRestrictionEntityData, -1025749669,
                                                               1928776733, 3)
	local s_BeingInteractedFinishedDelayConnection = m_EventConnections:Create(p_Instance, s_BeingInteracted_DelayEntityData, 1957374978,
                                                               5862146, 3)
	local s_BeingInteractedDelayToInputRestrictionConnection = m_EventConnections:Create(s_BeingInteracted_DelayEntityData, s_BeingInteracted_InputRestrictionEntityData, 193453899,
                                                               1928776733, 3)
    -- being interacted inputrestriction
    local s_SoldierInteractionStartedInputRestrictionConnection = m_EventConnections:Create(s_EntityInteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, 1783953429,
                                                                -559281700, 3)
    local s_SoldierInteractionCancelledInputRestrictionConnection = m_EventConnections:Create(s_EntityInteractionComponentData, s_SoldierInteraction_InputRestrictionEntityData, -1947428449,
                                                                1928776733, 3)
    local s_SoldierInteractionFinishedDelayConnection = m_EventConnections:Create(s_EntityInteractionComponentData, s_SoldierInteraction_DelayEntityData, -1956653754,
                                                                5862146, 3)
    local s_SoldierInteractionDelayToInputRestrictionConnection = m_EventConnections:Create(s_SoldierInteraction_DelayEntityData, s_SoldierInteraction_InputRestrictionEntityData, 193453899,
                                                                1928776733, 3)

    -- Region add all created to the MPSoldier and Registry of the game
    p_Instance.components:add(s_CustomizeSoldierEntityData)
	p_Instance.components:add(s_EventSplitterEntityDataStart)
	p_Instance.components:add(s_EventSplitterEntityDataFinish)
	p_Instance.components:add(s_BeingInteracted_InputRestrictionEntityData)
	p_Instance.components:add(s_BeingInteracted_DelayEntityData)
	p_Instance.components:add(s_SoldierInteraction_InputRestrictionEntityData)
	p_Instance.components:add(s_SoldierInteraction_DelayEntityData)

    local s_SoldierBlueprint = SoldierBlueprint(ResourceManager:FindInstanceByGuid(
                                                    Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
                                                    Guid("261E43BF-259B-41D2-BF3B-9AE4DDA96AD2")))
    s_SoldierBlueprint:MakeWritable()

    for i = #s_SoldierBlueprint.eventConnections, 1, -1 do
        if s_SoldierBlueprint.eventConnections[i].source:Is("SoldierEntityData") and
            s_SoldierBlueprint.eventConnections[i].target:Is("PlayerFilterEntityData") then
            -- Remove revive sound connection 
            -- Should be looked over again, some PlayerFilterEntityData connections might be useful
            s_SoldierBlueprint.eventConnections:erase(i)
        elseif s_SoldierBlueprint.eventConnections[i].target.instanceGuid ==
            Guid("9DF212F6-73C1-4218-9110-2090EE95F730") then
            -- Remove revive paindamage connection
            s_SoldierBlueprint.eventConnections:erase(i)
        elseif s_SoldierBlueprint.eventConnections[i].source:Is("SoldierEntityData") and
            s_SoldierBlueprint.eventConnections[i].target.instanceGuid == Guid("8B5295FF-8770-4587-B436-1F2E71F97F35") then
            -- Remove inputrestriction
            if s_SoldierBlueprint.eventConnections[i].sourceEvent.id == 901651067 then -- (OnRevived)
                s_SoldierBlueprint.eventConnections[i].targetEvent.id = 1928776733 -- (Deactivate)

            elseif s_SoldierBlueprint.eventConnections[i].sourceEvent.id == 2030068478 then -- (OnReviveAccepted)
                s_SoldierBlueprint.eventConnections[i].sourceEvent.id = -563307660 -- (OnManDown)
                s_SoldierBlueprint.eventConnections[i].targetEvent.id = -559281700 -- (Activate)
            else
                s_SoldierBlueprint.eventConnections:erase(i)
            end
        end
    end

    for i = #s_SoldierBlueprint.propertyConnections, 1, -1 do
        if s_SoldierBlueprint.propertyConnections[i].source.instanceGuid == Guid("9DF212F6-73C1-4218-9110-2090EE95F730") or
            s_SoldierBlueprint.propertyConnections[i].target.instanceGuid ==
            Guid("9DF212F6-73C1-4218-9110-2090EE95F730") then
            -- Remove floathub paindamage connection
            s_SoldierBlueprint.propertyConnections:erase(i)

        end
    end

    s_SoldierBlueprint.eventConnections:add(s_ManDownConnection) -- add connection that equips the m9 kit when you go mandown
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedStartedImpulseConnection)
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedCancelledImpulseConnection)
    s_SoldierBlueprint.eventConnections:add(s_BeingInteractedFinishedImpulseConnection)
    -- being interacted inputrestriction
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedStartedInputRestrictionConnection)
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedCancelledInputRestrictionConnection)
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedFinishedDelayConnection)
	s_SoldierBlueprint.eventConnections:add(s_BeingInteractedDelayToInputRestrictionConnection)
	s_SoldierBlueprint.eventConnections:add(s_SoldierInteractionStartedInputRestrictionConnection)
	s_SoldierBlueprint.eventConnections:add(s_SoldierInteractionCancelledInputRestrictionConnection)
	s_SoldierBlueprint.eventConnections:add(s_SoldierInteractionFinishedDelayConnection)
	s_SoldierBlueprint.eventConnections:add(s_SoldierInteractionDelayToInputRestrictionConnection)

    -- this causes crashes for unknown reasons but also it's not needed
    local s_Partition = DatabasePartition((ResourceManager:FindPartitionForInstance(p_Instance)))
    --s_Partition:AddInstance(s_CustomizeSoldierEntityData) -- add entitydata to the s_Partition
	--s_Partition:AddInstance(s_EventSplitterEntityDataStart)
    --s_Partition:AddInstance(s_EventSplitterEntityDataFinish)
    --s_Partition:AddInstance(s_BeingInteracted_InputRestrictionEntityData)
	--s_Partition:AddInstance(s_BeingInteracted_DelayEntityData)
    --s_Partition:AddInstance(s_SoldierInteraction_InputRestrictionEntityData)
	--s_Partition:AddInstance(s_SoldierInteraction_DelayEntityData)

    local registry = RegistryContainer()
    registry.referenceObjectRegistry:add(s_CustomizeSoldierEntityData) -- add entityData to registry
	registry.entityRegistry:add(s_EventSplitterEntityDataStart)
	registry.entityRegistry:add(s_EventSplitterEntityDataFinish)
	registry.entityRegistry:add(s_BeingInteracted_InputRestrictionEntityData)
	registry.entityRegistry:add(s_BeingInteracted_DelayEntityData)
	registry.entityRegistry:add(s_SoldierInteraction_InputRestrictionEntityData)
	registry.entityRegistry:add(s_SoldierInteraction_DelayEntityData)
    ResourceManager:AddRegistry(registry, ResourceCompartment.ResourceCompartment_Game)

    -- Add connections between EntityInteractionComponentData and InterfaceDescriptionData
    -- OnSoldierInteraction-Finished, -Started, -Cancelled
    -- OnInteractionStarted, -Stopped

    local s_InterfaceDescriptorData = InterfaceDescriptorData(
                                          ResourceManager:FindInstanceByGuid(
                                              Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"),
                                              Guid("9C158C06-AFDA-4CE5-8323-F41D356B2971")))

    local onSoldierInteractionFinishedConnection = m_EventConnections:Create(s_EntityInteractionComponentData,
                                                                                  s_InterfaceDescriptorData,
                                                                                  -1956653754, -1956653754, 3)
    local onSoldierInteractionStarted = m_EventConnections:Create(s_EntityInteractionComponentData,
                                                                       s_InterfaceDescriptorData, 1783953429,
                                                                       1783953429, 3)
    local onSoldierInteractionCancelled = m_EventConnections:Create(s_EntityInteractionComponentData,
                                                                         s_InterfaceDescriptorData, -1947428449,
                                                                         -1947428449, 3)
    local onInteractionStopped = m_EventConnections:Create(s_EntityInteractionComponentData,
                                                                s_InterfaceDescriptorData, 1565407255, 1565407255, 3)
    local onInteractionStarted = m_EventConnections:Create(s_EntityInteractionComponentData,
                                                                s_InterfaceDescriptorData, 1572599007, 1572599007, 3)
    s_SoldierBlueprint.eventConnections:add(onSoldierInteractionFinishedConnection)
    s_SoldierBlueprint.eventConnections:add(onSoldierInteractionStarted)
    s_SoldierBlueprint.eventConnections:add(onSoldierInteractionCancelled)
    s_SoldierBlueprint.eventConnections:add(onInteractionStopped)
    s_SoldierBlueprint.eventConnections:add(onInteractionStarted)

    -- add dynamicEvent outputs to interfaceDescriptorData
    s_InterfaceDescriptorData:MakeWritable()
    local dynamicEvent = DynamicEvent()
    dynamicEvent.id = -1956653754
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = 1783953429
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = -1947428449
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = 1565407255
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = 1572599007
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)

    -- Add connections between SoldierEntityData and InterfaceDescriptionData
    -- OnBeingInteractedStarted, -Cancelled, -Finished
    local onBeingInteractedStarted = m_EventConnections:Create(p_Instance, s_InterfaceDescriptorData, -1741104687,
                                                                    -1741104687, 3)
    local onBeingInteractedCancelled = m_EventConnections:Create(p_Instance, s_InterfaceDescriptorData,
                                                                      -1025749669, -1025749669, 3)
    local onBeingInteractedFinished = m_EventConnections:Create(p_Instance, s_InterfaceDescriptorData, 1957374978,
                                                                     1957374978, 3)
    local onBeingInteractedFinishedToReviveConnection = m_EventConnections:Create(p_Instance, p_Instance,
                                                                                       1957374978, -1001523010, 3)

    dynamicEvent.id = -1741104687
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = -1025749669
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)
    dynamicEvent.id = 1957374978
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)

    s_SoldierBlueprint.eventConnections:add(onBeingInteractedStarted)
    s_SoldierBlueprint.eventConnections:add(onBeingInteractedCancelled)
    s_SoldierBlueprint.eventConnections:add(onBeingInteractedFinished)
    s_SoldierBlueprint.eventConnections:add(onBeingInteractedFinishedToReviveConnection)
    -- EventSpec(s_SoldierBlueprint.eventConnections[213].targetEvent).id = 2089008817
    EventSpec(s_SoldierBlueprint.eventConnections[3].targetEvent).id = 2008897511
    -- add onRevived eventconnection between SoldierEntityData and InterfaceDescriptionData
    local onRevived = m_EventConnections:Create(p_Instance, s_InterfaceDescriptorData, 901651067, 901651067, 3)

    dynamicEvent.id = 901651067
    s_InterfaceDescriptorData.outputEvents:add(dynamicEvent)

    s_SoldierBlueprint.eventConnections:add(onRevived)
end

-- TODO: Add Input Restriction with Soldier:HealthAction on client

function InteractiveManDown:CreateManDownCustomizeSoldierData()
    local s_CoopManDownSoldierData = CustomizeSoldierData(self.m_CoopManDownM9Guid)
    s_CoopManDownSoldierData.restoreToOriginalVisualState = false
    s_CoopManDownSoldierData.clearVisualState = false
    s_CoopManDownSoldierData.overrideMaxHealth = -1.0
    s_CoopManDownSoldierData.overrideCriticalHealthThreshold = -1.0

    --[[
    local s_UnlockWeaponAndSlot = UnlockWeaponAndSlot()
    s_UnlockWeaponAndSlot.weapon = SoldierWeaponUnlockAsset(ResourceManager:FindInstanceByGuid(
                                                                Guid("7C58AA2F-DCF2-4206-8880-E32497C15218"),
                                                                Guid("B145A444-BC4D-48BF-806A-0CEFA0EC231B")))
    s_UnlockWeaponAndSlot.slot = WeaponSlot.WeaponSlot_9

    s_CoopManDownSoldierData.weapons:add(s_UnlockWeaponAndSlot)
    ]]
    s_CoopManDownSoldierData.activeSlot = WeaponSlot.WeaponSlot_9
    s_CoopManDownSoldierData.removeAllExistingWeapons = false
    s_CoopManDownSoldierData.disableDeathPickup = false

    return s_CoopManDownSoldierData
end

function InteractiveManDown:CreateManDownCustomizeSoldierEntityData(p_CustomizeSoldierData)
    local s_CoopManDownSoldierEntityData = CustomizeSoldierEntityData(self.m_NewSoldierEntityDataGuid)
    s_CoopManDownSoldierEntityData.isEventConnectionTarget = 1
    s_CoopManDownSoldierEntityData.isPropertyConnectionTarget = 3
    s_CoopManDownSoldierEntityData.realm = Realm.Realm_Server
    s_CoopManDownSoldierEntityData.customizeSoldierData = p_CustomizeSoldierData

    return s_CoopManDownSoldierEntityData
end

function InteractiveManDown:CreateDelayEntityData(p_Guid)
    local s_DelayEntityData = DelayEntityData(p_Guid)
	s_DelayEntityData.delay = 0.3
	s_DelayEntityData.realm = Realm.Realm_Server
	s_DelayEntityData.autoStart = false
	s_DelayEntityData.runOnce = false
	s_DelayEntityData.removeDuplicateEvents = false
	s_DelayEntityData.isEventConnectionTarget = 1
	s_DelayEntityData.isPropertyConnectionTarget = 3

    return s_DelayEntityData
end

function InteractiveManDown:CreateBeingInteractedInputRestrictionEntityData()
    local s_InputRestrictionEntityData = InputRestrictionEntityData(Guid('4FFD99D0-3E9B-2A8F-967E-3A0724A06BA7'))
	s_InputRestrictionEntityData.overridePreviousInputRestriction = true
	s_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
	s_InputRestrictionEntityData.throttle = false
	s_InputRestrictionEntityData.strafe = false
	s_InputRestrictionEntityData.brake = false
	s_InputRestrictionEntityData.handBrake = false
	s_InputRestrictionEntityData.clutch = false
	s_InputRestrictionEntityData.yaw = true
	s_InputRestrictionEntityData.pitch = true
	s_InputRestrictionEntityData.roll = true
	s_InputRestrictionEntityData.fire = true
	s_InputRestrictionEntityData.fireCountermeasure = false
	s_InputRestrictionEntityData.altFire = false
	s_InputRestrictionEntityData.cycleRadioChannel = false
	s_InputRestrictionEntityData.selectMeleeWeapon = false
	s_InputRestrictionEntityData.zoom = false
	s_InputRestrictionEntityData.jump = false
	s_InputRestrictionEntityData.changeVehicle = false
	s_InputRestrictionEntityData.changeEntry = false
	s_InputRestrictionEntityData.changePose = false
	s_InputRestrictionEntityData.toggleParachute = false
	s_InputRestrictionEntityData.changeWeapon = false
	s_InputRestrictionEntityData.reload = true
	s_InputRestrictionEntityData.toggleCamera = false
	s_InputRestrictionEntityData.sprint = false
	s_InputRestrictionEntityData.scoreboardMenu = true
	s_InputRestrictionEntityData.mapZoom = false
	s_InputRestrictionEntityData.gearUp = false
	s_InputRestrictionEntityData.gearDown = false
	s_InputRestrictionEntityData.threeDimensionalMap = false
	s_InputRestrictionEntityData.giveOrder = false
	s_InputRestrictionEntityData.prone = false
	s_InputRestrictionEntityData.switchPrimaryInventory = true
	s_InputRestrictionEntityData.switchPrimaryWeapon = true
	s_InputRestrictionEntityData.grenadeLauncher = true
	s_InputRestrictionEntityData.staticGadget = true
	s_InputRestrictionEntityData.dynamicGadget1 = true
	s_InputRestrictionEntityData.dynamicGadget2 = true
	s_InputRestrictionEntityData.meleeAttack = true
	s_InputRestrictionEntityData.throwGrenade = true
	s_InputRestrictionEntityData.selectWeapon1 = true
	s_InputRestrictionEntityData.selectWeapon2 = true
	s_InputRestrictionEntityData.selectWeapon3 = true
	s_InputRestrictionEntityData.selectWeapon4 = true
	s_InputRestrictionEntityData.selectWeapon5 = true
	s_InputRestrictionEntityData.selectWeapon6 = true
	s_InputRestrictionEntityData.selectWeapon7 = true
	s_InputRestrictionEntityData.selectWeapon8 = true
	s_InputRestrictionEntityData.selectWeapon9 = true
	s_InputRestrictionEntityData.enabled = true
	s_InputRestrictionEntityData.runtimeComponentCount = 0
	s_InputRestrictionEntityData.transform = LinearTransform(Vec3(1.000000, 0.000000, 0.000000), Vec3(0.000000, 1.000000, 0.000000), Vec3(0.000000, 0.000000, 1.000000), Vec3(0.000000, 0.000000, 0.000000))
	s_InputRestrictionEntityData.isEventConnectionTarget = 1
    s_InputRestrictionEntityData.isPropertyConnectionTarget = 3
    
    return s_InputRestrictionEntityData
end

function InteractiveManDown:CreateSoldierInterationInputRestrictionEntityData()
    s_InputRestrictionEntityData = InputRestrictionEntityData(Guid('3A0724A0-2A8F-3E9B-6BA7-4FFD99D0967E'))
    s_InputRestrictionEntityData.overridePreviousInputRestriction = true
    s_InputRestrictionEntityData.applyRestrictionsToSpecificPlayer = true
    s_InputRestrictionEntityData.throttle = false
    s_InputRestrictionEntityData.strafe = false
    s_InputRestrictionEntityData.brake = false
    s_InputRestrictionEntityData.handBrake = false
    s_InputRestrictionEntityData.clutch = false
    s_InputRestrictionEntityData.yaw = false
    s_InputRestrictionEntityData.pitch = false
    s_InputRestrictionEntityData.roll = false
    s_InputRestrictionEntityData.fire = false
    s_InputRestrictionEntityData.fireCountermeasure = false
    s_InputRestrictionEntityData.altFire = false
    s_InputRestrictionEntityData.cycleRadioChannel = false
    s_InputRestrictionEntityData.selectMeleeWeapon = false
    s_InputRestrictionEntityData.zoom = false
    s_InputRestrictionEntityData.jump = false
    s_InputRestrictionEntityData.changeVehicle = false
    s_InputRestrictionEntityData.changeEntry = false
    s_InputRestrictionEntityData.changePose = false
    s_InputRestrictionEntityData.toggleParachute = false
    s_InputRestrictionEntityData.changeWeapon = false
    s_InputRestrictionEntityData.reload = false
    s_InputRestrictionEntityData.toggleCamera = false
    s_InputRestrictionEntityData.sprint = false
    s_InputRestrictionEntityData.scoreboardMenu = true
    s_InputRestrictionEntityData.mapZoom = false
    s_InputRestrictionEntityData.gearUp = false
    s_InputRestrictionEntityData.gearDown = false
    s_InputRestrictionEntityData.threeDimensionalMap = false
    s_InputRestrictionEntityData.giveOrder = false
    s_InputRestrictionEntityData.prone = false
    s_InputRestrictionEntityData.switchPrimaryInventory = true
    s_InputRestrictionEntityData.switchPrimaryWeapon = true
    s_InputRestrictionEntityData.grenadeLauncher = true
    s_InputRestrictionEntityData.staticGadget = true
    s_InputRestrictionEntityData.dynamicGadget1 = true
    s_InputRestrictionEntityData.dynamicGadget2 = true
    s_InputRestrictionEntityData.meleeAttack = true
    s_InputRestrictionEntityData.throwGrenade = true
    s_InputRestrictionEntityData.selectWeapon1 = true
    s_InputRestrictionEntityData.selectWeapon2 = true
    s_InputRestrictionEntityData.selectWeapon3 = true
    s_InputRestrictionEntityData.selectWeapon4 = true
    s_InputRestrictionEntityData.selectWeapon5 = true
    s_InputRestrictionEntityData.selectWeapon6 = true
    s_InputRestrictionEntityData.selectWeapon7 = true
    s_InputRestrictionEntityData.selectWeapon8 = true
    s_InputRestrictionEntityData.selectWeapon9 = true
    s_InputRestrictionEntityData.enabled = true
    s_InputRestrictionEntityData.runtimeComponentCount = 0
    s_InputRestrictionEntityData.transform = LinearTransform(Vec3(1.000000, 0.000000, 0.000000), Vec3(0.000000, 1.000000, 0.000000), Vec3(0.000000, 0.000000, 1.000000), Vec3(0.000000, 0.000000, 0.000000))
    s_InputRestrictionEntityData.isEventConnectionTarget = 1
    s_InputRestrictionEntityData.isPropertyConnectionTarget = 3

    return s_InputRestrictionEntityData
end

if g_InteractiveManDown == nil then
    g_InteractiveManDown = InteractiveManDown()
end

return g_InteractiveManDown
