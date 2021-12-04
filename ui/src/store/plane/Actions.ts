import Vec3 from "../../helpers/Vec3Helper";
import { 
    PlaneActionTypes,
    RESET_PLANE,
    UPDATE_PLANE_POSITION,
    UPDATE_PLANE_YAW,
} from "./ActionTypes";

export function updatePlanePosition(position: Vec3|null): PlaneActionTypes {
    return {
        type: UPDATE_PLANE_POSITION,
        payload: { position },
    };
}

export function updatePlaneYaw(yaw: number|null): PlaneActionTypes {
    return {
        type: UPDATE_PLANE_YAW,
        payload: { yaw },
    };
}

export function resetPlane(): PlaneActionTypes {
    return {
        type: RESET_PLANE,
        payload: {},
    };
}
