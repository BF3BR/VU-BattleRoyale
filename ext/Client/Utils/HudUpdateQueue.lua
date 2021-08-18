require "__shared/Libs/Queue"
require "Utils/CachedJsExecutor"

local MIN_ITEMS_TO_GROUP = 1
local MAX_ITEMS_TO_GROUP = 25
local UPDATES_TO_SKIP = 5

local m_Logger = Logger("HudUpdateQueue", true)

class "HudUpdateQueue"

function HudUpdateQueue:__init()
	self.m_Queue = Queue()
	self.m_SkippedUpdates = 0
end

function HudUpdateQueue:CreateExecutor(p_FuncTemplate, p_InitialValue)
	return CachedJsExecutor(self, p_FuncTemplate, p_InitialValue)
end

function HudUpdateQueue:Enqueue(p_Executor)
	if p_Executor.m_IsQueued then
		return
	end

	self.m_Queue:Enqueue(p_Executor)
end

function HudUpdateQueue:OnUIDrawHud()
	self.m_SkippedUpdates = self.m_SkippedUpdates + 1
	if self.m_SkippedUpdates < UPDATES_TO_SKIP then
		return
	end

	-- items to update in this batch
	local s_ItemsNumber = math.min(MAX_ITEMS_TO_GROUP, self.m_Queue:Size())
	if s_ItemsNumber < MIN_ITEMS_TO_GROUP then
		return
	end

	-- reset skipped updates
	self.m_SkippedUpdates = 0
	local s_ExecStrings = {}

	-- get js strings for each executor
	for i = 1, s_ItemsNumber do
		local s_Executor = self.m_Queue:Dequeue()
		s_Executor.m_IsQueued = false
		table.insert(s_ExecStrings, s_Executor:JSString())
	end

	-- m_Logger:Write("Items batched #" .. s_ItemsNumber)

	-- concat and send the js strings as one js call
	-- reduces the total overhead of sending each one to CEF for
	-- individual execution
	WebUI:ExecuteJS(table.concat(s_ExecStrings, ";"))
end

if g_HudUpdateQueue == nil then
	g_HudUpdateQueue = HudUpdateQueue()
end

return g_HudUpdateQueue
