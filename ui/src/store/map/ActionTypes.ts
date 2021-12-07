export const OPEN_MAP = "OPEN_MAP";
export const SWITCH_OPEN_MAP = "SWITCH_OPEN_MAP";
export const SHOW_MAP = "SHOW_MAP";
export const SWITCH_ROTATION = "SWITCH_ROTATION";
export const RESET_MAP = "RESET_MAP";

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

interface ResetMap {
    type: typeof RESET_MAP;
    payload: {};
}

export type MapActionTypes = 
    | OpenMap
    | SwitchOpenMap
    | ShowMap
    | SwitchRotation
    | ResetMap
;
