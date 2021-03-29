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

local s_MaxFireEffects = 256

-- Out of Circle Fires
function OOCFires:__init()
    self.m_Queue = Queue()

    self.m_IsLoaded = false
    self.m_PrevRotation = 0
    self.m_LastRadius = 0

    self.m_OuterCircle = nil
    self.m_WasUpdated = false

    self:RegisterEvents()
end

function OOCFires:RegisterEvents()
    Events:Subscribe("Level:Loaded", self, self.OnLoad)
    Events:Subscribe("Level:Destroy", self, self.OnDestroy)

    Events:Subscribe(PhaseManagerEvent.CircleMove, self, self.OnCircleMove)
    Events:Subscribe("UpdatePass_PreSim", self, self.OnPresim)
end

function OOCFires:OnPresim(p_State)
    if not self.m_IsLoaded or not self.m_WasUpdated then
        return
    end

    self.m_WasUpdated = false

    m_Logger:Write("check if should spawn")
    if self:ShouldSpawn() then
        return
    end

    m_Logger:Write("about to spawn some fires")

    self:SpawnMany(6)

    -- -- rotation
    -- local l_Circle = Circle(self.m_OuterCircle.Center, self.m_OuterCircle.Radius)
    -- local l_PlusAngle = MathUtils:GetRandom(0.64, 0.96)
    -- self.m_PrevRotation = (self.m_PrevRotation + l_PlusAngle) % (2 * math.pi)

    -- -- position
    -- local l_Position = l_Circle:CircumferencePoint(self.m_PrevRotation)
    -- l_Position.y = g_RaycastHelper:GetY(l_Position, 600)

    -- -- spawn
    -- self:SpawnFire(l_Position)
end

function OOCFires:SpawnMany(p_Count)
    -- check distance from previous fire zone
    if math.abs(self.m_OuterCircle.Radius - self.m_LastRadius) < 3 then
        return
    end
    self.m_LastRadius = self.m_OuterCircle.Radius

    local l_AngleStep = 2 * math.pi / p_Count

    -- rotation
    local l_Circle = Circle(self.m_OuterCircle.Center, self.m_OuterCircle.Radius)
    local l_PlusAngle = MathUtils:GetRandom(0.64, 0.96)
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

function OOCFires:OnCircleMove(p_OuterCircle)
    self.m_OuterCircle = p_OuterCircle
    self.m_WasUpdated = true
end

function OOCFires:SpawnFire(p_Position)
    m_Logger:Write("Trying to spawn fire at:")
    m_Logger:Write(p_Position)

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
    if self.m_Queue:Size() < s_MaxFireEffects and not p_Forced then
        return
    end

    local l_Entities = self.m_Queue:Dequeue()
    if l_Entities == nil then
        return
    end

    m_Logger:Write("removing oldest entity")

    for i, l_Entity in ipairs(l_Entities) do
        l_Entity:FireEvent("Stop")
        l_Entity:FireEvent("Disable")

        -- destroy entity
        l_Entity:Destroy()

        -- clear reference
        l_Entities[i] = nil
    end
end

function OOCFires:OnLoad()
    self.m_IsLoaded = true
end

function OOCFires:OnDestroy()
    self.m_IsLoaded = false

    -- destroy entities
    while not self.m_Queue:IsEmpty() do
        self:DespawnOldest(true)
    end

    -- reset vars
    self.m_Queue = Queue()
    self.m_IsLoaded = false
    self.m_PrevRotation = 0
    self.m_OuterCircle = nil
    self.m_WasUpdated = false
end

-- define global
if g_OOCFires == nil then
    g_OOCFires = OOCFires()
end

return g_OOCFires
