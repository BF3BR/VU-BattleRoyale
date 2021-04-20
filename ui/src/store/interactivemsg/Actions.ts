import { 
    InteractivemsgActionTypes,
    ADD_INTERACTIVEMSG
} from "./ActionTypes";

export function addInteractivemsg(message: string|null, key: string|null): InteractivemsgActionTypes {
    return {
        type: ADD_INTERACTIVEMSG,
        payload: { 
            message,
            key,
        },
    };
}
