import { TeamState } from "./Types";
import { 
    RESET_TEAM,
    TeamActionTypes,
    UPDATE_SPEAKING,
    UPDATE_TEAM,
    UPDATE_MUTING,
} from "./ActionTypes";
import Player from "../../helpers/PlayerHelper";

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
                players: action.payload.players.map((newPlayer) => {
                    const player = state.players.find((pl: Player) => pl.name === newPlayer.name);
                    if (player) {
                        return {
                            ...player,
                            ...newPlayer,
                        };
                    } else {
                        return newPlayer;
                    }
                }),
            };
        case RESET_TEAM:
            return initialState;
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
        case UPDATE_MUTING:
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
                        isMuted: action.payload.isMuted,
                    }
                })
            }
        default:
            return state;
    }
};

export default TeamReducer;
