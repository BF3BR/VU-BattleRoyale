import { KillmsgState } from "./Types";
import { 
    KillmsgActionTypes,
    ADD_KILLMSG,
    RESET_KILLMSG
} from "./ActionTypes";

const initialState: KillmsgState = {
    killed: null,
    kills: null,
    enemyName: null,
};

const KillmsgReducer = (
    state = initialState,
    action: KillmsgActionTypes
): KillmsgState => {
    switch (action.type) {
        case ADD_KILLMSG:
            return {
                killed: action.payload.killed,
                kills: action.payload.kills,
                enemyName: action.payload.enemyName,
            };
        case RESET_KILLMSG:
            return initialState;
        default:
            return state;
    }
};

export default KillmsgReducer;
