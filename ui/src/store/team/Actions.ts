import Player from "../../helpers/PlayerHelper";
import { 
    RESET_TEAM,
    TeamActionTypes,
    UPDATE_TEAM,
    UPDATE_SPEAKING,
    UPDATE_MUTING,
} from "./ActionTypes";

export function updateTeam(players: Player[]): TeamActionTypes {
    return {
        type: UPDATE_TEAM,
        payload: { players },
    };
}

export function resetTeam(): TeamActionTypes {
    return {
        type: RESET_TEAM,
        payload: {},
    };
}

export function updateSpeaking(playersName: string, speaking: boolean, isParty: boolean): TeamActionTypes {
    return {
        type: UPDATE_SPEAKING,
        payload: { 
            playersName,
            speaking,
            isParty,
        },
    };
}

export function updateMuting(playersName: string, isMuted: boolean): TeamActionTypes {
    return {
        type: UPDATE_MUTING,
        payload: { 
            playersName,
            isMuted,
        },
    };
}
