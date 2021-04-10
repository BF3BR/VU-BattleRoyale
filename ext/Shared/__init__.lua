class "VuBattleRoyaleShared"

require "__shared/Configs/ServerConfig"
require "__shared/Utils/Logger"
require "__shared/Utils/EventRouter"
require "__shared/Utils/LevelNameHelper"
require "__shared/Configs/MapsConfig"
require "__shared/Enums/AttachmentTypes"
require "__shared/Types/FrostbiteDC"
require "__shared/Weapons/Attachments"
require "__shared/Weapons/Weapons"
require "__shared/Weapons/Gadgets"
require "__shared/Configs/PickupsConfig"
-- local m_Logger = Logger("VuBattleRoyaleShared", true)
local m_DropWeapons = require "__shared/DropWeapons"
local m_LootCreation = require "__shared/LootCreation"
local m_InteractiveManDown = require "__shared/InteractiveManDown"

function VuBattleRoyaleShared:__init()
    Events:Subscribe("Extension:Loaded", self, self.OnExtensionLoaded)
end

function VuBattleRoyaleShared:OnExtensionLoaded()
    self:RegisterEvents()
    self:RegisterCallbacks()
    self:RegisterHooks()
end

function VuBattleRoyaleShared:RegisterEvents()
    Events:Subscribe("Level:LoadResources", self, self.OnLevelLoadResources)
    Events:Subscribe("GunSway:Update", self, self.OnGunSwayUpdate)
end

function VuBattleRoyaleShared:RegisterCallbacks()
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("6C0D021C-80D8-4BDE-85F7-CDF6231F95D5"),
        Guid("DA506D40-69C7-4670-BB8B-25EDC9F1A526"),
        self, self.OnWorldPartLoaded
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"),
        Guid("B3AF5AF0-4703-402C-A238-601E610A0B48"), 
        self, self.OnPreRoundEntityData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"),
        Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95"), 
        self, self.OnDisableCamerasOnUnspawn
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("B6CDC48A-3A8C-11E0-843A-AC0656909BCB"),
        Guid("F21FB5EA-D7A6-EE7E-DDA2-C776D604CD2E"), 
        self, self.OnMeleeEntityCommonData
    )
    
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("8A1B5CE5-A537-49C6-9C44-0DA048162C94"),
        Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D"),
       self, self.OnVehiclesWorldPartData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"),
        Guid("584D7B54-FBFE-4755-8AD4-89065EEB45C3"),
       self, self.OnInAirStateData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"),
        Guid("6F1DD196-9B9C-4538-B128-71BC14835652"),
       self, self.OnFreeFallCharacterStatePoseInfo
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"),
        Guid("CC8C3596-EEC5-4959-A644-8E5D5677CE15"),
       self, self.OnFreeFallCharacterStatePoseInfo
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("235CD1DA-8B06-4A7F-94BE-D50DA2D077CE"),
        Guid("64357471-E246-4FCD-B0EF-6F693FA98D71"),
       self, self.OnFreeFallCharacterStatePoseInfo
    )
    
    ResourceManager:RegisterInstanceLoadHandler(
        Guid("9942F328-35C1-11DF-9556-FDADABD0ADCC"), 
        Guid("FE76DD4D-CA25-2382-1ACB-40117A0AC957"), 
        self, self.OnSoldierWeaponSwitchingData
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("C4DCACFF-ED8F-BC87-F647-0BC8ACE0D9B4"),
        Guid("AD413546-DEAF-8115-B89C-D666E801C67A"),
        self, self.OnGameModeSettings
    )

    ResourceManager:RegisterInstanceLoadHandler(
        Guid("19631E31-2E3A-432B-8929-FB57BAA7D28E"),
        Guid("B4BB6CFA-0E53-45F9-B190-1287DCC093A9"),
        self, self.OnTeamEntityData
    )

    m_InteractiveManDown:RegisterCallbacks()
    m_DropWeapons:RegisterCallbacks()
end

function VuBattleRoyaleShared:RegisterHooks()
    Hooks:Install("ResourceManager:LoadBundles", 100, self, self.OnResourceManagerLoadBundles)
end

