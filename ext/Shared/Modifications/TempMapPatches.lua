class "TempMapPatches"

local m_LootCreation = require "__shared/Modifications/LootCreation"
local m_ManDownModifier = require "__shared/Modifications/Soldiers/ManDownModifier"

local m_Logger = Logger("TempMapPatches", true)

local m_XP5_003_Conquest_WorldPartData = DC(Guid("6C0D021C-80D8-4BDE-85F7-CDF6231F95D5"), Guid("DA506D40-69C7-4670-BB8B-25EDC9F1A526"))
local m_Conquest_PreRoundEntityData = DC(Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"), Guid("B3AF5AF0-4703-402C-A238-601E610A0B48"))
local m_Conquest_SpatialPrefabBlueprint = DC(Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"), Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95"))
local m_XP5_003_CQL_WorldPartData = DC(Guid("8A1B5CE5-A537-49C6-9C44-0DA048162C94"), Guid("B795C24B-21CA-4E57-AA32-86BEFDDF471D"))
local m_GameModeSettings = DC(Guid("C4DCACFF-ED8F-BC87-F647-0BC8ACE0D9B4"), Guid("AD413546-DEAF-8115-B89C-D666E801C67A"))
local m_RU_Large_TeamEntityData = DC(Guid("19631E31-2E3A-432B-8929-FB57BAA7D28E"), Guid("B4BB6CFA-0E53-45F9-B190-1287DCC093A9"))
local m_CapturePointPrefab_HQ_US_XP_CameraEntityData = DC(Guid("694A231C-4439-461D-A7FF-764915FC3E7C"), Guid("6B728CD3-EBD2-4D48-BF49-50A7CFAB0A30"))
local m_CapturePointPrefab_HQ_RU_XP_CameraEntityData = DC(Guid("5D4B1096-3089-45A7-9E3A-422E15E0D8F6"), Guid("A4281E60-7557-4BFF-ADD4-18D7E8780873"))

function TempMapPatches:RegisterCallbacks()
	m_XP5_003_Conquest_WorldPartData:RegisterLoadHandler(self, self.OnWorldPartLoaded)
	m_Conquest_PreRoundEntityData:RegisterLoadHandler(self, self.OnPreRoundEntityData)
	m_Conquest_SpatialPrefabBlueprint:RegisterLoadHandler(self, self.OnDisableCamerasOnUnspawn)
	m_XP5_003_CQL_WorldPartData:RegisterLoadHandler(self, self.OnVehiclesWorldPartData)
	m_GameModeSettings:RegisterLoadHandler(self, self.OnGameModeSettings)
	m_RU_Large_TeamEntityData:RegisterLoadHandler(self, self.OnTeamEntityData)
	m_CapturePointPrefab_HQ_US_XP_CameraEntityData:RegisterLoadHandler(self, self.OnCameraEntityData)
	m_CapturePointPrefab_HQ_RU_XP_CameraEntityData:RegisterLoadHandler(self, self.OnCameraEntityData)
end

function TempMapPatches:DeregisterCallbacks()
	m_XP5_003_Conquest_WorldPartData:Deregister()
	m_Conquest_PreRoundEntityData:Deregister()
	m_Conquest_SpatialPrefabBlueprint:Deregister()
	m_XP5_003_CQL_WorldPartData:Deregister()
	m_GameModeSettings:Deregister()
	m_RU_Large_TeamEntityData:Deregister()
	m_CapturePointPrefab_HQ_US_XP_CameraEntityData:Deregister()
	m_CapturePointPrefab_HQ_RU_XP_CameraEntityData:Deregister()
end

function TempMapPatches:OnSoldierBlueprintLoaded(p_SoldierBlueprint)
	-- Add 1 CharacterSpawnReference
	local s_SpatialPrefabBlueprint = SpatialPrefabBlueprint(ResourceManager:SearchForDataContainer("Gameplay/GameModes/Conquest"))
	s_SpatialPrefabBlueprint:MakeWritable()
	local s_Partition = ResourceManager:FindPartitionForInstance(s_SpatialPrefabBlueprint)
	local s_Registry = RegistryContainer()

	local s_CharacterSpawnReferenceObjectData = CharacterSpawnReferenceObjectData(Guid("67A2C146-9CC0-E7EC-5227-B2DCB9D316C1"))
	s_CharacterSpawnReferenceObjectData.team = TeamId.TeamNeutral
	s_CharacterSpawnReferenceObjectData.locationTextSid = "1"
	s_CharacterSpawnReferenceObjectData.locationNameSid = "Spawn 1"
	s_CharacterSpawnReferenceObjectData.blueprint = p_SoldierBlueprint
	s_CharacterSpawnReferenceObjectData.playerType = PlayerSpawnType.PlayerSpawnType_HumanPlayer
	s_CharacterSpawnReferenceObjectData.useAsSpawnPoint = true
	s_CharacterSpawnReferenceObjectData.maxCount = 0
	s_CharacterSpawnReferenceObjectData.takeControlEntryIndex = 1
	s_CharacterSpawnReferenceObjectData.isEventConnectionTarget = 2
	s_CharacterSpawnReferenceObjectData.isPropertyConnectionTarget = 3

	s_SpatialPrefabBlueprint.objects:add(s_CharacterSpawnReferenceObjectData)
	s_Partition:AddInstance(s_CharacterSpawnReferenceObjectData)
	s_Registry.referenceObjectRegistry:add(s_CharacterSpawnReferenceObjectData)

	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

