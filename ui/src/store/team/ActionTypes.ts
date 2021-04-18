import Player from "../../helpers/PlayerHelper";

export const UPDATE_TEAM = "UPDATE_TEAM";

interface UpdateTeam {
    type: typeof UPDATE_TEAM;
    payload: { players: Player[] };
}

export type TeamActionTypes = 
    | UpdateTeam
;
