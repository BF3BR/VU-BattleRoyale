import { Sounds } from "../../helpers/SoundsHelper";
import { 
    AlertActionTypes,
    ADD_ALERT
} from "./ActionTypes";

export function addAlert(message: string, duration?: number, sound?: Sounds): AlertActionTypes {
    return {
        type: ADD_ALERT,
        payload: { 
            message,
            duration,
            sound
        },
    };
}
