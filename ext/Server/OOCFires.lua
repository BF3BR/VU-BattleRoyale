class "OOCFires"

local m_Logger = Logger("OOCFires", true)

local m_MaxEffectsNumber = 256
local m_GridSize = 16

function OOCFires:__init()
	self.m_Queue = Queue()

	self:ResetVars()
	self:RegisterEvents()
end

function OOCFires:ResetVars()
	self.m_Queue:ResetVars()
	self.m_LastSpawnRadius = 0

	-- use spawn grid to avoid spawning effects too close
	self.m_SpawnGrid = {}
end

function OOCFires:RegisterEvents()
	Events:Subscribe(PhaseManagerEvent.Update, self, self.OnCircleUpdate)
	Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnCircleMove)
end

function OOCFires:GetRandomCircumPositions(p_Circle, p_Num)
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

function OOCFires:ShouldSpawnItems(p_Circle)
	-- return MathUtils:GetRandom(0, 1) > 0.999
	return math.abs(self.m_LastSpawnRadius - p_Circle.m_Radius) > 4
end

function OOCFires:AddItems(p_Positions)
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

function OOCFires:CanAddItem(p_Item)
	return not self.m_SpawnGrid[self:GridKey(p_Item)]
end

function OOCFires:GetRandomEffectIndex()
	local s_RandNum = MathUtils:GetRandom(0, 1)

	if s_RandNum > 0.3 then
		return 1
	else
		return 2
	end
end

function OOCFires:AddItem(p_Position)
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
function OOCFires:RemoveOldestItem(p_Force)
	p_Force = not (not p_Force)

	-- check if queue is over the limit
	if not p_Force and self.m_Queue:Size() <= m_MaxEffectsNumber then
		return
	end

	-- remove from queue
	local s_Item = self.m_Queue:Dequeue()
	if s_Item == nil then
		return
	end

	-- remove from grid
	self.m_SpawnGrid[self:GridKey(s_Item)] = nil
end

function OOCFires:SendState(p_Player)
	local s_State = {
		MaxEffectsNumber = m_MaxEffectsNumber,
		Items = self.m_Queue:AsList()
	}

	NetEvents:SendToLocal("OOCF:State", p_Player, s_State)
end

function OOCFires:GridKey(p_Item)
	return string.format("%.0f:%.0f", p_Item.Position.x // m_GridSize, p_Item.Position.y // m_GridSize)
end

function OOCFires:OnPlayerConnected(p_Player)
	m_Logger:Write("OnPlayerConnected")
	self:SendState(p_Player)
end

function OOCFires:OnCircleUpdate()
	-- TODO
end

function OOCFires:OnCircleMove(p_Circle)
	p_Circle = Circle:FromTable(p_Circle)

	if not self:ShouldSpawnItems(p_Circle) then
		return
	end

	self.m_LastSpawnRadius = p_Circle.m_Radius
	local s_Positions = self:GetRandomCircumPositions(p_Circle, 16)
	self:AddItems(s_Positions)
end

function OOCFires:OnLevelDestroy()
	self:ResetVars()
end

function OOCFires:OnExtensionUnloading()
	self:ResetVars()
end

if g_OOCFires == nil then
	g_OOCFires = OOCFires()
end

return g_OOCFires
