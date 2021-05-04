class "ListenersMixin"

local ListenerType = {Event = 1, NetEvent = 2, Hook = 3}

function ListenersMixin:__init()
	self.m__Listeners = {}
end

function ListenersMixin:MakeListenerKey(p_Type, p_EventName)
	return string.format("%s:%d", p_Listener, p_Type)
end

function ListenersMixin:AddListener(p_Type, p_EventName, p_Listener)
	p_Key = p_Key or self:MakeListenerKey(p_Type, p_EventName)

	self:RemoveListener(p_Key)

	self.m__Listeners[p_Key] = {Type = p_Type, Listener = p_Listener}
end

function ListenersMixin:AddEventListener(eventName, context, callback)
	self:AddListener(ListenerType.Event, eventName, Events:Subscribe(eventName, context, callback))
end

function ListenersMixin:AddNetEventListener(eventName, context, callback)
	self:AddListener(ListenerType.NetEvent, eventName, NetEvents:Subscribe(eventName, context, callback))
end

function ListenersMixin:AddHookListener(hookName, priority, context, callback)
	self:AddListener(ListenerType.Hook, eventName, Hooks:Install(hookName, priority, context, callback))
end

function ListenersMixin:GetListener(p_Type, p_EventName)
	-- you can directly pass the key as a parameter instead of type + eventName
	local l_Key = p_Type
	if p_EventName ~= nil then
		l_Key = self:MakeListenerKey(p_Type, p_EventName)
	end

	return self.m__Listeners[l_Key]
end

function ListenersMixin:RemoveListener(p_Type, p_EventName)
	-- you can directly pass the key as a parameter instead of type + eventName
	local l_Key = p_Type
	if p_EventName ~= nil then
		l_Key = self:MakeListenerKey(p_Type, p_EventName)
	end

	local l_Listener = self:GetListener(l_Key)

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
	for l_Key, _ in pairs(self.m__Listeners) do
		self:RemoveListener(l_Key)
	end

	self.m__Listeners = {}
end
