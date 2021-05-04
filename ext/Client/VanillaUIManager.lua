class "VanillaUIManager"

local m_Logger = Logger("VanillaUIManager", true)
local m_ConnectionHelper = require "__shared/Utils/ConnectionHelper"

function VanillaUIManager:__init()
    self:ResetVars()
end

function VanillaUIManager:OnLevelDestroy()
    self:ResetVars()
end

function VanillaUIManager:ResetVars()
    self.m_UIControlEntity = nil
end

function VanillaUIManager:GetEntity()
    if self.m_UIControlEntity == nil then
        self:CreateEntity()
    end

    return self.m_UIControlEntity
end

function VanillaUIManager:CreateEntity()
    local s_Data = self:GetEntityData()

    local s_Entity = EntityManager:CreateEntity(s_Data, LinearTransform())
    if s_Entity ~= nil then
        self.m_UIControlEntity = s_Entity

        m_Logger:Write("Created UI control entity")
    else
        m_Logger:Error("Failed to create UI control entity")
    end
end

function VanillaUIManager:GetEntityData()
    local s_GraphAsset = UIGraphAsset()

	-- SpawnCustomization
    local s_ShowSoldierInputNode = m_ConnectionHelper:GetNode('InstanceInputNode', s_GraphAsset, { 'out' })
	s_ShowSoldierInputNode.name = 'ShowSoldier'
	
	local s_ShowSoldierActionNode =  m_ConnectionHelper:GetNode('ActionNode', s_GraphAsset, { 'inValue', 'out' })
	s_ShowSoldierActionNode.actionKey = UIAction.SpawnCustomization
	s_ShowSoldierActionNode.params:add('-1')	
	ConnectionHelper:AddNodeConnection(s_GraphAsset, s_ShowSoldierInputNode, s_ShowSoldierActionNode, s_ShowSoldierInputNode.out, s_ShowSoldierActionNode.inValue)

    -- UnSpawnCustomization
    local s_HideSoldierInputNode = m_ConnectionHelper:GetNode('InstanceInputNode', s_GraphAsset, { 'out' })
	s_HideSoldierInputNode.name = 'HideSoldier'
	
    local s_HideSoldierActionNode =  m_ConnectionHelper:GetNode('ActionNode', s_GraphAsset, { 'inValue', 'out' })
	s_HideSoldierActionNode.actionKey = UIAction.UnSpawnCustomization
	s_HideSoldierActionNode.params:add('-1')	
	ConnectionHelper:AddNodeConnection(s_GraphAsset, s_HideSoldierInputNode, s_HideSoldierActionNode, s_HideSoldierInputNode.out, s_HideSoldierActionNode.inValue)

    -- Outputs
    local s_OutputNode = m_ConnectionHelper:GetNode('InstanceOutputNode', s_GraphAsset, { 'inValue' })
	ConnectionHelper:AddNodeConnection(s_GraphAsset, s_ShowSoldierActionNode, s_OutputNode, s_ShowSoldierActionNode.out, s_OutputNode.inValue)
    ConnectionHelper:AddNodeConnection(s_GraphAsset, s_HideSoldierActionNode, s_OutputNode, s_HideSoldierActionNode.out, s_OutputNode.inValue)
	
	local s_GraphEntityData = UIGraphEntityData()
	s_GraphEntityData.graphAsset = s_GraphAsset
	s_GraphEntityData.popPreviousGraph = false
	
	return s_GraphEntityData
end

function VanillaUIManager:EnableShowroomSoldier(p_Enable)
    local s_Entity = self:GetEntity()
    local s_Event = p_Enable and "ShowSoldier" or "HideSoldier"
    s_Entity:FireEvent(s_Event)

    m_Logger:Write("Fired "..s_Event.." at UI control entity")
end

function VanillaUIManager:OnUIPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
    local s_Screen = UIGraphAsset(p_Screen)

    if s_Screen.name == "UI/Flow/Screen/SpawnScreenPC" 
    or s_Screen.name == "UI/Flow/Screen/SpawnScreenTicketCounterConquestScreen" 
    or s_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD32Screen" 
    or s_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen" 
    or s_Screen.name == "UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD64Screen" 
    or s_Screen.name == "UI/Flow/Screen/KillScreen" 
    or s_Screen.name == "UI/Flow/Screen/SpawnButtonScreen" then
        p_Hook:Return()
    end
end

if g_VanillaUIManager == nil then
	g_VanillaUIManager = VanillaUIManager()
end

return g_VanillaUIManager
