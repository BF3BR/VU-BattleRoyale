import { TeamState } from "./Types";
import { 
    TeamActionTypes,
    UPDATE_TEAM
} from "./ActionTypes";

const initialState: TeamState = {
    players: [],
};

const PlaneReducer = (
    state = initialState,
    action: TeamActionTypes
): TeamState => {
    switch (action.type) {
        case UPDATE_TEAM:
            return {
                ...state,
                players: action.payload.players,
            };
        default:
            return state;
    }
};

export default PlaneReducer;
