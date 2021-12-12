---@class ConnectionHelper
local ConnectionHelper = class "ConnectionHelper"

-- Blueprint connections
---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceEvent integer|string
---@param p_TargetEvent integer|string
---@param p_Type EventConnectionTargetType|integer
---@return EventConnection
function ConnectionHelper:CreateEventConnection(p_Source, p_Target, p_SourceEvent, p_TargetEvent, p_Type)
	local s_SourceEventSpec = EventSpec()
	s_SourceEventSpec.id = tonumber(p_SourceEvent) or MathUtils:FNVHash(p_SourceEvent)

	local s_TargetEventSpec = EventSpec()
	s_TargetEventSpec.id = tonumber(p_TargetEvent) or MathUtils:FNVHash(p_TargetEvent)

	local s_EventConnection = EventConnection()
	s_EventConnection.source = p_Source
	s_EventConnection.target = p_Target
	s_EventConnection.sourceEvent = s_SourceEventSpec
	s_EventConnection.targetEvent = s_TargetEventSpec
	s_EventConnection.targetType = p_Type

	return s_EventConnection
end

---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceFieldId integer|string
---@param p_TargetFieldId integer|string
---@return PropertyConnection
function ConnectionHelper:CreatePropertyConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
	local s_PropertyConnection = PropertyConnection()
	s_PropertyConnection.source = p_Source
	s_PropertyConnection.target = p_Target
	s_PropertyConnection.sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
	s_PropertyConnection.targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)

	return s_PropertyConnection
end

---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceFieldId integer|string
---@param p_TargetFieldId integer|string
---@return function|LinkConnection
function ConnectionHelper:CreateLinkConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
	local s_LinkConnection = LinkConnection()
	s_LinkConnection.source = p_Source
	s_LinkConnection.target = p_Target
	s_LinkConnection.sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
	s_LinkConnection.targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)

	return s_LinkConnection
end

-- Temporary struct crash fix
---@param p_Blueprint Blueprint
---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceEvent integer|string
---@param p_TargetEvent integer|string
---@param p_Type EventConnectionTargetType
function ConnectionHelper:AddEventConnection(p_Blueprint, p_Source, p_Target, p_SourceEvent, p_TargetEvent, p_Type)
	-- Normal implementation:
	-- p_Blueprint.eventConnections:add(self:CreateEventConnection(p_Source, p_Target, p_SourceEvent, p_TargetEvent, p_Type))

	-- Without storing any structs in local vars:
	p_Blueprint.eventConnections:add(EventConnection())
	p_Blueprint.eventConnections[#p_Blueprint.eventConnections].source = p_Source
	p_Blueprint.eventConnections[#p_Blueprint.eventConnections].target = p_Target
	p_Blueprint.eventConnections[#p_Blueprint.eventConnections].sourceEvent.id = tonumber(p_SourceEvent) or MathUtils:FNVHash(p_SourceEvent)
	p_Blueprint.eventConnections[#p_Blueprint.eventConnections].targetEvent.id = tonumber(p_TargetEvent) or MathUtils:FNVHash(p_TargetEvent)
	p_Blueprint.eventConnections[#p_Blueprint.eventConnections].targetType = p_Type
end

---@param p_Blueprint Blueprint
---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceFieldId integer|string
---@param p_TargetFieldId integer|string
function ConnectionHelper:AddPropertyConnection(p_Blueprint, p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
	-- Normal implementation:
	-- p_Blueprint.propertyConnections:add(self:CreatePropertyConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId))

	-- Without storing any structs in local vars:
	p_Blueprint.propertyConnections:add(PropertyConnection())
	p_Blueprint.propertyConnections[#p_Blueprint.propertyConnections].source = p_Source
	p_Blueprint.propertyConnections[#p_Blueprint.propertyConnections].target = p_Target
	p_Blueprint.propertyConnections[#p_Blueprint.propertyConnections].sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
	p_Blueprint.propertyConnections[#p_Blueprint.propertyConnections].targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)
end

---@param p_Blueprint Blueprint
---@param p_Source DataContainer
---@param p_Target DataContainer
---@param p_SourceFieldId integer|string
---@param p_TargetFieldId integer|string
function ConnectionHelper:AddLinkConnection(p_Blueprint, p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
	-- Normal implementation:
	-- p_Blueprint.linkConnections:add(self:CreateLinkConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId))

	-- Without storing any structs in local vars:
	p_Blueprint.linkConnections:add(LinkConnection())
	p_Blueprint.linkConnections[#p_Blueprint.linkConnections].source = p_Source
	p_Blueprint.linkConnections[#p_Blueprint.linkConnections].target = p_Target
	p_Blueprint.linkConnections[#p_Blueprint.linkConnections].sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
	p_Blueprint.linkConnections[#p_Blueprint.linkConnections].targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)
end

-- UI node connections
---@param p_Source UINodeData
---@param p_Target UINodeData
---@param p_SourcePort UINodePort
---@param p_TargetPort UINodePort
---@param p_ScreensToPop integer|nil
---@return UINodeConnection
function ConnectionHelper:CreateNodeConnection(p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop)
	local s_UINodeConnection = UINodeConnection()
	s_UINodeConnection.sourceNode = p_Source
	s_UINodeConnection.targetNode = p_Target
	s_UINodeConnection.sourcePort = p_SourcePort
	s_UINodeConnection.targetPort = p_TargetPort
	s_UINodeConnection.numScreensToPop = p_ScreensToPop or 0

	return s_UINodeConnection
end

---@param p_GraphAsset UIGraphAsset
---@param p_Source UINodeData
---@param p_Target UINodeData
---@param p_SourcePort UINodePort
---@param p_TargetPort UINodePort
---@param p_ScreensToPop integer|nil
function ConnectionHelper:AddNodeConnection(p_GraphAsset, p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop)
	p_GraphAsset.connections:add(self:CreateNodeConnection(p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop))
end

---@param p_TypeName string
---@param p_ParentGraphAsset UIGraphAsset
---@param p_FieldsToPopulate string[]
---@return UINodeData #UINodeData this is just the base type
function ConnectionHelper:GetNode(p_TypeName, p_ParentGraphAsset, p_FieldsToPopulate)
	local s_Node = _G[p_TypeName]()
	s_Node.parentGraph = p_ParentGraphAsset

	---@type string
	for _, l_Field in ipairs(p_FieldsToPopulate or {}) do
		s_Node[l_Field] = UINodePort()
	end

	p_ParentGraphAsset.nodes:add(s_Node)

	return s_Node
end

local m_FieldAndType = {
	eventConnections = "EventConnection",
	propertyConnections = "PropertyConnection",
	linkConnections = "LinkConnection",
}

---@param p_Blueprint Blueprint
---@param p_OriginalData DataContainer
---@param p_CustomData DataContainer
function ConnectionHelper:CloneConnections(p_Blueprint, p_OriginalData, p_CustomData)
	for l_Field, l_Type in pairs(m_FieldAndType) do
		for _, l_Connection in pairs(p_Blueprint[l_Field]) do
			if l_Connection.source.instanceGuid == p_OriginalData.instanceGuid then
				local s_Clone = _G[l_Type](l_Connection:Clone())
				s_Clone.source = p_CustomData

				p_Blueprint[l_Field]:add(s_Clone)
			end

			if l_Connection.target.instanceGuid == p_OriginalData.instanceGuid then
				local s_Clone = _G[l_Type](l_Connection:Clone())
				s_Clone.target = p_CustomData

				p_Blueprint[l_Field]:add(s_Clone)
			end
		end
	end
end

return ConnectionHelper()
