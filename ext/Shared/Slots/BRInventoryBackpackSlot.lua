require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

local m_Logger = Logger("BRInventoryBackpackSlot", true)

class("BRInventoryBackpackSlot", BRInventorySlot)

function BRInventoryBackpackSlot:__init(p_Inventory)
    BRInventorySlot.__init(self, p_Inventory, { 
        ItemType.Attachment,
        ItemType.Ammo,
        ItemType.Consumable,
    })
end

function BRInventoryBackpackSlot:OnUpdate()
    m_Logger:Write("Backpack slot updated")
    self.m_Inventory:UpdateWeaponSecondaryAmmo()
end
