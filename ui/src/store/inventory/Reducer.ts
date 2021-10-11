import { InventoryState } from "./Types";
import { 
    InventoryActionTypes,
    UPDATE_INVENTORY,
    UPDATE_OVERLAY_LOOT,
    UPDATE_CLOSE_LOOT_PICKUP
} from "./ActionTypes";

const initialState: InventoryState = {
    slots: [],
    overlayLoot: null,
    closeItems: [],
};

const InventoryReducer = (
    state = initialState,
    action: InventoryActionTypes
): InventoryState => {
    switch (action.type) {
        case UPDATE_INVENTORY:
            return {
                ...state,
                slots: action.payload.slots,
            };
        case UPDATE_OVERLAY_LOOT:
            return {
                ...state,
                overlayLoot: action.payload.overlayLoot,
            };
        case UPDATE_CLOSE_LOOT_PICKUP:
            /*if (JSON.stringify(state.closeItems) !== JSON.stringify(action.payload.items)) {
                return {
                    ...state,
                    closeItems: action.payload.items,
                };
            }

            return state;*/
            return {
                ...state,
                closeItems: action.payload.items,
            };
        default:
            return state;
    }
};

export default InventoryReducer;
