require "__shared/Types/BRLootPickupDatabaseShared"

class ("BRLootPickupDatabase", BRLootPickupDatabaseShared)

function BRLootPickupDatabase:ResetVars()
	BRLootPickupDatabaseShared.ResetVars(self)

	self.m_InstanceIdToLootPickup = {}

	self.m_CachedCloseEntitiesUpdatedAt = 0
	self.m_CachedCloseEntities = {}
end

function BRLootPickupDatabase:GetByInstanceId(p_InstanceId)
	return self.m_InstanceIdToLootPickup[p_InstanceId]
end

function BRLootPickupDatabase:Add(p_LootPickup)
	if not BRLootPickupDatabaseShared.Add(self, p_LootPickup) then
		return false
	end

	-- TODO add required refs to grid

	-- add a reference in close entities too. It will be cleaned up in
	-- a bit if it's not close, anyways
	self.m_CachedCloseEntities[p_LootPickup.m_Id] = p_LootPickup

	self:CreateLootPickupEntities(p_LootPickup)
	return true
end

function BRLootPickupDatabase:Update(p_LootPickupData)
	local s_LootPickup = self:GetById(p_LootPickupData ~= nil and p_LootPickupData.Id)

	if s_LootPickup == nil then
		return nil
	end

	-- clear references to this LootPickup
	self:DestroyLootPickupEntities(s_LootPickup)

	-- update LootPickup data
	s_LootPickup:UpdateFromTable(p_LootPickupData)

	-- spawn LootPickup entities
	self:CreateLootPickupEntities(s_LootPickup)

	return s_LootPickup
end

function BRLootPickupDatabase:Remove(p_LootPickup)
	if not BRLootPickupDatabaseShared.Remove(self, p_LootPickup) then
		return false
	end

	-- clear it's reference from cached close items
	self.m_CachedCloseEntities[p_LootPickup.m_Id] = nil

	-- destroy entities for this LootPickup
	self:DestroyLootPickupEntities(p_LootPickup)
	p_LootPickup:Destroy()

	return true
end

-- override with a temporary solution for client
function BRLootPickupDatabase:GetCloseLootPickups(p_Position, p_Radius)
	if p_Position == nil then
		return
	end

	p_Radius = p_Radius or 3
	self:UpdateCachedCloseLootPickups(p_Position)

	-- search the LootPickups that are close (<= p_Radius)
	local s_CloseLootPickups = {}
	for _, l_LootPickup in pairs(self.m_CachedCloseEntities) do
		if l_LootPickup.m_Transform.trans:Distance(p_Position) <= p_Radius then
			s_CloseLootPickups[l_LootPickup.m_Id] = l_LootPickup
		end
	end

	return s_CloseLootPickups
end

function BRLootPickupDatabase:UpdateCachedCloseLootPickups(p_Position, p_CachedRadius)
	if p_Position == nil or SharedUtils:GetTime() - self.m_CachedCloseEntitiesUpdatedAt < 6 then
		return
	end

	p_CachedRadius = p_CachedRadius or 60
	s_Pos2D = Vec2(p_Position.x, p_Position.z)

	-- search the LootPickups that are inside the cache radius
	self.m_CachedCloseEntities = {}
	for _, l_LootPickup in pairs(self.m_LootPickups) do
		local s_LootPickupPos2D = Vec2(l_LootPickup.m_Transform.trans.x, l_LootPickup.m_Transform.trans.z)

		if s_LootPickupPos2D:Distance(s_Pos2D) <= p_CachedRadius then
			self.m_CachedCloseEntities[l_LootPickup.m_Id] = l_LootPickup
		end
	end

	self.m_CachedCloseEntitiesUpdatedAt = SharedUtils:GetTime()
end

function BRLootPickupDatabase:CreateLootPickupEntities(p_LootPickup)
	-- try to spawn entities for the LootPickup
	if not p_LootPickup:Spawn(p_LootPickup.m_Id) then
		return nil
	end

	-- map each entity spawned to the LootPickup
	for l_InstanceId, _ in pairs(p_LootPickup.m_Entities) do
		self.m_InstanceIdToLootPickup[l_InstanceId] = p_LootPickup
	end

	return p_LootPickup.m_Entities
end

function BRLootPickupDatabase:DestroyLootPickupEntities(p_LootPickup)
	-- clear references to this LootPickup
	for l_InstanceId, _ in pairs(p_LootPickup.m_Entities) do
		self.m_InstanceIdToLootPickup[l_InstanceId] = nil
	end

	p_LootPickup:DestroyEntities()
end

function BRLootPickupDatabase:UpdateGridSubscriptions()
	-- TODO
end

-- EVENT LISTENERS

function BRLootPickupDatabase:OnCreateLootPickup(p_LootPickupData)
	if p_LootPickupData == nil then
		return
	end

	local s_LootPickup = BRLootPickup:CreateFromTable(p_LootPickupData)
	self:Add(s_LootPickup)
end

function BRLootPickupDatabase:Destroy()
	for _, l_LootPickup in ipairs(self.m_LootPickups) do
		-- destroy entities and references to them
		self:DestroyLootPickupEntities(l_LootPickup)

		-- destroy LootPickups
		l_LootPickup:Destroy()
	end

	self:ResetVars()
end

return BRLootPickupDatabase()
