class 'ClientManDownLoot'

local m_Logger = Logger("ClientManDownLoot", true)

function ClientManDownLoot:__init()
end

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
			return
		end
		s_Entity = s_EntityIterator:Next()
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
