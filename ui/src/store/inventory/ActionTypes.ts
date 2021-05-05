import Player from "../../helpers/PlayerHelper";

export const UPDATE_INVENTORY = "UPDATE_INVENTORY";

interface UpdateInventory {
    type: typeof UPDATE_INVENTORY;
    payload: { players: Player[] };
}

export type InventoryActionTypes = 
    | UpdateInventory
;
