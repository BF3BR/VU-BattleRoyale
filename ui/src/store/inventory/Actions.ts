import Player from "../../helpers/PlayerHelper";
import { 
    InventoryActionTypes,
    UPDATE_INVENTORY,
} from "./ActionTypes";

export function updateInventory(players: Player[]): InventoryActionTypes {
    return {
        type: UPDATE_INVENTORY,
        payload: { players },
    };
}
