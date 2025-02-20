---@class BRLootPickupDatabaseShared
BRLootPickupDatabaseShared = class "BRLootPickupDatabaseShared"

function BRLootPickupDatabaseShared:__init()
	self:ResetVars()
end

function BRLootPickupDatabaseShared:ResetVars()
	-- A map of LootPickups `{id -> BRLootPickup}`
	---@type table<string, BRLootPickup>
	self.m_LootPickups = {}

	-- A map of GridCells used for proximity looting
	---@type BRLootGrid
	self.m_Grid = BRLootGrid(32)
end

---@param p_Id string
---@return BRLootPickup
function BRLootPickupDatabaseShared:GetById(p_Id)
	return self.m_LootPickups[p_Id]
end

---@param p_LootPickup BRLootPickup|nil
---@return boolean
function BRLootPickupDatabaseShared:Add(p_LootPickup)
	if p_LootPickup == nil or self:Contains(p_LootPickup) then
		return false
	end

	-- add to lootpickups
	self.m_LootPickups[p_LootPickup.m_Id] = p_LootPickup

	-- add to grid cell
	self.m_Grid:AddLootPickup(p_LootPickup)

	return true
end

---@param p_LootPickup BRLootPickup|nil
---@return boolean
function BRLootPickupDatabaseShared:Remove(p_LootPickup)
	if p_LootPickup == nil or not self:Contains(p_LootPickup) then
		return false
	end

	self.m_LootPickups[p_LootPickup.m_Id] = nil
	return true
end

---@param p_LootPickupId string
---@return boolean
function BRLootPickupDatabaseShared:RemoveById(p_LootPickupId)
	return self:Remove(self:GetById(p_LootPickupId))
end

---@param p_LootPickup BRLootPickup|nil
---@return boolean
function BRLootPickupDatabaseShared:Contains(p_LootPickup)
	return self.m_LootPickups[p_LootPickup ~= nil and p_LootPickup.m_Id] ~= nil
end

---@param p_LootPickupId string
---@return boolean
function BRLootPickupDatabaseShared:ContainsId(p_LootPickupId)
	return self.m_LootPickups[p_LootPickupId] ~= nil
end

---TODO
---@param p_Position Vec3
---@param p_Radius number
---@return table<string, BRLootPickup>
function BRLootPickupDatabaseShared:GetCloseLootPickups(p_Position, p_Radius)
	return {}
end

---@param p_Position Vec3
---@param p_Radius number
---@return BRLootPickup
function BRLootPickupDatabaseShared:GetClosestLootPickup(p_Position, p_Radius)
	local s_LootPickups = self:GetCloseLootPickups(p_Position, p_Radius)

	-- return the item at first index in case the items returned
	-- are empty or only have one item
	if #s_LootPickups < 2 then
		return s_LootPickups[1]
	end

	-- find the closest item
	local s_ClosestPickup = s_LootPickups[1]
	local s_ClosestDistance = p_Radius + 1.0

	for l_Index = 2, #s_LootPickups do
		local s_LootPickup = s_LootPickups[l_Index]
		local s_Distance = p_Position:Distance(s_LootPickup.m_Transform.trans)

		if s_Distance < s_ClosestDistance then
			s_ClosestPickup = s_LootPickup
			s_ClosestDistance = s_Distance
		end
	end

	return s_ClosestPickup
end

function BRLootPickupDatabaseShared:Destroy()
	self:ResetVars()
end

function BRLootPickupDatabaseShared:OnLevelDestroy()
	self:Destroy()
end

function BRLootPickupDatabaseShared:OnExtensionUnloaded()
	self:Destroy()
end
