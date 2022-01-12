local m_Logger = Logger("BRInventoryBackpackSlot", false)

---@class BRInventoryBackpackSlot : BRInventorySlot
BRInventoryBackpackSlot = class("BRInventoryBackpackSlot", BRInventorySlot)

function BRInventoryBackpackSlot:__init(p_Inventory)
	BRInventorySlot.__init(self, p_Inventory, {
		ItemType.Attachment,
		ItemType.Ammo,
		ItemType.Consumable,
	})

	self.m_Type = SlotType.Backpack
end

function BRInventoryBackpackSlot:OnSlotUpdate()
	m_Logger:Write("Backpack slot updated")
	self.m_Inventory:UpdateWeaponSecondaryAmmo()
end
