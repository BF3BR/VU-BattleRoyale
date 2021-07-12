class "ListenersMixin"

local ListenerType = {Event = 1, NetEvent = 2, Hook = 3}

function ListenersMixin:__init()
	self.m__Listeners = {}
end

function ListenersMixin:MakeListenerKey(p_Type, p_Listener)
	return string.format("%s:%d", p_Listener, p_Type)
end

function ListenersMixin:AddListener(p_Type, p_EventName, p_Listener)
	p_Key = p_Key or self:MakeListenerKey(p_Type, p_EventName)

	self:RemoveListener(p_Key)

	self.m__Listeners[p_Key] = {Type = p_Type, Listener = p_Listener}
end

function ListenersMixin:AddEventListener(p_EventName, p_Context, p_Callback)
	self:AddListener(ListenerType.Event, p_EventName, Events:Subscribe(p_EventName, p_Context, p_Callback))
end

function ListenersMixin:AddNetEventListener(p_EventName, p_Context, p_Callback)
	self:AddListener(ListenerType.NetEvent, p_EventName, NetEvents:Subscribe(p_EventName, p_Context, p_Callback))
end

function ListenersMixin:AddHookListener(p_HookName, p_Priority, p_Context, p_Callback)
	self:AddListener(ListenerType.Hook, eventName, Hooks:Install(p_HookName, p_Priority, p_Context, p_Callback))
end

function ListenersMixin:GetListener(p_Type, p_EventName)
	-- you can directly pass the key as a parameter instead of type + eventName
	local s_Key = p_Type

	if p_EventName ~= nil then
		s_Key = self:MakeListenerKey(p_Type, p_EventName)
	end

	return self.m__Listeners[s_Key]
end

function ListenersMixin:RemoveListener(p_Type, p_EventName)
	-- you can directly pass the key as a parameter instead of type + eventName
	local s_Key = p_Type

	if p_EventName ~= nil then
		s_Key = self:MakeListenerKey(p_Type, p_EventName)
	end

	local s_Listener = self:GetListener(s_Key)

	if s_Listener ~= nil then
		if s_Listener.type == ListenerType.Hook then
			item:Uninstall()
		else
			item:Unsubscribe()
		end

		self.m__Listeners[s_Key] = nil
	end
end

function ListenersMixin:RemoveListeners()
	for l_Key, _ in pairs(self.m__Listeners) do
		self:RemoveListener(l_Key)
	end

	self.m__Listeners = {}
end
