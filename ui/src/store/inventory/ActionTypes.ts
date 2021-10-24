export const UPDATE_INVENTORY = "UPDATE_INVENTORY";
export const UPDATE_OVERLAY_LOOT = "UPDATE_OVERLAY_LOOT";
export const UPDATE_CLOSE_LOOT_PICKUP = "UPDATE_CLOSE_LOOT_PICKUP";
export const UPDATE_PROGRESS = "UPDATE_PROGRESS";
export const RESET_INVENTORY = "RESET_INVENTORY";

interface UpdateInventory {
    type: typeof UPDATE_INVENTORY;
    payload: { slots: any[] };
}

interface UpdateOverlayLoot {
    type: typeof UPDATE_OVERLAY_LOOT;
    payload: { overlayLoot: any };
}

interface UpdateCloseLootPickup {
    type: typeof UPDATE_CLOSE_LOOT_PICKUP;
    payload: { items: any[] };
}

interface UpdateProgress {
    type: typeof UPDATE_PROGRESS;
    payload: { 
        slot: any,
        time: number|null,
    };
}

interface ResetInventory {
    type: typeof RESET_INVENTORY;
    payload: {};
}

export type InventoryActionTypes = 
    | UpdateInventory
    | UpdateOverlayLoot
    | UpdateCloseLootPickup
    | UpdateProgress
    | ResetInventory
;
