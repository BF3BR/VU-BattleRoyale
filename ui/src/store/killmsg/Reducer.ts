import { KillmsgState } from "./Types";
import { 
    KillmsgActionTypes,
    ADD_KILLMSG
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
        default:
            return state;
    }
};

export default KillmsgReducer;
