class "OOCFires"

local m_Logger = Logger("OOCFires", true)

local m_Queue = require "__shared/Libs/Queue"

function OOCFires:__init()
	self:ResetVars()
	self:RegisterEvents()
end

function OOCFires:ResetVars()
	m_Queue:ResetVars()
	self.m_MaxEffectsNumber = self.m_MaxEffectsNumber or 128
end

function OOCFires:RegisterEvents()
	NetEvents:Subscribe("OOCF:State", self, self.OnReceiveState)
	NetEvents:Subscribe("OOCF:SpawnItems", self, self.OnReceiveItems)
end

function OOCFires:SpawnItem(p_Item)
	local s_Blueprint = ResourceManager:SearchForInstanceByGuid(FireEffectsConfig.CustomEffectsGuid[p_Item.Effect])

	-- do a raycast to get the correct height
	local s_From = Vec3(p_Item.Position.x, 600.0, p_Item.Position.y)
	local s_To = Vec3(p_Item.Position.x, -600.0, p_Item.Position.y)
	local s_RaycastHit = RaycastManager:Raycast(s_From, s_To, RayCastFlags.DontCheckWater | RayCastFlags.DontCheckCharacter |
											RayCastFlags.DontCheckRagdoll)

	if s_RaycastHit == nil then
		-- wouldn't make any sense to spawn something at the default height
		return
	end

	local s_Transform = LinearTransform()
	s_Transform.trans = s_RaycastHit.position

	local s_Params = EntityCreationParams()
	s_Params.transform = s_Transform
	s_Params.networked = false

	if s_Blueprint == nil then
		m_Logger:Error("No blueprint")
		return
	end

	local s_EntityBus = EntityBus(EntityManager:CreateEntitiesFromBlueprint(s_Blueprint, s_Params))

	local s_SpawnedEntities = {}

	for _, l_Entity in pairs(s_EntityBus.entities) do
		l_Entity = Entity(l_Entity)
		l_Entity:Init(Realm.Realm_Client, true)

		table.insert(s_SpawnedEntities, l_Entity)

		l_Entity:FireEvent("Start")
		l_Entity:FireEvent("Enable")
	end

	-- add created entities in the queue
	m_Queue:Enqueue(s_SpawnedEntities)

	-- remove oldest fire if needed
	self:UnspawnOldest()
end

function OOCFires:UnspawnOldest(p_Forced)
	-- check if fire effects are over the limit
	if not p_Forced and m_Queue:Size() < self.m_MaxEffectsNumber then
		return
	end

	-- get oldest entities
	local s_Entities = m_Queue:Dequeue()
	if s_Entities == nil then
		return
	end

	-- remove each entity
	for i, l_Entity in ipairs(s_Entities) do
		l_Entity:FireEvent("Stop")
		l_Entity:FireEvent("Disable")

		-- destroy entity
		l_Entity:Destroy()

		-- clear reference
		s_Entities[i] = nil
	end
end

function OOCFires:UnspawnAll()
	while not m_Queue:IsEmpty() do
		self:UnspawnOldest(true)
	end
end

function OOCFires:OnReceiveState(p_State)
	-- remove all existing items
	self:UnspawnAll()

	self.m_MaxEffectsNumber = p_State.MaxEffectsNumber

	for _, l_Item in pairs(p_State.Items) do
		self:SpawnItem(l_Item)
	end
end

function OOCFires:OnReceiveItems(p_Items)
	for _, l_Item in pairs(p_Items) do
		self:SpawnItem(l_Item)
	end
end

function OOCFires:OnLevelDestroy()
	self:UnspawnAll()
	self:ResetVars()
end

function OOCFires:OnExtensionUnloading()
	self:UnspawnAll()
end

if g_OOCFires == nil then
	g_OOCFires = OOCFires()
end

return g_OOCFires
