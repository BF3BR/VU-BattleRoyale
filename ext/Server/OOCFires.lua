require "__shared/Libs/Queue"

class "OOCFires"

local m_Logger = Logger("OOCFires", true)

local s_MaxEffectsNumber = 256
local s_GridSize = 16

function OOCFires:__init()
    self:ResetVars()
    self:RegisterEvents()
end

function OOCFires:ResetVars()
    self.m_Queue = Queue()
    self.m_LastSpawnRadius = 0

    -- use spawn grid to avoid spawning effects too close
    self.m_SpawnGrid = {}
end

function OOCFires:RegisterEvents()
    NetEvents:Subscribe(PlayerEvents.PlayerConnected, self, self.OnPlayerConnected)
    Events:Subscribe(PhaseManagerEvent.Update, self, self.OnCircleUpdate)
    Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnCircleMove)

    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
end

function OOCFires:GetRandomCircumPositions(p_Circle, p_Num)
    local l_RandomAngle = MathUtils:GetRandom(0, 2 * math.pi)
    local l_AngleDiff = (2 * math.pi) / p_Num

    local l_Points = {}
    for l_Index = 1, p_Num do
        local l_Angle = l_RandomAngle + (l_Index * l_AngleDiff)
        local l_Pos = p_Circle:CircumferencePoint(l_Angle)

        table.insert(l_Points, Vec2(l_Pos.x, l_Pos.z))
    end

    return l_Points
end

function OOCFires:ShouldSpawnItems(p_Circle)
    -- return MathUtils:GetRandom(0, 1) > 0.999
    return math.abs(self.m_LastSpawnRadius - p_Circle.m_Radius) > 4
end

function OOCFires:AddItems(p_Positions)
    local l_AddedItems = {}

    -- try to all add new items
    for l_Index = 1, #p_Positions do
        -- add new item
        local l_Item = self:AddItem(p_Positions[l_Index])
        if l_Item ~= nil then
            table.insert(l_AddedItems, l_Item)

            -- remove oldest item
            self:RemoveOldestItem()
        end
    end

    -- send added items to players
    if #l_AddedItems > 0 then
        NetEvents:BroadcastLocal("OOCF:SpawnItems", l_AddedItems)
    end
end

function OOCFires:CanAddItem(p_Item)
    return not self.m_SpawnGrid[self:GridKey(p_Item)]
end

function OOCFires:GetRandomEffectIndex()
    local l_RandNum = MathUtils:GetRandom(0, 1)

    if l_RandNum > 0.3 then
        return 1
    else
        return 2
    end
end

function OOCFires:AddItem(p_Position)
    local l_Item = {
        Position = p_Position,
        Effect = self:GetRandomEffectIndex()
    }

    -- check if item should be added
    if not self:CanAddItem(l_Item) then
        return nil
    end

    -- add to queue and grid
    self.m_Queue:Enqueue(l_Item)
    self.m_SpawnGrid[self:GridKey(l_Item)] = true

    return l_Item
end

-- Removes the oldest item if the queue is above the limit
function OOCFires:RemoveOldestItem(p_Force)
    p_Force = not (not p_Force)

    -- check if queue is over the limit
    if not p_Force and self.m_Queue:Size() <= s_MaxEffectsNumber then
        return
    end

    -- remove from queue
    local l_Item = self.m_Queue:Dequeue()
    if l_Item == nil then
        return
    end

    -- remove from grid
    self.m_SpawnGrid[self:GridKey(l_Item)] = nil
end

function OOCFires:SendState(p_Player)
    local l_State = {
        MaxEffectsNumber = s_MaxEffectsNumber,
        Items = self.m_Queue:AsList()
    }

    NetEvents:SendToLocal("OOCF:State", p_Player, l_State)
end

function OOCFires:GridKey(p_Item)
    return string.format("%.0f:%.0f", p_Item.Position.x // s_GridSize, p_Item.Position.y // s_GridSize)
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
    local l_Positions = self:GetRandomCircumPositions(p_Circle, 16)
    self:AddItems(l_Positions)
end

function OOCFires:OnLevelLoaded()
    
end

function OOCFires:OnLevelDestroy()
    self:ResetVars()
end

OOCFires()
