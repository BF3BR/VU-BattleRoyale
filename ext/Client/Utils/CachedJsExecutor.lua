class "CachedJsExecutor"

function CachedJsExecutor:__init(p_UpdateQueue, p_FuncTemplate, p_InitialValue)
	self.m_UpdateQueue = p_UpdateQueue
	self.m_IsQueued = false

	self.m_FuncTemplate = p_FuncTemplate
	self.m_PrevValue = nil

	self:Update(p_InitialValue)
end

function CachedJsExecutor:Update(p_Value, p_Forced)
	if not p_Forced and self.m_PrevValue == p_Value then
		return p_Value
	end

	self.m_PrevValue = p_Value
	self.m_UpdateQueue:Enqueue(self)

	return p_Value
end

-- Ignored cached value and update
function CachedJsExecutor:ForceUpdate(p_Value)
	self:Update(p_Value, true)
end

function CachedJsExecutor:JSString()
	return string.format(self.m_FuncTemplate, self.m_PrevValue)
end
