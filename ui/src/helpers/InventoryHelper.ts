export interface InventoryItem {
    id: string;
    name: string;
    count: number;
    type: "weapon" | "attachment" | "backpack"; 
}

export interface InventorySlot {
    id: string;
    item: InventoryItem | null;
    accepts: Array<"weapon" | "attachment" | "backpack">;
}

export default InventorySlot;

export const getItemType = (itemTypeId: number) => {
    switch (itemTypeId) {
        default:
        case 1:
            return "Default";
        case 2:
            return "Weapon";
        case 3:
            return "Attachment";
        case 4:
            return "Ammo";
        case 5:
            return "Consumable";
        case 6:
            return "Armor";
        case 7:
            return "Helmet";
        case 8:
            return "Gadget";
    }
}
