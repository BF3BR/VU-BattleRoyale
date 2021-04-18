import Ping from "../../helpers/PingHelper";
import { 
    PingActionTypes,
    ADD_PING,
    REMOVE_PING
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
