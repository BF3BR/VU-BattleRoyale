import { 
    MapActionTypes,
    OPEN_MAP,
    SHOW_MAP,
    SWITCH_OPEN_MAP
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
