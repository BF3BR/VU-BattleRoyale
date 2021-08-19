-- thanks to RM https://github.com/BF3RM/MapEditor/blob/development/ext/Shared/Util/Logger.lua

class "Logger"

function Logger:__init(p_ClassName, p_ActivateLogging)
	if type(p_ClassName) ~= "string" then
		error("Logger: Wrong arguments creating object, className is not a string. ClassName: ".. tostring(p_ClassName))
		return
	elseif type(p_ActivateLogging) ~= "boolean" then
		error("Logger: Wrong arguments creating object, ActivateLogging is not a boolean. ActivateLogging: " .. tostring(p_ActivateLogging))
		return
	end

	self.m_Debug = p_ActivateLogging
	self.m_ClassName = p_ClassName
end

function Logger:Write(p_Message, p_Highlight)
	if not ServerConfig.Debug.Logger_Enabled then
		return
	end

	if ServerConfig.Debug.Logger_Print_All == true and self.m_ClassName ~= nil then
		goto continue
	elseif self.m_Debug == false or self.m_Debug == nil or self.m_ClassName == nil then
		return
	end

	::continue::

	if type(p_Message) == "table" then
		print("["..self.m_ClassName.."]")
		print(p_Message)
	else
		if p_Highlight and SharedUtils:IsClientModule() then
			print("["..self.m_ClassName.."] *" .. tostring(p_Message))
		else
			print("["..self.m_ClassName.."] " .. tostring(p_Message))
		end
	end
end

function Logger:WriteTable(p_Table, p_Highlight, p_Key)
	if p_Key == nil then
		p_Key = ""
	else
		p_Key = tostring(p_Key) .. " - "
	end

	for l_Key, l_Value in pairs(p_Table) do
		local s_Key = p_Key .. tostring(l_Key)

		if type(l_Value) == "table" then
			self:WriteTable(l_Value, p_Highlight, s_Key)
		else
			self:Write(s_Key .. " - " .. tostring(l_Value), p_Highlight)
		end
	end
end

function Logger:Warning(p_Message)
	if self.m_ClassName == nil then
		return
	end

	if SharedUtils:IsClientModule() then
		print("["..self.m_ClassName.."] *WARNING: " .. tostring(p_Message))
	else
		print("["..self.m_ClassName.."] WARNING: " .. tostring(p_Message))
	end
end

function Logger:Error(p_Message)
	if self.m_ClassName == nil then
		return
	end

	if SharedUtils:IsClientModule() then
		print("["..self.m_ClassName.."] *ERROR: " .. tostring(p_Message))
	else
		print("["..self.m_ClassName.."] ERROR: " .. tostring(p_Message))
	end

end

return Logger
