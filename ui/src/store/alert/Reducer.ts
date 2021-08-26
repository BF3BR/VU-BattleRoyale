import { AlertState } from "./Types";
import { 
    AlertActionTypes,
    ADD_ALERT,
} from "./ActionTypes";
import { Sounds } from "../../helpers/SoundsHelper";

const initialState: AlertState = {
    message: "",
    duration: 4,
    sound: Sounds.None,
    date: null,
};

const AlertReducer = (
    state = initialState,
    action: AlertActionTypes
): AlertState => {
    switch (action.type) {
        case ADD_ALERT:
            return {
                message: action.payload.message,
                duration: action.payload.duration ?? 4,
                sound: action.payload.sound ?? Sounds.None,
                date: action.payload.date,
            };
        default:
            return state;
    }
};

export default AlertReducer;
