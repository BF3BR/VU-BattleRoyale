class "CachedJsExecutor"

function CachedJsExecutor:__init(p_FuncTemplate, p_InitialValue)
	self.m_FuncTemplate = p_FuncTemplate
	self.m_Prev = nil

	self:Update(p_InitialValue)
end

function CachedJsExecutor:Update(p_Value)
	if self.m_Prev == p_Value then
		return p_Value
	end

	self.m_Prev = p_Value

	WebUI:ExecuteJS(string.format(self.m_FuncTemplate, p_Value))
	return p_Value
end

function CachedJsExecutor:ForceUpdate(p_Value)
	self.m_Prev = p_Value

	WebUI:ExecuteJS(string.format(self.m_FuncTemplate, p_Value))
	return p_Value
end
