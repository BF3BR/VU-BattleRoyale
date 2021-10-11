require "__shared/Enums/ItemEnums"
require "__shared/Slots/BRInventorySlot"

class("BRInventoryHelmetSlot", BRInventorySlot)

function BRInventoryHelmetSlot:__init(p_Inventory)
    BRInventorySlot.__init(self, p_Inventory, { ItemType.Helmet })
end
