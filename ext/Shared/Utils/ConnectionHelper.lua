class "ConnectionHelper"

-- Blueprint connections
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

function ConnectionHelper:CreatePropertyConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
    local s_PropertyConnection = PropertyConnection()
    s_PropertyConnection.source = p_Source
    s_PropertyConnection.target = p_Target
    s_PropertyConnection.sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
    s_PropertyConnection.targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)

	return s_PropertyConnection
end

function ConnectionHelper:CreateLinkConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
	local s_LinkConnection = LinkConnection()
    s_LinkConnection.source = p_Source
    s_LinkConnection.target = p_Target
    s_LinkConnection.sourceFieldId = tonumber(p_SourceFieldId) or MathUtils:FNVHash(p_SourceFieldId)
    s_LinkConnection.targetFieldId = tonumber(p_TargetFieldId) or MathUtils:FNVHash(p_TargetFieldId)

	return s_LinkConnection
end

-- Temporary struct crash fix
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
function ConnectionHelper:CreateNodeConnection(p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop)
	local s_UINodeConnection = UINodeConnection()
    s_UINodeConnection.source = p_Source
    s_UINodeConnection.target = p_Target
    s_UINodeConnection.sourcePort = p_SourcePort
    s_UINodeConnection.targetPort = p_TargetPort
    s_UINodeConnection.numScreensToPop = p_ScreensToPop or 0

	return s_UINodeConnection
end

function ConnectionHelper:AddNodeConnection(p_GraphAsset, p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop)
    p_GraphAsset.connections:add(self:CreateNodeConnection(p_Source, p_Target, p_SourcePort, p_TargetPort, p_ScreensToPop))
end


-- TODO: Add other connection types
function ConnectionHelper:CloneConnections(p_Blueprint, p_OriginalData, p_CustomData)
    for _, l_Connection in pairs(p_Blueprint.eventConnections) do
        if l_Connection.source == p_OriginalData then
            local s_Clone = EventConnection(l_Connection:Clone())
            s_Clone.source = p_CustomData

            p_Blueprint.eventConnections:add(s_Clone)
        end

        if l_Connection.target == p_OriginalData then
            local s_Clone = EventConnection(l_Connection:Clone())
            s_Clone.target = p_CustomData

            p_Blueprint.eventConnections:add(s_Clone)
        end
    end
end

-- Singleton.
if g_ConnectionHelper == nil then
	g_ConnectionHelper = ConnectionHelper()
end

return g_ConnectionHelper