export const ADD_INTERACTIVEMSG = "ADD_INTERACTIVEMSG";

interface AddInteractivemsg {
    type: typeof ADD_INTERACTIVEMSG;
    payload: {
        message: string|null,
        key: string|null,
    };
}

export type InteractivemsgActionTypes = 
    | AddInteractivemsg
;
