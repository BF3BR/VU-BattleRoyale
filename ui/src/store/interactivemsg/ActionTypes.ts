export const ADD_INTERACTIVEMSG = "ADD_INTERACTIVEMSG";
export const RESET_INTERACTIVEMSG = "RESET_INTERACTIVEMSG";

interface AddInteractivemsg {
    type: typeof ADD_INTERACTIVEMSG;
    payload: {
        message: string|null,
        key: string|null,
    };
}

interface ResetInteractivemsg {
    type: typeof RESET_INTERACTIVEMSG;
    payload: {};
}

export type InteractivemsgActionTypes = 
    | AddInteractivemsg
    | ResetInteractivemsg
;
