export const OPEN_MAP = "OPEN_MAP";
export const SWITCH_OPEN_MAP = "SWITCH_OPEN_MAP";
export const SHOW_MAP = "SHOW_MAP";
export const SWITCH_ROTATION = "SWITCH_ROTATION";

interface OpenMap {
    type: typeof OPEN_MAP;
    payload: { open: boolean };
}

interface SwitchOpenMap {
    type: typeof SWITCH_OPEN_MAP;
    payload: {};
}

interface ShowMap {
    type: typeof SHOW_MAP;
    payload: { show: boolean };
}

interface SwitchRotation {
    type: typeof SWITCH_ROTATION;
    payload: {};
}

export type MapActionTypes = 
    | OpenMap
    | SwitchOpenMap
    | ShowMap
    | SwitchRotation
;
