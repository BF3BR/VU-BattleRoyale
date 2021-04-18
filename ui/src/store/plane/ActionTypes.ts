import Vec3 from "../../helpers/Vec3Helper";

export const UPDATE_PLANE_POSITION = "UPDATE_PLAYER_POSITION";
export const UPDATE_PLANE_YAW = "UPDATE_PLAYER_YAW";

interface UpdatePlanePosition {
    type: typeof UPDATE_PLANE_POSITION;
    payload: { position: Vec3|null };
}

interface UpdatePlaneYaw {
    type: typeof UPDATE_PLANE_YAW;
    payload: { yaw: number };
}

export type PlaneActionTypes = 
    | UpdatePlanePosition
    | UpdatePlaneYaw
;
