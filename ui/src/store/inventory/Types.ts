import InventorySlot from "../../helpers/InventoryHelper";

export interface InventoryState {
    slots: Array<any>,
    overlayLoot: any,
    closeItems: Array<any>,
    progress: {
        slot: any,
        time: number|null,
    },
}