-- =============================================
-- Events
-- =============================================

function VuBattleRoyaleShared:OnGunSwayUpdate(p_GunSway, p_Weapon, p_WeaponFiring, p_DeltaTime)
    -- fix Aimglitch
    if p_GunSway.dispersionAngle < p_GunSway.minDispersionAngle then
        p_GunSway.dispersionAngle = p_GunSway.minDispersionAngle
    end
end

function VuBattleRoyaleShared:OnWorldPartLoaded(p_Instance)
    local s_CustomWorldPartData = WorldPartData()

    local s_WorldPartReferenceObjectData = WorldPartReferenceObjectData(p_Instance)
    s_WorldPartReferenceObjectData:MakeWritable()
    s_WorldPartReferenceObjectData.blueprint = s_CustomWorldPartData

    local s_Registry = RegistryContainer()
    s_Registry.blueprintRegistry:add(s_CustomWorldPartData)

    m_LootCreation:OnWorldPartLoaded(s_CustomWorldPartData, s_Registry)

    ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

function VuBattleRoyaleShared:OnVehiclesWorldPartData(p_Instance)
    -- Remove / exclude all the vehicles from the map
    -- TODO: Probably need to fix this for other maps!!
    p_Instance = WorldPartData(p_Instance)
    for i, l_Object in pairs(p_Instance.objects) do
        if l_Object:Is("ReferenceObjectData") then
            l_Object = ReferenceObjectData(l_Object)
            if l_Object.blueprint.instanceGuid ~= Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95") and
                l_Object.blueprint.instanceGuid ~= Guid("B57E136A-0E4D-4952-8823-98A20DFE8F44") then
                l_Object:MakeWritable()
                l_Object.excluded = true
            end
        end
    end
end

function VuBattleRoyaleShared:OnInAirStateData(p_Instance)
    -- Change the free fall velocity so free fall state kicks in earlier
    p_Instance = InAirStateData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.freeFallVelocity = 14.0
end

