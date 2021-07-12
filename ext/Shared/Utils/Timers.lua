class "TimerManager"

function TimerManager:__init()
	self.m_LastId = 1
	self.m_ActiveTimers = 0
	self.m_Timers = {}
	self.m_UpdateEvent = nil

	-- flags
	self.__Updating = false
	self.__CreatedDuringUpdate = false
end

-- Updates the state of the timers
function TimerManager:Update()
	self.__Updating = true
	self.__CreatedDuringUpdate = false

	local s_Now = SharedUtils:GetTimeMS()

	for l_Id, l_Timer in pairs(self.m_Timers) do
		if l_Timer ~= nil then l_Timer:Update(s_Now) end

		if self.__CreatedDuringUpdate then return self:Update() end
	end

	self.__Updating = false
end

-- Removes a timer from the manager
function TimerManager:Remove(p_Timer)
	if self.m_Timers[p_Timer.m_Id] == nil then return end

	self.m_Timers[p_Timer.m_Id] = nil

	-- unsubscribe from update event if needed
	self.m_ActiveTimers = self.m_ActiveTimers - 1

	if self.m_UpdateEvent ~= nil and self.m_ActiveTimers < 1 then
		self.m_UpdateEvent:Unsubscribe()
		self.m_UpdateEvent = nil
	end
end

-- Removes all timers from the manager
function TimerManager:RemoveAll()
	-- unsubscribe from update event
	if self.m_UpdateEvent ~= nil then
		self.m_UpdateEvent:Unsubscribe()
		self.m_UpdateEvent = nil
	end

	-- destroy all timers
	for l_Id, l_Timer in pairs(self.m_Timers) do if l_Timer ~= nil then l_Timer:Destroy() end end

	self.m_ActiveTimers = 0
	self.m_Timers = {}
end

-- Creates a timer and add it to the manager
function TimerManager:CreateTimer(p_Delay, p_Cycles, p_UserData, p_Callback)
	self.m_LastId = self.m_LastId + 1
	local s_Timer = Timer(self, tostring(self.m_LastId), p_Delay, p_Cycles, p_UserData, p_Callback)
	self.m_Timers[s_Timer.m_Id] = s_Timer

	-- update flags
	if self.__Updating then self.__CreatedDuringUpdate = true end

	-- subscribe to update event if needed
	self.m_ActiveTimers = self.m_ActiveTimers + 1

	if self.m_UpdateEvent == nil then self.m_UpdateEvent = Events:Subscribe("Engine:Update", self, self.Update) end

	return s_Timer
end

-- Runs once after the specified delay
function TimerManager:Timeout(p_Delay, p_UserData, p_Callback)
	return self:CreateTimer(p_Delay, 1, p_UserData, p_Callback)
end

-- Runs for a certain amount of times with the specified delay in between calls
function TimerManager:Sequence(p_Delay, p_Cycles, p_UserData, p_Callback)
	return self:CreateTimer(p_Delay, p_Cycles, p_UserData, p_Callback)
end

-- Runs forever with the specified delay in between calls
function TimerManager:Interval(p_Delay, p_UserData, p_Callback)
	return self:CreateTimer(p_Delay, 0, p_UserData, p_Callback)
end

-- Timer
class "Timer"

function Timer:__init(p_Manager, p_Id, p_Delay, p_Cycles, p_UserData, p_Callback)
	self.m_Manager = p_Manager
	self.m_Id = p_Id
	self.m_Delay = p_Delay * 1000
	self.m_Cycles = p_Cycles
	self.m_UserData = p_UserData
	self.m_Callback = p_Callback

	if p_UserData ~= nil and p_Callback == nil then
		self.m_UserData = nil
		self.m_Callback = p_UserData
	end

	self.m_CurrentCycle = 0
	self.m_StartedAt = SharedUtils:GetTimeMS()
	self.m_UpdatedAt = self.m_StartedAt
end

-- Update timer's state and call the callback if needed
function Timer:Update(now)
	if self.m_Callback ~= nil and now - self.m_UpdatedAt >= self.m_Delay then
		self.m_UpdatedAt = now

		-- call the callback
		if self.m_UserData ~= nil then
			self.m_Callback(self.m_UserData, self)
		else
			self.m_Callback(self)
		end

		-- move to next cycle
		if not self:Next() then self:Destroy() end
	end
end

-- Move to the next cycle
function Timer:Next()
	if self.m_Cycles == 0 then return true end

	-- increment cycle counter
	self.m_CurrentCycle = self.m_CurrentCycle + 1

	if self.m_CurrentCycle >= self.m_Cycles then
		self.m_CurrentCycle = self.m_Cycles
		return false
	end

	return true
end

-- Destroy the timer
function Timer:Destroy()
	self.m_Manager:Remove(self)

	self.m_Callback = nil
	self.m_UserData = nil
end

-- Returns the time elapsed since the beginning
function Timer:Elapsed()
	return (SharedUtils:GetTimeMS() - self.m_StartedAt) / 1000
end

-- Returns the time remaining until the timer is completed
function Timer:Remaining()
	if self.m_Cycles == 0 then return 0 end

	local s_Time = (self.m_StartedAt + (self.m_Cycles * self.m_Delay)) - SharedUtils:GetTimeMS()
	return math.max(0, s_Time / 1000)
end

-- TimerManager singleton
g_Timers = TimerManager()
