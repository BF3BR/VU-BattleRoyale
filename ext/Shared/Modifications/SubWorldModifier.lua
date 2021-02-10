class "SubWorldModifier"


local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"

function SubWorldModifier:__init()
	
end

function SubWorldModifier:OnSubWorldLoaded(p_SubWorldData, p_Common)
    -- Add player data
	local s_HumanPlayerEntityData = HumanPlayerEntityData(MathUtils:RandomGuid())
	s_HumanPlayerEntityData.indexInBlueprint = p_Common:GetIndex()
	s_HumanPlayerEntityData.isEventConnectionTarget = 1
	s_HumanPlayerEntityData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_HumanPlayerEntityData)
	
	-- Add level control data
	local s_LevelControlEntityData = LevelControlEntityData(MathUtils:RandomGuid())
	s_LevelControlEntityData.indexInBlueprint = p_Common:GetIndex()
	s_LevelControlEntityData.isEventConnectionTarget = 1
	s_LevelControlEntityData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_LevelControlEntityData)
	
	-- Add team data
	local s_AutoTeamEntityData = AutoTeamEntityData()
	s_AutoTeamEntityData.teamAssignMode = TeamAssignMode.TamFullTeams
	s_AutoTeamEntityData.autoBalance = false
	s_AutoTeamEntityData.indexInBlueprint = p_Common:GetIndex()
	s_AutoTeamEntityData.isEventConnectionTarget = 1
	s_AutoTeamEntityData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_AutoTeamEntityData)
	
	local s_TeamsLogicPrefabBlueprint = LogicPrefabBlueprint(ResourceManager:SearchForDataContainer("Gameplay/Level_Setups/Components/ConquestTeamsLarge"))
	local s_TeamsLogicReferenceObjectData = ReferenceObjectData(MathUtils:RandomGuid())
	s_TeamsLogicReferenceObjectData.blueprint = s_TeamsLogicPrefabBlueprint
	s_TeamsLogicReferenceObjectData.indexInBlueprint = p_Common:GetIndex()
	s_TeamsLogicReferenceObjectData.isEventConnectionTarget = 3
	s_TeamsLogicReferenceObjectData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_TeamsLogicReferenceObjectData)
	p_Common.m_Registry.referenceObjectRegistry:add(s_TeamsLogicReferenceObjectData)
		
	-- Add weapon UI (crosshairs, hitmarkers...)
	local s_UIGraphAsset = UIGraphAsset(ResourceManager:SearchForDataContainer("UI/Flow/Graph/Ingame/Soldier/UIWeaponGraphMP"))
	local s_UIGraphEntityData = UIGraphEntityData(MathUtils:RandomGuid())
	s_UIGraphEntityData.graphAsset = s_UIGraphAsset
   	s_UIGraphEntityData.indexInBlueprint = p_Common:GetIndex()
	s_UIGraphEntityData.isEventConnectionTarget = 0
	s_UIGraphEntityData.isPropertyConnectionTarget = 3
   	p_SubWorldData.objects:add(s_UIGraphEntityData)
	
   	-- Add menu UI
   	local s_MenuLogicPrefabBlueprint = LogicPrefabBlueprint(ResourceManager:SearchForDataContainer("UI/Flow/Logic/UIIngameMenuMPLogic"))
	local s_MenuLogicReferenceObjectData = LogicReferenceObjectData(MathUtils:RandomGuid())
	s_MenuLogicReferenceObjectData.blueprint = s_MenuLogicPrefabBlueprint
	s_MenuLogicReferenceObjectData.indexInBlueprint = p_Common:GetIndex()
	s_MenuLogicReferenceObjectData.isEventConnectionTarget = 0
	s_MenuLogicReferenceObjectData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_MenuLogicReferenceObjectData)
	p_Common.m_Registry.referenceObjectRegistry:add(s_MenuLogicReferenceObjectData)
	
	-- Convert server events to client events
	local s_PlayerFilterEntityData = PlayerFilterEntityData(MathUtils:RandomGuid())
	s_PlayerFilterEntityData.realm = Realm.Realm_Server
	s_PlayerFilterEntityData.indexInBlueprint = p_Common:GetIndex()
	s_PlayerFilterEntityData.isEventConnectionTarget = 1
	s_PlayerFilterEntityData.isPropertyConnectionTarget = 3
	p_SubWorldData.objects:add(s_PlayerFilterEntityData)
	
	-- Fire server event at PlayerFilterEntity
	m_ConnectionHelper:AddEventConnection(p_SubWorldData, s_HumanPlayerEntityData, s_PlayerFilterEntityData, 'OnPlayerEnter', 'In', 3) -- TargetType_Server

	-- Fire client events to initialize UI
	m_ConnectionHelper:AddEventConnection(p_SubWorldData, s_PlayerFilterEntityData, s_UIGraphEntityData, 'OnTriggerOnlyForPlayer', 'StartRound', 2) -- TargetType_Client
	m_ConnectionHelper:AddEventConnection(p_SubWorldData, s_PlayerFilterEntityData, s_MenuLogicReferenceObjectData, 'OnTriggerOnlyForPlayer', 'Disable', 2) -- TargetType_Client
	
    -- TODO: fix weapon UI

	print("[SubWorldModifier] Basic SubWorld created")
end

-- Singleton.
if g_SubWorldModifier == nil then
	g_SubWorldModifier = SubWorldModifier()
end

return g_SubWorldModifier