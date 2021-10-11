require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

class("BRInventoryArmorSlot", BRInventorySlot)

function BRInventoryArmorSlot:__init(p_Inventory)
    BRInventorySlot.__init(self, p_Inventory, { ItemType.Armor })
end
