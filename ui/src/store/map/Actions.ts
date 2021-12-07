import { 
    MapActionTypes,
    OPEN_MAP,
    RESET_MAP,
    SHOW_MAP,
    SWITCH_OPEN_MAP,
    SWITCH_ROTATION
} from "./ActionTypes";

export function openMap(open: boolean): MapActionTypes {
    return {
        type: OPEN_MAP,
        payload: { open },
    };
}

export function switchOpenMap(): MapActionTypes {
    return {
        type: SWITCH_OPEN_MAP,
        payload: {},
    };
}

export function showMap(show: boolean): MapActionTypes {
    return {
        type: SHOW_MAP,
        payload: { show },
    };
}

export function switchRotation(): MapActionTypes {
    return {
        type: SWITCH_ROTATION,
        payload: {},
    };
}

export function resetMap(): MapActionTypes {
    return {
        type: RESET_MAP,
        payload: {},
    };
}