-- TODO: Include in map modification system
function TempMapPatches:OnWorldPartLoaded(p_Instance)
	local s_CustomWorldPartData = WorldPartData()

	local s_WorldPartReferenceObjectData = WorldPartReferenceObjectData(p_Instance)
	s_WorldPartReferenceObjectData:MakeWritable()
	s_WorldPartReferenceObjectData.blueprint = s_CustomWorldPartData

	local s_Registry = RegistryContainer()
	s_Registry.blueprintRegistry:add(s_CustomWorldPartData)

	m_ManDownModifier:OnWorldPartLoaded(s_CustomWorldPartData, s_Registry)
	m_LootCreation:OnWorldPartLoaded(s_CustomWorldPartData, s_Registry)
	self:CreateMapMarkers(s_CustomWorldPartData, s_Registry)
	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

-- TODO: Include in map modification system
function TempMapPatches:OnVehiclesWorldPartData(p_Instance)
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

-- TODO: Include in map modification system
function TempMapPatches:OnPreRoundEntityData(p_Instance)
	-- Disables the pre-round entity
	p_Instance = PreRoundEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.enabled = false
end

-- TODO: Include in map modification system
function TempMapPatches:OnDisableCamerasOnUnspawn(p_Instance)
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

-- TODO: Include in map modification system
function TempMapPatches:OnGameModeSettings(p_Instance)
	local s_Settings = GameModeSettings(p_Instance)
	s_Settings:MakeWritable()
	local s_GameModeTeamSize = GameModeTeamSize()
	s_GameModeTeamSize.playerCount = 127
	s_GameModeTeamSize.squadSize = 4

	for i = 3, 126 do
		s_Settings.information[1].sizes[3].teams:add(s_GameModeTeamSize)
	end
end

-- TODO: Include in map modification system
function TempMapPatches:OnTeamEntityData(p_Instance)
	for i = 3, 126 do
		local s_NewTeamId = TeamEntityData(MathUtils:RandomGuid())
		s_NewTeamId.isEventConnectionTarget = 3
		s_NewTeamId.isPropertyConnectionTarget = 3
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

function TempMapPatches:OnCameraEntityData(p_CameraEntityData)
	p_CameraEntityData.enabled = false
end

function TempMapPatches:CreateMapMarkers(p_WorldPartData, p_Registry)
	for i = 1, 24 do
		local s_MapMarkerEntityData = MapMarkerEntityData()
		s_MapMarkerEntityData.transform.trans = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.baseTransform = Vec3(-9999, -9999, -9999)
		s_MapMarkerEntityData.sid = ""
		s_MapMarkerEntityData.showRadius = 9999
		s_MapMarkerEntityData.hideRadius = 0
		if i <= 4 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_ObjectiveMoveTo -- normal ping
		elseif i <= 8 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_ObjectiveScout -- enemy ping
		elseif i <= 12 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_NeedPickup -- weapon pickup
		elseif i <= 16 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_AmmoCrate -- ammo pickup
		elseif i <= 20 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_MedicBag -- armor pickup
		elseif i <= 24 then
			s_MapMarkerEntityData.hudIcon = UIHudIcon.UIHudIcon_NeedMedic -- health pickup
		end
		s_MapMarkerEntityData.verticalOffset = 0.0
		s_MapMarkerEntityData.focusPointRadius = 0.0
		s_MapMarkerEntityData.useMarkerTransform = false
		s_MapMarkerEntityData.isVisible = true
		s_MapMarkerEntityData.snap = true
		s_MapMarkerEntityData.showAirTargetBox = true
		s_MapMarkerEntityData.isFocusPoint = false
		s_MapMarkerEntityData.indexInBlueprint = 132 + i
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
		s_MapMarkerReferenceObjectData.indexInBlueprint = 132 + i

		p_WorldPartData.objects:add(s_MapMarkerReferenceObjectData)

		p_Registry.referenceObjectRegistry:add(s_MapMarkerReferenceObjectData)
	end
	m_Logger:Write("Created pinging mapmarkers")
end

return TempMapPatches()
