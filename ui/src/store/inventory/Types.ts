import InventorySlot from "../../helpers/InventoryHelper";

export interface InventoryState {
    primaryWeapon: {
        weaponSlot: InventorySlot,
        attachmentSlot1: InventorySlot,
        attachmentSlot2: InventorySlot,
        attachmentSlot3: InventorySlot,
    },
    secondaryWeapon: {
        weaponSlot: InventorySlot,
        attachmentSlot1: InventorySlot,
        attachmentSlot2: InventorySlot,
        attachmentSlot3: InventorySlot,
    },
    backpack: Array<InventorySlot>,
    ammo: Array<InventorySlot>,
}
