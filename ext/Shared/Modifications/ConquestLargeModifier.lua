---@class ConquestModifier
ConquestModifier = class 'ConquestModifier'

local m_Conquest_PreRoundEntityData = DC(Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"), Guid("B3AF5AF0-4703-402C-A238-601E610A0B48"))
local m_Conquest_SpatialPrefabBlueprint = DC(Guid("0C342A8C-BCDE-11E0-8467-9159D6ACA94C"), Guid("ADDF2F84-F2E8-2AD8-5FE6-56620207AC95"))
local m_SoldierBlueprint = DC(Guid("F256E142-C9D8-4BFE-985B-3960B9E9D189"), Guid("261E43BF-259B-41D2-BF3B-9AE4DDA96AD2"))
local m_CapturePointPrefab_HQ_US_XP_CameraEntityData = DC(Guid("694A231C-4439-461D-A7FF-764915FC3E7C"), Guid("6B728CD3-EBD2-4D48-BF49-50A7CFAB0A30"))
local m_CapturePointPrefab_HQ_RU_XP_CameraEntityData = DC(Guid("5D4B1096-3089-45A7-9E3A-422E15E0D8F6"), Guid("A4281E60-7557-4BFF-ADD4-18D7E8780873"))
-- CqLarge
local m_RU_Large_TeamEntityData = DC(Guid("19631E31-2E3A-432B-8929-FB57BAA7D28E"), Guid("B4BB6CFA-0E53-45F9-B190-1287DCC093A9"))
local m_ConquestTeamsLarge_LogicPrefabBlueprint = DC(Guid("466C8E5C-BD29-11E0-923F-C41005FFB7BD"), Guid("D0DB1029-9313-7D6D-BBA9-9C8F92C0040B"))

local m_Logger = Logger("ConquestModifier", true)

function ConquestModifier:RegisterCallbacks()
	m_Conquest_PreRoundEntityData:RegisterLoadHandler(self, self.OnPreRoundEntityData)
	m_Conquest_SpatialPrefabBlueprint:RegisterLoadHandler(self, self.OnSpatialPrefabBlueprint)
	m_CapturePointPrefab_HQ_US_XP_CameraEntityData:RegisterLoadHandler(self, self.OnCameraEntityData)
	m_CapturePointPrefab_HQ_RU_XP_CameraEntityData:RegisterLoadHandler(self, self.OnCameraEntityData)
	DC:WaitForInstances({ m_RU_Large_TeamEntityData, m_ConquestTeamsLarge_LogicPrefabBlueprint }, self, self.OnTeamEntityDataModification)
	DC:WaitForInstances({ m_Conquest_SpatialPrefabBlueprint, m_SoldierBlueprint }, self, self.OnAddCharacterSpawnReference)
end

function ConquestModifier:DeregisterCallbacks()
	m_Conquest_PreRoundEntityData:Deregister()
	m_Conquest_SpatialPrefabBlueprint:Deregister()
	m_SoldierBlueprint:Deregister()
	m_CapturePointPrefab_HQ_US_XP_CameraEntityData:Deregister()
	m_CapturePointPrefab_HQ_RU_XP_CameraEntityData:Deregister()
	m_RU_Large_TeamEntityData:Deregister()
	m_ConquestTeamsLarge_LogicPrefabBlueprint:Deregister()
end

function ConquestModifier:OnPreRoundEntityData(p_Instance)
	-- Disables the pre-round entity
	p_Instance = PreRoundEntityData(p_Instance)
	p_Instance:MakeWritable()
	p_Instance.enabled = false
end

function ConquestModifier:OnSpatialPrefabBlueprint(p_Instance)
	p_Instance = SpatialPrefabBlueprint(p_Instance)
	p_Instance:MakeWritable()

	-- Disables the default HQ / spawn cameras
	for i = #p_Instance.eventConnections, 1, -1 do
		if p_Instance.eventConnections[i] ~= nil and p_Instance.eventConnections[i].source ~= nil then
			if p_Instance.eventConnections[i].source:Is("HumanPlayerEntityData") then
				if EventSpec(p_Instance.eventConnections[i].sourceEvent).id == MathUtils:FNVHash("OnPlayerDeathTimeout") and
					p_Instance.eventConnections[i].target:Is("LogicReferenceObjectData") then
					p_Instance.eventConnections:erase(i)
				end

				if p_Instance.eventConnections[i].target.instanceGuid == Guid("38B766CB-020E-4254-B220-7F69F33A7FEA") then
					p_Instance.eventConnections:erase(i)
				end
			end
		end
	end
end

function ConquestModifier:OnCameraEntityData(p_CameraEntityData)
	p_CameraEntityData.enabled = false
end

function ConquestModifier:OnTeamEntityDataModification(p_TeamData, p_LogicPrefabBlueprint)
	m_Logger:Write("Adding TeamEntityDatas to ConquestTeamsLarge LogicPrefabBlueprint")

	p_LogicPrefabBlueprint = LogicPrefabBlueprint(p_LogicPrefabBlueprint)

	if #p_LogicPrefabBlueprint.objects > 3 then
		m_Logger:Warning("We added the TeamEntities already.")
		return
	end

	for i = 3, 126 do
		local s_NewTeamId = TeamEntityData(MathUtils:RandomGuid())
		s_NewTeamId.isEventConnectionTarget = 3
		s_NewTeamId.isPropertyConnectionTarget = 3
		s_NewTeamId.indexInBlueprint = i
		s_NewTeamId.team = TeamData(p_TeamData)
		s_NewTeamId.id = i

		p_LogicPrefabBlueprint:MakeWritable()
		p_LogicPrefabBlueprint.objects:add(s_NewTeamId)
		p_LogicPrefabBlueprint.partition:AddInstance(s_NewTeamId)
	end
end

function ConquestModifier:OnAddCharacterSpawnReference(p_SpatialPrefabBlueprint, p_SoldierBlueprint)
	-- Add 1 CharacterSpawnReference
	p_SpatialPrefabBlueprint = SpatialPrefabBlueprint(p_SpatialPrefabBlueprint)
	p_SpatialPrefabBlueprint:MakeWritable()
	local s_Partition = ResourceManager:FindPartitionForInstance(p_SpatialPrefabBlueprint)
	local s_Registry = RegistryContainer()

	local s_CharacterSpawnReferenceObjectData = CharacterSpawnReferenceObjectData(Guid("67A2C146-9CC0-E7EC-5227-B2DCB9D316C1"))
	s_CharacterSpawnReferenceObjectData.team = TeamId.TeamNeutral
	s_CharacterSpawnReferenceObjectData.locationTextSid = "1"
	s_CharacterSpawnReferenceObjectData.locationNameSid = "Spawn 1"
	s_CharacterSpawnReferenceObjectData.blueprint = SoldierBlueprint(p_SoldierBlueprint)
	s_CharacterSpawnReferenceObjectData.playerType = PlayerSpawnType.PlayerSpawnType_HumanPlayer
	s_CharacterSpawnReferenceObjectData.useAsSpawnPoint = true
	s_CharacterSpawnReferenceObjectData.maxCount = 0
	s_CharacterSpawnReferenceObjectData.takeControlEntryIndex = 1
	s_CharacterSpawnReferenceObjectData.isEventConnectionTarget = 2
	s_CharacterSpawnReferenceObjectData.isPropertyConnectionTarget = 3

	p_SpatialPrefabBlueprint.objects:add(s_CharacterSpawnReferenceObjectData)
	s_Partition:AddInstance(s_CharacterSpawnReferenceObjectData)
	s_Registry.referenceObjectRegistry:add(s_CharacterSpawnReferenceObjectData)

	ResourceManager:AddRegistry(s_Registry, ResourceCompartment.ResourceCompartment_Game)
end

return ConquestModifier()
