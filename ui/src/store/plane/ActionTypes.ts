import Vec3 from "../../helpers/Vec3Helper";

export const UPDATE_PLANE_POSITION = "UPDATE_PLANE_POSITION";
export const UPDATE_PLANE_YAW = "UPDATE_PLANE_YAW";
export const RESET_PLANE = "RESET_PLANE";

interface UpdatePlanePosition {
    type: typeof UPDATE_PLANE_POSITION;
    payload: { position: Vec3|null };
}

interface UpdatePlaneYaw {
    type: typeof UPDATE_PLANE_YAW;
    payload: { yaw: number };
}

interface ResetPlane {
    type: typeof RESET_PLANE;
    payload: {};
}

export type PlaneActionTypes = 
    | UpdatePlanePosition
    | UpdatePlaneYaw
    | ResetPlane
;
