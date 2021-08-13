import Ping from "../../helpers/PingHelper";
import { 
    PingActionTypes,
    ADD_PING,
    REMOVE_PING,
    UPDATE_PING,
    LAST_PING
} from "./ActionTypes";

export function addPing(ping: Ping): PingActionTypes {
    return {
        type: ADD_PING,
        payload: { ping },
    };
}

export function removePing(id: string): PingActionTypes {
    return {
        type: REMOVE_PING,
        payload: { id },
    };
}

export function updatePing(id: string, x: number, y: number): PingActionTypes {
    return {
        type: UPDATE_PING,
        payload: { id, x, y },
    };
}

export function lastPing(id: string): PingActionTypes {
    return {
        type: LAST_PING,
        payload: { id },
    };
}
