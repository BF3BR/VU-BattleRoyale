import Player from "../../helpers/PlayerHelper";
import { 
    TeamActionTypes,
    UPDATE_TEAM,
} from "./ActionTypes";

export function updateTeam(players: Player[]): TeamActionTypes {
    return {
        type: UPDATE_TEAM,
        payload: { players },
    };
}
