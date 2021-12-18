---@class TimersMixin
TimersMixin = class "TimersMixin"

function TimersMixin:__init()
	---@type table<string, Timer>
	self.m__Timers = {}
end

-- Sets a new timer
---@param p_Key string
---@param p_Timer Timer
function TimersMixin:SetTimer(p_Key, p_Timer)
	self:RemoveTimer(p_Key)
	self.m__Timers[p_Key] = p_Timer
end

-- Returns a timer
---@param p_Key string
---@return Timer|nil
function TimersMixin:GetTimer(p_Key)
	return self.m__Timers[p_Key]
end

-- Checks if a timer exists
---@param p_Key string
---@return boolean
function TimersMixin:TimerExists(p_Key)
	return self.m__Timers[p_Key] ~= nil
end

-- Destroys and nils a timer
---@param p_Key string
function TimersMixin:RemoveTimer(p_Key)
	if self.m__Timers[p_Key] ~= nil then
		self.m__Timers[p_Key]:Destroy()
		self.m__Timers[p_Key] = nil
	end
end

-- Resets the timer
-- returns true if it was successfully reset, false otherwise
---@param p_Key string
---@return boolean
function TimersMixin:ResetTimer(p_Key)
	if self.m__Timers[p_Key] ~= nil then
		self.m__Timers[p_Key]:Reset()
		return true
	end

	return false
end

-- Destroys every timer and empties the timers table
function TimersMixin:RemoveTimers()
	for l_Key, _ in pairs(self.m__Timers) do
		self:RemoveTimer(l_Key)
	end

	self.m__Timers = {}
end
