-- thanks to RM https://github.com/BF3RM/MapEditor/blob/development/ext/Shared/Util/Logger.lua

---@class Logger
Logger = class "Logger"

---@param p_ClassName string
---@param p_ActivateLogging boolean
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

function Logger:WriteF(...)
	self:Write(string.format(table.unpack({...})))
end

---@param p_Message string|number|boolean|table
---@param p_Highlight boolean
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

---@param p_Table table
---@param p_Highlight boolean
---@param p_Key any @only used within the function itself
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

function Logger:WarningF(...)
	self:Warning(string.format(table.unpack({...})))
end

---@param p_Message boolean|string|number|table
function Logger:Warning(p_Message)
	if self.m_ClassName == nil then
		return
	end

	if type(p_Message) == "table" then
		print("["..self.m_ClassName.."] WARNING:")
		print(p_Message)
	else
		if SharedUtils:IsClientModule() then
			print("["..self.m_ClassName.."] *WARNING: " .. tostring(p_Message))
		else
			print("["..self.m_ClassName.."] WARNING: " .. tostring(p_Message))
		end
	end
end

function Logger:ErrorF(...)
	self:Error(string.format(table.unpack({...})))
end

---@param p_Message string|number|boolean|table
function Logger:Error(p_Message)
	if self.m_ClassName == nil then
		return
	end

	if type(p_Message) == "table" then
		print("["..self.m_ClassName.."] ERROR:")
		print(p_Message)
	else
		if SharedUtils:IsClientModule() then
			print("["..self.m_ClassName.."] *ERROR: " .. tostring(p_Message))
		else
			print("["..self.m_ClassName.."] ERROR: " .. tostring(p_Message))
		end
	end
end

return Logger
