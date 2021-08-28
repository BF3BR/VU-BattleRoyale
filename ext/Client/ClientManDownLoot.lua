class 'ClientManDownLoot'

local m_Logger = Logger("ClientManDownLoot", true)

-- =============================================
-- Custom (Net-)Events
-- =============================================

function ClientManDownLoot:OnUpdateLootPosition(p_IndexInBlueprint, p_Transform)
	m_Logger:Write("OnUpdateLootPosition")
	local s_EntityIterator = EntityManager:GetIterator('ClientInteractionEntity')
	local s_Entity = s_EntityIterator:Next()

	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)

		if s_Entity.transform == LinearTransform() and GameObjectData(s_Entity.bus.parentRepresentative).indexInBlueprint == p_IndexInBlueprint then
			s_Entity.transform = p_Transform
			break
		end

		s_Entity = s_EntityIterator:Next()
	end

	local s_Crate_01 = ObjectBlueprint(ResourceManager:FindInstanceByGuid(Guid('2A3E4EB5-DE56-11DD-AE2C-D53D253AEF63'), Guid('2A3E4EB6-DE56-11DD-AE2C-D53D253AEF63')))
	local s_Crate_01_Bus = EntityManager:CreateEntitiesFromBlueprint(s_Crate_01, p_Transform)

	if s_Crate_01_Bus == nil then
		m_Logger:Write("s_Crate_01_Bus is nil")
		return
	end

	for _, l_Entity in pairs(s_Crate_01_Bus.entities) do
		l_Entity:Init(Realm.Realm_Client, true, false)
	end
end

function ClientManDownLoot:OnLootInteractionFinished(p_ManDownLootTable)
	m_Logger:Write("OnLootInteractionFinished")
	-- Do stuff like open the ui
end

if g_ClientManDownLoot == nil then
	g_ClientManDownLoot = ClientManDownLoot()
end

return g_ClientManDownLoot
