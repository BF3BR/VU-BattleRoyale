---@class OOCFiresServer
OOCFiresServer = class "OOCFiresServer"

---@type Logger
local m_Logger = Logger("OOCFiresServer", false)

local m_MaxEffectsNumber = 256
local m_GridSize = 16

function OOCFiresServer:__init()
	---@type Queue
	self.m_Queue = Queue()

	self:ResetVars()
	self:RegisterEvents()
end

function OOCFiresServer:ResetVars()
	self.m_Queue:ResetVars()
	self.m_LastSpawnRadius = 0.0

	-- use spawn grid to avoid spawning effects too close
	self.m_SpawnGrid = {}
end

function OOCFiresServer:RegisterEvents()
	Events:Subscribe(PhaseManagerEvent.Update, self, self.OnCircleUpdate)
	Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnCircleMove)
end

---@param p_Circle Circle
---@param p_Num integer
---@return Vec2[]
function OOCFiresServer:GetRandomCircumPositions(p_Circle, p_Num)
	local s_RandomAngle = MathUtils:GetRandom(0, 2 * math.pi)
	local s_AngleDiff = (2 * math.pi) / p_Num

	local s_Points = {}
	for l_Index = 1, p_Num do
		local s_Angle = s_RandomAngle + (l_Index * s_AngleDiff)
		local s_Pos = p_Circle:CircumferencePoint(s_Angle)

		table.insert(s_Points, Vec2(s_Pos.x, s_Pos.z))
	end

	return s_Points
end

---@param p_Circle Circle
---@return boolean
function OOCFiresServer:ShouldSpawnItems(p_Circle)
	-- return MathUtils:GetRandom(0, 1) > 0.999
	return math.abs(self.m_LastSpawnRadius - p_Circle.m_Radius) > 4
end

---@param p_Positions Vec3[]
function OOCFiresServer:AddItems(p_Positions)
	local s_AddedItems = {}

	-- try to all add new items
	for l_Index = 1, #p_Positions do
		-- add new item
		local s_Item = self:AddItem(p_Positions[l_Index])
		if s_Item ~= nil then
			table.insert(s_AddedItems, s_Item)

			-- remove oldest item
			self:RemoveOldestItem()
		end
	end

	-- send added items to players
	if #s_AddedItems > 0 then
		NetEvents:BroadcastLocal("OOCF:SpawnItems", s_AddedItems)
	end
end

---@param p_Item OOCFireItem
---@return boolean
function OOCFiresServer:CanAddItem(p_Item)
	return not self.m_SpawnGrid[self:GridKey(p_Item)]
end

---@return integer|'1'|'2'
function OOCFiresServer:GetRandomEffectIndex()
	local s_RandNum = MathUtils:GetRandom(0.0, 1.0)

	if s_RandNum > 0.3 then
		return 1
	else
		return 2
	end
end

---@param p_Position Vec3
---@return OOCFireItem|nil
function OOCFiresServer:AddItem(p_Position)
	---@class OOCFireItem
	local s_Item = {
		Position = p_Position,
		Effect = self:GetRandomEffectIndex()
	}

	-- check if item should be added
	if not self:CanAddItem(s_Item) then
		return nil
	end

	-- add to queue and grid
	self.m_Queue:Enqueue(s_Item)
	self.m_SpawnGrid[self:GridKey(s_Item)] = true

	return s_Item
end

-- Removes the oldest item if the queue is above the limit
---@param p_Force boolean
function OOCFiresServer:RemoveOldestItem(p_Force)
	p_Force = not (not p_Force)

	-- check if queue is over the limit
	if not p_Force and self.m_Queue:Size() <= m_MaxEffectsNumber then
		return
	end

	-- remove from queue
	---@type OOCFireItem|nil
	local s_Item = self.m_Queue:Dequeue()
	if s_Item == nil then
		return
	end

	-- remove from grid
	self.m_SpawnGrid[self:GridKey(s_Item)] = nil
end

---@param p_Player Player
function OOCFiresServer:SendState(p_Player)
	local s_State = {
		MaxEffectsNumber = m_MaxEffectsNumber,
		Items = self.m_Queue:AsList()
	}

	NetEvents:SendToLocal("OOCF:State", p_Player, s_State)
end

---@param p_Item OOCFireItem
---@return string
function OOCFiresServer:GridKey(p_Item)
	return string.format("%.0f:%.0f", p_Item.Position.x // m_GridSize, p_Item.Position.y // m_GridSize)
end

---Custom Server PlayerEvents.PlayerConnected NetEvent
---@param p_Player Player
function OOCFiresServer:OnPlayerConnected(p_Player)
	m_Logger:Write("OnPlayerConnected")
	self:SendState(p_Player)
end

---Custom Server PhaseManagerEvent.Update Event
function OOCFiresServer:OnCircleUpdate()
	-- TODO
end

---Custom Server PhaseManagerEvent.CircleMove Event
---@param p_Circle Circle
function OOCFiresServer:OnCircleMove(p_Circle)
	p_Circle = Circle:FromTable(p_Circle)

	if not self:ShouldSpawnItems(p_Circle) then
		return
	end

	self.m_LastSpawnRadius = p_Circle.m_Radius
	local s_Positions = self:GetRandomCircumPositions(p_Circle, 16)
	self:AddItems(s_Positions)
end

---VEXT Shared Level:Destroy Event
function OOCFiresServer:OnLevelDestroy()
	self:ResetVars()
end

---VEXT Shared Extension:Unloading Event
function OOCFiresServer:OnExtensionUnloading()
	self:ResetVars()
end

return OOCFiresServer()