function VuBattleRoyaleShared:OnFreeFallCharacterStatePoseInfo(p_Instance)
    -- Modify the free fall velocity
    p_Instance = CharacterStatePoseInfo(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.velocity = 40.0
    p_Instance.accelerationGain = 0.35
end

function VuBattleRoyaleShared:OnPreRoundEntityData(p_Instance)
    -- Disables the pre-round entity
    p_Instance = PreRoundEntityData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.enabled = false
end

function VuBattleRoyaleShared:OnDisableCamerasOnUnspawn(p_Instance)
    -- Disables the default HQ / spawn cameras
    p_Instance = SpatialPrefabBlueprint(p_Instance)
    p_Instance:MakeWritable()
    for i = #p_Instance.eventConnections, 1, -1 do
        if p_Instance.eventConnections[i].source:Is("HumanPlayerEntityData") then
            if EventSpec(p_Instance.eventConnections[i].sourceEvent).id == 273719920 and
                p_Instance.eventConnections[i].target:Is("LogicReferenceObjectData") then -- (OnPlayerDeathTimeout)
                p_Instance.eventConnections:erase(i)
            end
            if p_Instance.eventConnections[i].target.instanceGuid == Guid("38B766CB-020E-4254-B220-7F69F33A7FEA") then
                p_Instance.eventConnections:erase(i)
            end
        end
    end
end

function VuBattleRoyaleShared:OnMeleeEntityCommonData(p_Instance)
    -- Disable canned knife animation
    p_Instance = MeleeEntityCommonData(p_Instance)
    p_Instance:MakeWritable()
    p_Instance.meleeAttackDistance = 0
    p_Instance.maxAttackHeightDifference = 0
end

function VuBattleRoyaleShared:OnSoldierWeaponSwitchingData(p_Instance)
    p_Instance = SoldierWeaponSwitchingData(p_Instance)
    p_Instance:MakeWritable()
    -- add EIASwitchPrimaryWeapon from Slot0 to Slot9 if there is no weapon in Slot1
    p_Instance.switchMap[1].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot1 to Slot9 if there is no weapon in Slot0
    p_Instance.switchMap[7].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- add EIASwitchPrimaryWeapon from Slot2 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[13].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
	-- add EIASwitchPrimaryWeapon from Slot3 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[19].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
	-- add EIASwitchPrimaryWeapon from Slot4 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[25].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
	-- add EIASwitchPrimaryWeapon from Slot5 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[31].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
	-- add EIASwitchPrimaryWeapon from Slot6 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[37].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
	-- add EIASwitchPrimaryWeapon from Slot7 to Slot9 if there is no weapon in Slot0 and Slot1
	p_Instance.switchMap[43].toWeapon:add(WeaponSwitchingEnum.wsSlot9)
    -- EIASwitchPrimaryWeapon from Slot8 to Slot0 or Slot1
    p_Instance.switchMap:add(WeaponSwitchingMapData())
    p_Instance.switchMap[#p_Instance.switchMap].fromWeapon = WeaponSwitchingEnum.wsSlot8
    p_Instance.switchMap[#p_Instance.switchMap].action = EntryInputActionEnum.EIASwitchPrimaryWeapon
    p_Instance.switchMap[#p_Instance.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot0)
    p_Instance.switchMap[#p_Instance.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot1)
    p_Instance.switchMap[#p_Instance.switchMap].fireAndSwitchBackToPrev = false
    -- EIASwitchPrimaryWeapon from Slot9 to Slot0 or Slot1
    p_Instance.switchMap:add(WeaponSwitchingMapData())
    p_Instance.switchMap[#p_Instance.switchMap].fromWeapon = WeaponSwitchingEnum.wsSlot9
    p_Instance.switchMap[#p_Instance.switchMap].action = EntryInputActionEnum.EIASwitchPrimaryWeapon
    p_Instance.switchMap[#p_Instance.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot0)
    p_Instance.switchMap[#p_Instance.switchMap].toWeapon:add(WeaponSwitchingEnum.wsSlot1)
    p_Instance.switchMap[#p_Instance.switchMap].fireAndSwitchBackToPrev = false
end

function VuBattleRoyaleShared:OnLevelLoadResources()
    ResourceManager:MountSuperBundle("spchunks")
    ResourceManager:MountSuperBundle("levels/coop_010/coop_010")
end

function VuBattleRoyaleShared:OnGameModeSettings(p_Instance)
    local settings = GameModeSettings(p_Instance)
    settings:MakeWritable()
    local s_GameModeTeamSize = GameModeTeamSize()
    s_GameModeTeamSize.playerCount = 127
    s_GameModeTeamSize.squadSize = 4
    for i=1, 14 do
        settings.information[1].sizes[3].teams:add(s_GameModeTeamSize)
    end
end

function VuBattleRoyaleShared:OnTeamEntityData(p_Instance)
    for i=3, 16, 1 do
        local s_NewTeamId = TeamEntityData(MathUtils:RandomGuid())
        s_NewTeamId.isEventConnectionTarget = 3
        s_NewTeamId.isPropertyConnectionTarget  = 3
        s_NewTeamId.indexInBlueprint = i
        s_NewTeamId.team = TeamData(p_Instance)
        s_NewTeamId.id = i

        local s_LogicPrefabBlueprint = LogicPrefabBlueprint(
            ResourceManager:FindInstanceByGuid(
                Guid("466C8E5C-BD29-11E0-923F-C41005FFB7BD"),
                Guid("D0DB1029-9313-7D6D-BBA9-9C8F92C0040B")
            )
        )
        s_LogicPrefabBlueprint:MakeWritable()
        s_LogicPrefabBlueprint.objects:add(s_NewTeamId)
        s_LogicPrefabBlueprint.partition:AddInstance(s_NewTeamId)
    end
end

-- =============================================
-- Hooks
-- =============================================

function VuBattleRoyaleShared:OnResourceManagerLoadBundles(p_HookCtx, p_Bundles, p_Compartment)
    if #p_Bundles == 1 and p_Bundles[1] == SharedUtils:GetLevelName() then
        p_Bundles = {
            "levels/coop_010/coop_010",
            p_Bundles[1]
        }
        p_HookCtx:Pass(p_Bundles, p_Compartment)
    end
end

return VuBattleRoyaleShared()
