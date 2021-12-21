---@class BRItem
BRItem = class "BRItem"

local m_Logger = Logger("BRItem", true)
---@type BRItemFactory
local m_BRItemFactory = require "__shared/Utils/BRItemFactory"

---Creates a new BRItem
---@param p_Id string @It is a tostring(Guid)
---@param p_Definition BRItemDefinition @BRItemDefinition or something upcasted
---@param p_Quantity integer
function BRItem:__init(p_Id, p_Definition, p_Quantity)
	-- Unique Id for each item
	--
	-- It is a tostring(Guid)
	self.m_Id = p_Id ~= nil and p_Id or tostring(MathUtils:RandomGuid())

	-- Item's definition
	---manually upcasted in the other BRItem classes
	self.m_Definition = p_Definition

	-- Item's quantity
	self.m_Quantity = p_Quantity ~= nil and p_Quantity or 1

	-- The LootPickup or Slot that contains the item
	---@see done in: BRInventorySlot:Put(p_Item)
	---@type BRInventorySlot|nil
	self.m_Owner = nil
end

-- TODO: Recheck this m_Items & ContainsId seems wrong, also this function is unused
-- Returns the LootPickup instance that this item belongs to
--[[
function BRItem:GetParentLootPickup()
	if self.m_Owner == nil or self.m_Owner.m_Items == nil then
		return nil
	end

	-- make sure the loot pickup contains this item
	return self.m_Owner:ContainsId(self.m_Id) and self.m_Owner or nil
end
]]

-- Returns the BRInventorySlot instance that this item belongs to
function BRItem:GetParentSlot()
	if self.m_Owner == nil or self.m_Owner.m_Item == nil then
		return nil
	end

	-- make sure the slots item equal this item
	return self:Equals(self.m_Owner.m_Item) and self.m_Owner or nil
end

-- Returns the BRInventory instance that this item belongs to
function BRItem:GetParentInventory()
	local s_Slot = self:GetParentSlot()

	if s_Slot ~= nil then
		return s_Slot.m_Inventory
	end
end

-- Returns the Player instance that this item belongs to
function BRItem:GetParentPlayer()
	local s_Inventory = self:GetParentInventory()

	if s_Inventory ~= nil then
		return s_Inventory:GetOwnerPlayer()
	end
end

-- Mark the slot of this item as updated
function BRItem:SetUpdated()
	local s_Slot = self:GetParentSlot()
	if s_Slot ~= nil then
		s_Slot.m_IsUpdated = true
	end
end

-- Updates the quantity value for this item
function BRItem:SetQuantity(p_Quantity)
	local s_NewQuantity = math.max(0, math.min(self.m_Definition.m_MaxStack, p_Quantity))

	if not self.m_Definition.m_Stackable or self.m_Quantity == s_NewQuantity then
		return math.abs(p_Quantity)
	end

	self.m_Quantity = s_NewQuantity

	-- mark item's slot as updated
	self:SetUpdated()

	-- destroy item if quantity is 0
	if self.m_Quantity <= 0 then
		local s_Inventory = self:GetParentInventory()

		if s_Inventory ~= nil then
			s_Inventory:DestroyItem(self.m_Id)
		end
	end

	return math.abs(self.m_Quantity - p_Quantity)
end

function BRItem:IncreaseQuantityBy(p_Count)
	return self:SetQuantity(self.m_Quantity + p_Count)
end

function BRItem:DecreaseQuantityBy(p_Count)
	return self:SetQuantity(self.m_Quantity - p_Count)
end

function BRItem:IsOfType(p_Type)
	return self.m_Definition.m_Type == p_Type
end

function BRItem:AsTable(p_Extended)
	local s_Table = {
		Id = self.m_Id,
		UId = self.m_Definition.m_UId,
	}

	-- add quantity if item is stackable
	if p_Extended or self.m_Definition.m_Stackable then
		s_Table.Quantity = self.m_Quantity
	end

	-- add Definition data if Extended flag is true
	if p_Extended then
		s_Table.Name = self.m_Definition.m_Name
		s_Table.Type = self.m_Definition.m_Type
		s_Table.Description = self.m_Definition.m_Description
		s_Table.UIIcon = self.m_Definition.m_UIIcon
		s_Table.Price = self.m_Definition.m_Price
		s_Table.Quantity = self.m_Quantity
	end

	return s_Table
end

function BRItem:CreateFromTable(p_Table)
	return m_BRItemFactory:CreateFromTable(p_Table)
end

function BRItem:Equals(p_Item)
	return p_Item ~= nil and p_Item.m_Id == self.m_Id
end

function BRItem:Destroy()
	self.m_Definition = nil
	self.m_Owner = nil
end
