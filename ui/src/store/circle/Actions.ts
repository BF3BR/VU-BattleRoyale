import Circle from "../../helpers/CircleHelper";
import { 
    CircleActionTypes,
    RESET_CIRCLE,
    UPDATE_INNER_CIRLCE,
    UPDATE_OUTER_CIRLCE,
    UPDATE_SUBPHASE_INDEX
} from "./ActionTypes";

export function updateInnerCircle(circle: Circle|null): CircleActionTypes {
    return {
        type: UPDATE_INNER_CIRLCE,
        payload: { circle },
    };
}

export function updateOuterCircle(circle: Circle|null): CircleActionTypes {
    return {
        type: UPDATE_OUTER_CIRLCE,
        payload: { circle },
    };
}

export function updateSubphaseIndex(subPhaseIndex: number): CircleActionTypes {
    return {
        type: UPDATE_SUBPHASE_INDEX,
        payload: { subPhaseIndex },
    };
}

export function resetCircle(): CircleActionTypes {
    return {
        type: RESET_CIRCLE,
        payload: {},
    };
}
