import { InteractivemsgState } from "./Types";
import { 
    InteractivemsgActionTypes,
    ADD_INTERACTIVEMSG,
    RESET_INTERACTIVEMSG
} from "./ActionTypes";

const initialState: InteractivemsgState = {
    message: null,
    key: null,
};

const InteractivemsgReducer = (
    state = initialState,
    action: InteractivemsgActionTypes
): InteractivemsgState => {
    switch (action.type) {
        case ADD_INTERACTIVEMSG:
            return {
                message: action.payload.message,
                key: action.payload.key,
            };
        case RESET_INTERACTIVEMSG:
            return initialState;
        default:
            return state;
    }
};

export default InteractivemsgReducer;
