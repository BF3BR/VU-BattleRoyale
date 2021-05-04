import Ping from "../../helpers/PingHelper";

export const ADD_PING = "ADD_PING";
export const REMOVE_PING = "REMOVE_PING";

interface AddPing {
    type: typeof ADD_PING;
    payload: { ping: Ping };
}

interface RemovePing {
    type: typeof REMOVE_PING;
    payload: { id: string };
}

export type PingActionTypes = 
    | AddPing
    | RemovePing
;
