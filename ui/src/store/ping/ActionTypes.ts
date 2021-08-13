import Ping from "../../helpers/PingHelper";

export const ADD_PING = "ADD_PING";
export const REMOVE_PING = "REMOVE_PING";
export const UPDATE_PING = "UPDATE_PING";
export const LAST_PING = "LAST_PING";

interface AddPing {
    type: typeof ADD_PING;
    payload: { ping: Ping };
}

interface RemovePing {
    type: typeof REMOVE_PING;
    payload: { id: string };
}

interface UpdatePing {
    type: typeof UPDATE_PING;
    payload: { id: string, x: number, y: number };
}

interface LastPing {
    type: typeof LAST_PING;
    payload: { id: string };
}

export type PingActionTypes = 
    | AddPing
    | RemovePing
    | UpdatePing
    | LastPing
;
