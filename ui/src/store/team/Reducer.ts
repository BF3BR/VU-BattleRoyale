import { TeamState } from "./Types";
import { 
    RESET_TEAM,
    TeamActionTypes,
    UPDATE_TEAM
} from "./ActionTypes";

const initialState: TeamState = {
    players: [],
};

const TeamReducer = (
    state = initialState,
    action: TeamActionTypes
): TeamState => {
    switch (action.type) {
        case UPDATE_TEAM:
            return {
                ...state,
                players: action.payload.players,
            };
        case RESET_TEAM:
            return initialState;
        default:
            return state;
    }
};

export default TeamReducer;
