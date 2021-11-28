import Player from "../../helpers/PlayerHelper";

export const UPDATE_TEAM = "UPDATE_TEAM";
export const UPDATE_SPEAKING = "UPDATE_SPEAKING";
export const UPDATE_MUTING = "UPDATE_MUTING";

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

interface UpdateMuting {
    type: typeof UPDATE_MUTING;
    payload: {
        playersName: string,
        isMuted: boolean,
    };
}

export type TeamActionTypes = 
    | UpdateTeam
    | UpdateSpeaking
    | UpdateMuting
;
