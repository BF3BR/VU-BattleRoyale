import { Sounds } from "../../helpers/SoundsHelper";

export const ADD_ALERT = "ADD_ALERT";

interface AddAlert {
    type: typeof ADD_ALERT;
    payload: {
        message: string,
        duration: number,
        sound: Sounds,
        date: number|null,
    };
}

export type AlertActionTypes = 
    | AddAlert
;
