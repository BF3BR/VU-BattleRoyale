import { MapState } from "./Types";
import { 
    MapActionTypes,
    OPEN_MAP,
    SWITCH_OPEN_MAP,
    SHOW_MAP
} from "./ActionTypes";

const initialState: MapState = {
    show: false,
    open: false,
};

const MapReducer = (
    state = initialState,
    action: MapActionTypes
): MapState => {
    switch (action.type) {
        case OPEN_MAP:
            return {
                ...state,
                open: action.payload.open,
            };
        case SWITCH_OPEN_MAP:
            return {
                ...state,
                open: !state.open,
            };
        case SHOW_MAP:
            return {
                ...state,
                show: action.payload.show,
            };
        default:
            return state;
    }
};

export default MapReducer;
