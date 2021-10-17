class "TimersMixin"

function TimersMixin:__init()
	self.m__Timers = {}
end

-- Sets a new timer
function TimersMixin:SetTimer(p_Key, p_Timer)
	self:RemoveTimer(p_Key)
	self.m__Timers[p_Key] = p_Timer
end

-- Returns a timer
function TimersMixin:GetTimer(p_Key)
	return self.m__Timers[p_Key]
end

-- Checks if a timer exists
function TimersMixin:TimerExists(p_Key)
	return self.m__Timers[p_Key] ~= nil
end

-- Destroys and nils a timer
function TimersMixin:RemoveTimer(p_Key)
	if self.m__Timers[p_Key] ~= nil then
		self.m__Timers[p_Key]:Destroy()
		self.m__Timers[p_Key] = nil
	end
end

-- Resets the timer
-- returns true if it was successfully reset, false otherwise
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
