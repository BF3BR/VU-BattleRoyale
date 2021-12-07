import { InventoryState } from "./Types";
import { 
    InventoryActionTypes,
    UPDATE_INVENTORY,
    UPDATE_OVERLAY_LOOT,
    UPDATE_CLOSE_LOOT_PICKUP,
    UPDATE_PROGRESS,
    RESET_INVENTORY
} from "./ActionTypes";

const initialState: InventoryState = {
    slots: [],
    overlayLoot: null,
    closeItems: [],
    progress: {
        slot: null,
        time: null,
    },
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
            return {
                ...state,
                closeItems: action.payload.items,
            };
        case UPDATE_PROGRESS:
            return {
                ...state,
                progress: {
                    slot: action.payload.slot,
                    time: action.payload.time,
                },
            }
        case RESET_INVENTORY:
            return initialState;
        default:
            return state;
    }
};

export default InventoryReducer;
