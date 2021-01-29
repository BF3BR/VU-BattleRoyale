class "ListenersMixin"

local ListenerType = {
    Event = 1,
    NetEvent = 2,
    Hook = 3
}

function ListenersMixin:__init()
    self.m__ListenersLastUID = 0
    self.m__Listeners = {}
end

function ListenersMixin:MakeListenerKey(p_Type, p_Listener)
    self.m__ListenersLastUID = self.m__ListenersLastUID + 1
    return string.format('%s:%d:%d', p_Listener, p_Type, self.m__ListenersLastUID)
end

function ListenersMixin:AddListener(p_Type, p_Listener, p_Key)
    p_Key = p_Key or self:MakeListenerKey(p_Type, p_Listener)

    self:RemoveListener(p_Key)

    self.m__Listeners[p_Key] = {
        Type = p_Type,
        Listener = p_Listener
    }
end

function ListenersMixin:AddEventListener(eventName, context, callback)
    self:AddListener(ListenerType.Event, Events:Subscribe(eventName, context, callback))
end

function ListenersMixin:AddNetEventListener(eventName, context, callback)
    self:AddListener(ListenerType.NetEvent, NetEvents:Subscribe(eventName, context, callback))
end

function ListenersMixin:AddHookListener(hookName, priority, context, callback)
    self:AddListener(ListenerType.Hook, Hooks:Install(hookName, priority, context, callback))
end

function ListenersMixin:GetListener(p_Key)
    return self.m__Listeners[p_Key]
end

function ListenersMixin:RemoveListener(p_Key)
    local l_Listener = self:GetListener(p_Key)

    if l_Listener ~= nil then
        if l_Listener.type == ListenerType.Hook then
            item:Uninstall()
        else
            item:Unsubscribe()
        end

        self.m__Listeners[key] = nil
    end
end

function ListenersMixin:RemoveListeners()
    for key, item in pairs(self.m__Listeners) do
        if item.type == ListenerType.Hook then
            item:Uninstall()
        else
            item:Unsubscribe()
        end

        self.m__Listeners[key] = nil
    end

    self.m__Listeners = {}
end
