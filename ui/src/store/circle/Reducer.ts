import { CircleState } from "./Types";
import { 
    CircleActionTypes,
    RESET_CIRCLE,
    UPDATE_INNER_CIRLCE,
    UPDATE_OUTER_CIRLCE,
    UPDATE_SUBPHASE_INDEX
} from "./ActionTypes";

const initialState: CircleState = {
    innerCircle: null,
    outerCircle: null,
    subPhaseIndex: 1,
};

const MapReducer = (
    state = initialState,
    action: CircleActionTypes
): CircleState => {
    switch (action.type) {
        case UPDATE_INNER_CIRLCE:
            return {
                ...state,
                innerCircle: action.payload.circle,
            };
        case UPDATE_OUTER_CIRLCE:
            return {
                ...state,
                outerCircle: action.payload.circle,
            };
        case UPDATE_SUBPHASE_INDEX:
            return {
                ...state,
                subPhaseIndex: action.payload.subPhaseIndex,
            };
        case RESET_CIRCLE:
            return initialState;
        default:
            return state;
    }
};

export default MapReducer;
