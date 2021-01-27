class "EventConnections"

function EventConnections:Create(source, target, sourceEvent, targetEvent, targetType)

    local sourceEventSpec = EventSpec()
    sourceEventSpec.id = tonumber(sourceEvent) or MathUtils:FNVHash(sourceEvent)

    local targetEventSpec = EventSpec()
    targetEventSpec.id = tonumber(targetEvent) or MathUtils:FNVHash(targetEvent)

    local EventConnection = EventConnection()
    EventConnection.source = source
    EventConnection.target = target
    EventConnection.sourceEvent = sourceEventSpec
    EventConnection.targetEvent = targetEventSpec
    EventConnection.targetType = targetType

    return EventConnection
end

return EventConnections()