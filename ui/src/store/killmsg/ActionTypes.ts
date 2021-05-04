export const ADD_KILLMSG = "ADD_KILLMSG";

interface AddKillmsg {
    type: typeof ADD_KILLMSG;
    payload: {
        killed: boolean|null,
        kills: number|null,
        enemyName: string|null,
    };
}

export type KillmsgActionTypes = 
    | AddKillmsg
;
