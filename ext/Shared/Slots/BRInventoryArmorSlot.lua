---@class BRInventoryArmorSlot : BRInventorySlot
---@field m_Item BRItemArmor
BRInventoryArmorSlot = class("BRInventoryArmorSlot", BRInventorySlot)

function BRInventoryArmorSlot:__init(p_Inventory)
	BRInventorySlot.__init(self, p_Inventory, { ItemType.Armor })

	self.m_Type = SlotType.Armor
	self.m_SendToSpectator = true
end
