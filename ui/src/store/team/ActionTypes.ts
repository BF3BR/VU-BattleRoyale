import Player from "../../helpers/PlayerHelper";

export const UPDATE_TEAM = "UPDATE_TEAM";
export const RESET_TEAM = "RESET_TEAM";

interface UpdateTeam {
    type: typeof UPDATE_TEAM;
    payload: { players: Player[] };
}

interface ResetTeam {
    type: typeof RESET_TEAM;
    payload: {};
}

export type TeamActionTypes = 
    | UpdateTeam
    | ResetTeam
;
