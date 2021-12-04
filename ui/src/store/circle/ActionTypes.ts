import Circle from "../../helpers/CircleHelper";

export const UPDATE_INNER_CIRLCE = "UPDATE_INNER_CIRLCE";
export const UPDATE_OUTER_CIRLCE = "UPDATE_OUTER_CIRLCE";
export const UPDATE_SUBPHASE_INDEX = "UPDATE_SUBPHASE_INDEX";
export const RESET_CIRCLE = "RESET_CIRCLE";

interface UpdateInnerCircle {
    type: typeof UPDATE_INNER_CIRLCE;
    payload: { circle: Circle|null };
}

interface UpdateOuterCircle {
    type: typeof UPDATE_OUTER_CIRLCE;
    payload: { circle: Circle|null };
}

interface UpdateSubphaseIndex {
    type: typeof UPDATE_SUBPHASE_INDEX;
    payload: { subPhaseIndex: number };
}

interface ResetCircle {
    type: typeof RESET_CIRCLE;
    payload: {};
}

export type CircleActionTypes = 
    | UpdateInnerCircle
    | UpdateOuterCircle
    | UpdateSubphaseIndex
    | ResetCircle
;
