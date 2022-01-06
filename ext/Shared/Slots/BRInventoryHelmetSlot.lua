---@class BRInventoryHelmetSlot : BRInventorySlot
BRInventoryHelmetSlot = class("BRInventoryHelmetSlot", BRInventorySlot)

function BRInventoryHelmetSlot:__init(p_Inventory)
	BRInventorySlot.__init(self, p_Inventory, { ItemType.Helmet })

	self.m_Type = SlotType.Helmet
	self.m_SendToSpectator = true
end
