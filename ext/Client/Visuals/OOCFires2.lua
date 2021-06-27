require "__shared/Libs/Queue"
require "__shared/Types/Circle"
require "__shared/Utils/RaycastHelper"

class "OOCFires2"

local m_Logger = Logger("OOCFires2", true)

function OOCFires2:__init()
    self:ResetVars()
    self:RegisterEvents()
end

function OOCFires2:ResetVars()
    self.m_Queue = Queue()
    self.m_MaxEffectsNumber = self.m_MaxEffectsNumber or 128
end

function OOCFires2:RegisterEvents()
    NetEvents:Subscribe("OOCF:State", self, self.OnReceiveState)
    NetEvents:Subscribe("OOCF:SpawnItems", self, self.OnReceiveItems)

    Events:Subscribe("Level:Destroy", self, self.OnLevelDestroy)
end

function OOCFires2:UnspawnItem(p_Item)
    
end

function OOCFires2:SpawnItem(p_Position)
    local l_Blueprint = EffectBlueprint(ResourceManager:SearchForInstanceByGuid(
                                            Guid("392D298D-CD2D-498F-AF2E-2C2F5B2AF137")))

    -- convert to 3d position
    p_Position = Vec3(p_Position.x, 0, p_Position.y)
    p_Position.y = g_RaycastHelper:GetY(p_Position, 600)

    local l_Transform = LinearTransform()
    l_Transform.trans = p_Position

    local l_Params = EntityCreationParams()
    l_Params.transform = l_Transform
    l_Params.networked = false

    if l_Blueprint ~= nil then
        local l_EntityBus = EntityBus(EntityManager:CreateEntitiesFromBlueprint(l_Blueprint, l_Params))

        local l_SpawnedEntities = {}

        for _, l_Entity in pairs(l_EntityBus.entities) do
            l_Entity = Entity(l_Entity)
            l_Entity:Init(Realm.Realm_Client, true)

            table.insert(l_SpawnedEntities, l_Entity)

            l_Entity:FireEvent("Start")
            l_Entity:FireEvent("Enable")
        end

        -- add created entities in the queue
        self.m_Queue:Enqueue(l_SpawnedEntities)

        -- remove oldest fire if needed
        self:UnspawnOldest()
    else
        m_Logger:Error("No blueprint")
    end
end

function OOCFires2:UnspawnOldest(p_Forced)
    -- check if fire effects are over the limit
    if not p_Forced and self.m_Queue:Size() < self.m_MaxEffectsNumber then
        return
    end

    -- get oldest entities
    local l_Entities = self.m_Queue:Dequeue()
    if l_Entities == nil then
        return
    end

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

function OOCFires2:UnspawnAll()
    while not self.m_Queue:IsEmpty() do
        self:UnspawnOldest(true)
    end
end

function OOCFires2:OnReceiveState(p_State)
    -- remove all existing items
    self:UnspawnAll()

    self.m_MaxEffectsNumber = p_State.MaxEffectsNumber

    for _, l_Item in pairs(p_State.Items) do
        self:SpawnItem(l_Item)
    end
end

function OOCFires2:OnReceiveItems(p_Items)
    for _, l_Item in pairs(p_Items) do
        self:SpawnItem(l_Item)
    end
end

function OOCFires2:OnLevelDestroy()
    self:UnspawnAll()
    self:ResetVars()
end

OOCFires2()
