import { Sounds } from "../../helpers/SoundHelper";
import { 
    AlertActionTypes,
    ADD_ALERT,
    RESET_ALERT,
} from "./ActionTypes";

export function addAlert(message: string, duration?: number, sound?: Sounds): AlertActionTypes {
    return {
        type: ADD_ALERT,
        payload: { 
            message,
            duration,
            sound,
            date: Date.now(),
        },
    };
}

export function resetAlert(): AlertActionTypes {
    return {
        type: RESET_ALERT,
        payload: {},
    };
}
