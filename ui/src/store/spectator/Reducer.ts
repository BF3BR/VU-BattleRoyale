import { SpectatorState } from "./Types";
import { 
    SpectatorActionTypes,
    UPDATE_SPECTATOR_ENABLED,
    UPDATE_SPECTATOR_TARGET
} from "./ActionTypes";

const initialState: SpectatorState = {
    enabled: false,
    target: "",
};

const SpectatorReducer = (
    state = initialState,
    action: SpectatorActionTypes
): SpectatorState => {
    switch (action.type) {
        case UPDATE_SPECTATOR_ENABLED:
            return {
                ...state,
                enabled: action.payload.enabled,
            };
        case UPDATE_SPECTATOR_TARGET:
            return {
                ...state,
                target: action.payload.target,
            };
        default:
            return state;
    }
};

export default SpectatorReducer;
