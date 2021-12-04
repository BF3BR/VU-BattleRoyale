import { PlaneState } from "./Types";
import { 
    PlaneActionTypes,
    RESET_PLANE,
    UPDATE_PLANE_POSITION,
    UPDATE_PLANE_YAW
} from "./ActionTypes";

const initialState: PlaneState = {
    position: null,
    yaw: null,
};

const PlaneReducer = (
    state = initialState,
    action: PlaneActionTypes
): PlaneState => {
    switch (action.type) {
        case UPDATE_PLANE_POSITION:
            return {
                ...state,
                position: action.payload.position,
            };
        case UPDATE_PLANE_YAW:
            return {
                ...state,
                yaw: action.payload.yaw,
            };
        case RESET_PLANE:
            return initialState;
        default:
            return state;
    }
};

export default PlaneReducer;
