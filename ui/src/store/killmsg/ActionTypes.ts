export const ADD_KILLMSG = "ADD_KILLMSG";
export const RESET_KILLMSG = "RESET_KILLMSG";

interface AddKillmsg {
    type: typeof ADD_KILLMSG;
    payload: {
        killed: boolean|null,
        kills: number|null,
        enemyName: string|null,
    };
}

interface ResetKillmsg {
    type: typeof RESET_KILLMSG;
    payload: {};
}

export type KillmsgActionTypes = 
    | AddKillmsg
    | ResetKillmsg
;
