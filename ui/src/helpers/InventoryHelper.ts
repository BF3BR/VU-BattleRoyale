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
