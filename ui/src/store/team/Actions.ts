import Player from "../../helpers/PlayerHelper";
import { 
    RESET_TEAM,
    TeamActionTypes,
    UPDATE_TEAM,
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
