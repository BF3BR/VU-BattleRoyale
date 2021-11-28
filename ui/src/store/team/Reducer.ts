import { TeamState } from "./Types";
import { 
    TeamActionTypes,
    UPDATE_SPEAKING,
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
        case UPDATE_SPEAKING:
            return {
                ...state,
                players: state.players.map((player) => {
                    if (player.name !== action.payload.playersName) {
                        // This isn't the player we care about - keep it as-is
                        return player;
                    }
                
                    // Otherwise, this is the one we want - return an updated value
                    return {
                        ...player,
                        isSpeaking: action.payload.speaking ? (action.payload.isParty ? 2 : 1) : 0,
                    }
                })
            }
        default:
            return state;
    }
};

export default TeamReducer;
