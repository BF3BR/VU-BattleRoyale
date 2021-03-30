require "__shared/Libs/Queue"
require "__shared/Types/Circle"
require "__shared/Utils/RaycastHelper"

class "OOCFires"

-- fire
-- FX/Ambient/Generic/FireSmoke/Fire/Generic/FX_Amb_Generic_Fire_L_01
-- EffectBlueprint
-- P 9798695A-DA55-46E4-9CAF-C9E393B43EC1
-- I 392D298D-CD2D-498F-AF2E-2C2F5B2AF137

local m_Logger = Logger("OOCFires", true)

local s_MaxFireEffects = 200
local s_RadiusDiff = 5
local s_MinFiresPerSpawn = 4
local s_MaxFiresPerSpawn = 8

-- Out of Circle Fires
function OOCFires:__init()
    self:ResetVars()
    self:RegisterEvents()
end

function OOCFires:ResetVars()
    self.m_Queue = Queue()

    self.m_IsLoaded = false
    self.m_PrevRotation = 0
    self.m_LastRadius = 0

    self.m_FiresPerSpawn = s_MaxFiresPerSpawn

    self.m_OuterCircle = nil
    self.m_WasUpdated = false
end

function OOCFires:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLevelLoaded)
    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)

    Events:Subscribe(PhaseManagerEvent.Update, self, self.OnCircleUpdate)
    Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnCircleMove)
    Events:Subscribe("UpdatePass_PreSim", self, self.OnPresim)
end

function OOCFires:OnPresim()
    if not self.m_IsLoaded or not self.m_WasUpdated then
        return
    end

    self.m_WasUpdated = false

    if self:ShouldSpawn() then
        return
    end

    self:SpawnMany(self.m_FiresPerSpawn)
end

function OOCFires:SpawnMany(p_Count)
    -- check distance from previous fire zone
    if math.abs(self.m_OuterCircle.Radius - self.m_LastRadius) < s_RadiusDiff then
        return
    end
    self.m_LastRadius = self.m_OuterCircle.Radius

    local l_AngleStep = 2 * math.pi / p_Count

    -- rotation
    local l_Circle = Circle(self.m_OuterCircle.Center, self.m_OuterCircle.Radius)
    local l_PlusAngle = MathUtils:GetRandom(l_AngleStep / 3, l_AngleStep / 2)
    self.m_PrevRotation = (self.m_PrevRotation + l_PlusAngle) % (2 * math.pi)

    -- spawn fires
    for i = 1, p_Count do
        local l_Rotation = self.m_PrevRotation + i * l_AngleStep

        -- position
        local l_Position = l_Circle:CircumferencePoint(l_Rotation)
        l_Position.y = g_RaycastHelper:GetY(l_Position, 600)

        -- spawn
        self:SpawnFire(l_Position)
    end
end

function OOCFires:OnCircleUpdate(p_State)
    local l_Min = 30
    local l_Max = 300
    local l_Radius = MathUtils:Clamp(p_State.OuterCircle.Radius, l_Min, l_Max)
    self.m_FiresPerSpawn = math.floor(MathUtils:Lerp(s_MinFiresPerSpawn, s_MaxFiresPerSpawn, (l_Radius - l_Min) / (l_Max - l_Min)))

    m_Logger:Write("m_FiresPerSpawn = " .. tostring(self.m_FiresPerSpawn))
end

function OOCFires:OnCircleMove(p_OuterCircle)
    self.m_OuterCircle = p_OuterCircle
    self.m_WasUpdated = true
end

function OOCFires:SpawnFire(p_Position)
    local l_Blueprint = EffectBlueprint(ResourceManager:SearchForInstanceByGuid(
                                            Guid("392D298D-CD2D-498F-AF2E-2C2F5B2AF137")))

    local l_Transform = LinearTransform()
    l_Transform.trans = p_Position

    local l_Params = EntityCreationParams()
    l_Params.transform = l_Transform
    l_Params.networked = false
    -- l_Params.variationNameHash = 0

    if l_Blueprint ~= nil then
        local l_EntityBus = EntityBus(EntityManager:CreateEntitiesFromBlueprint(l_Blueprint, l_Params))

        local l_SpawnedEntities = {}

        for _, l_Entity in pairs(l_EntityBus.entities) do
            l_Entity = Entity(l_Entity)
            l_Entity:Init(Realm.Realm_Client, true)

            table.insert(l_SpawnedEntities, l_Entity)

            l_Entity:FireEvent("Stop")
            l_Entity:FireEvent("Disable")

            l_Entity:FireEvent("Start")
            l_Entity:FireEvent("Enable")
        end

        -- add created entities in the queue
        self.m_Queue:Enqueue(l_SpawnedEntities)

        -- remove oldest fire if needed
        self:DespawnOldest()
    else
        m_Logger:Error("No blueprint")
    end
end

function OOCFires:ShouldSpawn()
    return MathUtils:GetRandom(0, 10) > 9.99
end

function OOCFires:DespawnOldest(p_Forced)
    -- check if fire effects are over the limit
    if self.m_Queue:Size() < s_MaxFireEffects and not p_Forced then
        return
    end

    -- get oldest entities
    local l_Entities = self.m_Queue:Dequeue()
    if l_Entities == nil then
        return
    end

    m_Logger:Write("removing oldest entity")

    -- remove each entity
    for i, l_Entity in ipairs(l_Entities) do
        l_Entity:FireEvent("Stop")
        l_Entity:FireEvent("Disable")

        -- destroy entity
        l_Entity:Destroy()

        -- clear reference
        l_Entities[i] = nil
    end
end

function OOCFires:OnLevelLoaded()
    self.m_IsLoaded = true
end

function OOCFires:OnLevelDestroy()
    self.m_IsLoaded = false

    -- destroy entities
    while not self.m_Queue:IsEmpty() do
        self:DespawnOldest(true)
    end

    self:ResetVars()
end

-- define global
if g_OOCFires == nil then
    g_OOCFires = OOCFires()
end

return g_OOCFires
