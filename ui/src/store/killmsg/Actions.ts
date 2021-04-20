import { 
    KillmsgActionTypes,
    ADD_KILLMSG
} from "./ActionTypes";

export function addKillmsg(killed: boolean|null, kills: number|null, enemyName: string|null): KillmsgActionTypes {
    return {
        type: ADD_KILLMSG,
        payload: { 
            killed,
            kills,
            enemyName,
        },
    };
}
