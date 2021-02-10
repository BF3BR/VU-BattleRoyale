class "ConnectionHelper"


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

function ConnectionHelper:AddEventConnection(p_Blueprint, p_Source, p_Target, p_SourceEvent, p_TargetEvent, p_Type)
    p_Blueprint.eventConnections:add(self:CreateEventConnection(p_Source, p_Target, p_SourceEvent, p_TargetEvent, p_Type))
end

function ConnectionHelper:AddPropertyConnection(p_Blueprint, p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
    p_Blueprint.propertyConnections:add(self:CreatePropertyConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId))
end

function ConnectionHelper:AddLinkConnection(p_Blueprint, p_Source, p_Target, p_SourceFieldId, p_TargetFieldId)
    p_Blueprint.linkConnections:add(self:CreateLinkConnection(p_Source, p_Target, p_SourceFieldId, p_TargetFieldId))
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