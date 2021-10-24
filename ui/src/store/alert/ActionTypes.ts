import { Sounds } from "../../helpers/SoundsHelper";

export const ADD_ALERT = "ADD_ALERT";
export const RESET_ALERT = "RESET_ALERT";

interface AddAlert {
    type: typeof ADD_ALERT;
    payload: {
        message: string,
        duration: number,
        sound: Sounds,
        date: number|null,
    };
}

interface ResetAlert {
    type: typeof RESET_ALERT;
    payload: {};
}

export type AlertActionTypes = 
    | AddAlert
    | ResetAlert
;
