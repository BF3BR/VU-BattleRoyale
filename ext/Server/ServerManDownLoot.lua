class 'ServerManDownLoot'

require "Types/BRPlayer"

function ServerManDownLoot:__init()
	self.m_ManDownLootTable = {}
	self.m_ManDownLootCount = 0
	Events:Subscribe(TeamManagerEvent.RegisterKill, self, self.OnRegisterKill)
end

-- =============================================
-- Events
-- =============================================

function ServerManDownLoot:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	self:RegisterLootInteractionCallback()
end
-- =============================================
-- Custom (Net-)Events
-- =============================================

function ServerManDownLoot:OnRegisterKill(p_Victim)
	self.m_ManDownLootCount = self.m_ManDownLootCount + 1
	local s_Transform = nil
	local s_IndexInBlueprint = nil
	local s_EntityIterator = EntityManager:GetIterator('ServerInteractionEntity')
	local s_Entity = s_EntityIterator:Next()
	while s_Entity do
		s_Entity = SpatialEntity(s_Entity)
		if s_Entity.transform == LinearTransform() and GameObjectData(s_Entity.bus.parentRepresentative).indexInBlueprint == 5555 + self.m_ManDownLootCount then
			s_Entity.transform = p_Victim.m_Player.corpse.transform
			s_Transform = s_Entity.transform:Clone()
			s_IndexInBlueprint = GameObjectData(s_Entity.bus.parentRepresentative).indexInBlueprint
			break
		end
		s_Entity = s_EntityIterator:Next()
	end
	-- We need to update the transform on the client as well
	NetEvents:BroadcastLocal(ManDownLootEvents.UpdateLootPosition, s_IndexInBlueprint, s_Transform)

	-- TODO: add all weapons, bullets, consumables etc. into a table
	self.m_ManDownLootTable[s_IndexInBlueprint] = {}
	for i, l_Weapon in pairs(p_Victim.m_Player.corpse.weaponsComponent.weapons) do
		if l_Weapon ~= nil then
			self.m_ManDownLootTable[s_IndexInBlueprint][i] = l_Weapon.name
		end
	end
end

function ServerManDownLoot:OnInteractionFinished(p_Entity, p_Event)
	local s_IndexInBlueprint = GameObjectData(p_Entity.bus.parentRepresentative).indexInBlueprint
	NetEvents:SendToLocal(ManDownLootEvents.OnInteractionFinished, p_Event.player, self.m_ManDownLootTable[s_IndexInBlueprint])
end

-- =============================================
-- Functions
-- =============================================

function ServerManDownLoot:RegisterLootInteractionCallback()
	local s_EntityIterator = EntityManager:GetIterator('EventSplitterEntity')
	local s_Entity = s_EntityIterator:Next()
	while s_Entity do
		s_Entity = Entity(s_Entity)
		if s_Entity.data.instanceGuid == Guid('1E1023F4-EACC-7E35-048B-58B3D32D51D0') then
			s_Entity:RegisterEventCallback(self, self.OnInteractionFinished)
		end
		s_Entity = s_EntityIterator:Next()
	end
end

if g_ServerManDownLoot == nil then
	g_ServerManDownLoot = ServerManDownLoot()
end

return g_ServerManDownLoot
