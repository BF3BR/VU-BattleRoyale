import { 
    InventoryActionTypes,
    UPDATE_INVENTORY,
    UPDATE_OVERLAY_LOOT,
    UPDATE_CLOSE_LOOT_PICKUP,
    UPDATE_PROGRESS,
    RESET_INVENTORY
} from "./ActionTypes";

export function updateInventory(slots: any[]): InventoryActionTypes {
    return {
        type: UPDATE_INVENTORY,
        payload: { slots },
    };
}

export function updateOverlayLoot(overlayLoot: any): InventoryActionTypes {
    return {
        type: UPDATE_OVERLAY_LOOT,
        payload: { overlayLoot },
    };
}

export function updateCloseLootPickup(items: any[]): InventoryActionTypes {
    return {
        type: UPDATE_CLOSE_LOOT_PICKUP,
        payload: { items },
    };
}

export function updateProgress(slot: any, time: number|null): InventoryActionTypes {
    return {
        type: UPDATE_PROGRESS,
        payload: { slot, time },
    };
}

export function resetInventory(): InventoryActionTypes {
    return {
        type: RESET_INVENTORY,
        payload: {},
    };
}
