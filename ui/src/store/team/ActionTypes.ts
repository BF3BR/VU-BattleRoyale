import Player from "../../helpers/PlayerHelper";

export const UPDATE_TEAM = "UPDATE_TEAM";
export const UPDATE_SPEAKING = "UPDATE_SPEAKING";

interface UpdateTeam {
    type: typeof UPDATE_TEAM;
    payload: { players: Player[] };
}

interface UpdateSpeaking {
    type: typeof UPDATE_SPEAKING;
    payload: {
        playersName: string,
        speaking: boolean,
        isParty: boolean,
    };
}

export type TeamActionTypes = 
    | UpdateTeam
    | UpdateSpeaking
;
