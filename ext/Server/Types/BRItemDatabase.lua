---@class BRItemDatabase
BRItemDatabase = class "BRItemDatabase"

---@type Logger
local m_Logger = Logger("BRItemDatabase", false)

function BRItemDatabase:__init()
	-- A table of items (id -> BRItem)
	---@type table<string, BRItemHelmet|BRItemAmmo|BRItemArmor|BRItemConsumable|BRItemAttachment|BRItemWeapon|BRItemGadget|BRItem>
	self.m_Items = {}
end

-- Returns an item from the database, by it's id
---@param p_Id string @it is a tostring(Guid)
---@return BRItemHelmet|BRItemAmmo|BRItemArmor|BRItemConsumable|BRItemAttachment|BRItemWeapon|BRItemGadget|BRItem|nil
function BRItemDatabase:GetItem(p_Id)
	return self.m_Items[p_Id]
end

-- All items should created using this methods from the database
-- to keep it's integrity
function BRItemDatabase:CreateItem(p_Definition, p_Quantity, p_Props)
	p_Quantity = p_Quantity or 1
	p_Props = p_Props or {}

	-- create data table
	local s_Table = {
		Id = self:GetRandomId(),
		UId = p_Definition.m_UId,
		Quantity = math.max(1, math.min(p_Definition.m_MaxStack or 1, p_Quantity))
	}

	-- extend and overwrite p_Props with s_Table data
	for l_Key, l_Value in pairs(s_Table) do p_Props[l_Key] = l_Value end

	-- create item instance and insert it to the items table
	local s_Item = BRItem:CreateFromTable(p_Props)
	self.m_Items[s_Item.m_Id] = s_Item

	-- m_Logger:Write("Item added to database. (" .. s_Item.m_Definition.m_Name .. ")")

	return s_Item
end

-- Removes and destroys an item from the item database
---@param p_Id string @it is a tostring(Guid)
function BRItemDatabase:UnregisterItem(p_Id)
	local s_Item = self:GetItem(p_Id)

	if s_Item == nil then
		return
	end

	-- clear reference and destroy
	self.m_Items[p_Id] = nil
	s_Item:Destroy()

	m_Logger:Write("Item removed from database. (" .. tostring(p_Id) .. ")")
end

-- Creates a new item by removing an
function BRItemDatabase:SplitItem(p_Id, p_QuantityToRemove)
	local s_Item = self:GetItem(p_Id)

	if s_Item == nil or not s_Item.m_Definition.m_Stackable or p_QuantityToRemove >= s_Item.m_Quantity then
		return nil
	end

	s_Item:DecreaseQuantityBy(p_QuantityToRemove)
	return self:CreateItem(s_Item.m_Definition, p_QuantityToRemove)
end

function BRItemDatabase:GetRandomId()
	-- for now use the guid string
	return tostring(MathUtils:RandomGuid())
end

return BRItemDatabase()
