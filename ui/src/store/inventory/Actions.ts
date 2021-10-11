import { 
    InventoryActionTypes,
    UPDATE_INVENTORY,
    UPDATE_OVERLAY_LOOT,
    UPDATE_CLOSE_LOOT_PICKUP
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
