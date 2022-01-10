---@class BRInventorySlot
BRInventorySlot = class "BRInventorySlot"

local m_Logger = Logger("BRInventorySlot", true)
local m_ItemDatabase = require "Types/BRItemDatabase"

function BRInventorySlot:__init(p_Inventory, p_AcceptedTypes)
	---@type SlotType|integer
	self.m_Type = SlotType.Default
	---@type BRItem|nil
	self.m_Item = nil
	self.m_Inventory = p_Inventory
	self.m_AcceptedTypes = p_AcceptedTypes or {}
	self.m_IsUpdated = true
	self.m_SendToSpectator = false
end

-- Checks if the slot contains an item with the specified definition
function BRInventorySlot:IsOfDefinition(p_Definition)
	if self.m_Item ~= nil and self.m_Item.m_Definition:Equals(p_Definition) then
		return true
	end

	return false
end

-- Puts an item into the slot
function BRInventorySlot:Put(p_Item)
	if p_Item ~= nil then
		-- check if invalid item for this slot
		if not self:IsAccepted(p_Item) then
			return false, {p_Item}
		end

		-- check if the item is already equipped
		if p_Item:Equals(self.m_Item) then
			return true, {}
		end

		-- update item's owner
		p_Item.m_Owner = self
	end

	-- drop old stuff
	local s_DroppedItems = self:Drop()

	-- set new item
	self.m_Item = p_Item
	self.m_IsUpdated = true

	-- trigger the update event
	self:OnSlotUpdate()

	return true, s_DroppedItems
end

function BRInventorySlot:Drop(p_Quantity)
	if self.m_Item == nil then
		return {}
	end

	local s_DroppedItems = self:OnBeforeDrop()
	local s_CurrentItem = nil

	-- try to split the item if needed
	p_Quantity = tonumber(p_Quantity)
	if p_Quantity ~= nil and p_Quantity > 0 then
		s_CurrentItem = m_ItemDatabase:SplitItem(self.m_Item.m_Id, p_Quantity)
	end

	-- if nothing was split, remove the item from the slot
	if s_CurrentItem == nil then
		s_CurrentItem = self.m_Item
		self.m_Item = nil
	end

	s_CurrentItem.m_Owner = nil
	table.insert(s_DroppedItems, 1, s_CurrentItem)

	-- update slot state
	self.m_IsUpdated = true
	self:OnSlotUpdate()

	return s_DroppedItems
end

function BRInventorySlot:PutWithRelated(p_Items)
	-- default behavior is to :Put only the first item
	if p_Items ~= nil and #p_Items > 0 then
		return self:Put(p_Items[1])
	else
		return self:Clear()
	end
end

function BRInventorySlot:Clear()
	return self:Put(nil)
end

function BRInventorySlot:IsAccepted(p_Item)
	if p_Item == nil then
		return false
	end

	for _, l_Type in ipairs(self.m_AcceptedTypes) do
		if p_Item.m_Definition.m_Type == l_Type then
			return true
		end
	end

	return false
end

function BRInventorySlot:IsAvailable(p_Item)
	-- Check if type is not accepted
	if not self:IsAccepted(p_Item) then
		return false
	end

	-- Check if empty
	if self.m_Item == nil then
		return true
	end

	-- Check if item is stackable and slot contains same item type and has space
	if p_Item.m_Definition.m_Stackable and
		p_Item.m_Definition.m_MaxStack ~= nil and
		self.m_Item.m_Definition:Equals(p_Item.m_Definition) and
		self.m_Item.m_Quantity < p_Item.m_Definition.m_MaxStack then
		return true
	end

	return false
end

function BRInventorySlot:ResolveSlot(p_Item)
	if not self:IsAccepted(p_Item) then
		return nil
	end

	return self
end

function BRInventorySlot:GetOwner()
	return self.m_Inventory:GetOwnerPlayer()
end

function BRInventorySlot:AsTable()
	return {Item = self.m_Item ~= nil and self.m_Item:AsTable() or nil}
end

-- @Override
-- It's called before the item is about to be dropped. It can be used
-- to trigger related ammo drops. Returns the related items that were dropped
function BRInventorySlot:OnBeforeDrop()
	return {}
end

-- @Override
function BRInventorySlot:OnSlotUpdate()
	-- Empty
end

-- @Override
-- It's called before soldier customization starts happening, even
-- if that was triggered from unrelated slot. It's used to suppress
-- some side-effects caused by unrelated (to this slot) slot changes
function BRInventorySlot:BeforeCustomizationApply()
	-- Empty
end
