import { 
    GameActionTypes,
    RESET_GAME,
    SWITCH_DEPLOY_SCREEN,
    UPDATE_COMMO_ROSE,
    UPDATE_DEPLOY_SCREEN,
    UPDATE_DEPLOY_TEAM,
    UPDATE_GAMEOVER,
    UPDATE_GAME_STATE,
    UPDATE_MIN_PLAYERS,
    UPDATE_PLAYERS,
    UPDATE_TIME,
    UPDATE_UI_STATE
} from "./ActionTypes";

export function updateGameState(gameState: string): GameActionTypes {
    return {
        type: UPDATE_GAME_STATE,
        payload: { gameState },
    };
}

export function updateUiState(uiState: "hidden" | "loading" | "game" | "menu"): GameActionTypes {
    return {
        type: UPDATE_UI_STATE,
        payload: { uiState },
    };
}

export function updateGameover(enabled?: boolean, win?: boolean, place?: number, team?: any): GameActionTypes {
    return {
        type: UPDATE_GAMEOVER,
        payload: { 
            enabled,
            win,
            place,
            team,
        },
    };
}

export function updateTime(time: number|null): GameActionTypes {
    return {
        type: UPDATE_TIME,
        payload: { time },
    };
}

export function updateMinPlayers(minPlayersToStart: number|null): GameActionTypes {
    return {
        type: UPDATE_MIN_PLAYERS,
        payload: { minPlayersToStart },
    };
}

export function updatePlayers(alive?: number, dead?: number, all?: number): GameActionTypes {
    return {
        type: UPDATE_PLAYERS,
        payload: { 
            alive,
            dead,
            all
        },
    };
}

export function updateDeployScreen(enabled: boolean): GameActionTypes {
    return {
        type: UPDATE_DEPLOY_SCREEN,
        payload: { enabled },
    };
}

export function switchDeployScreen(): GameActionTypes {
    return {
        type: SWITCH_DEPLOY_SCREEN,
        payload: {},
    };
}

export function updateDeployTeam(
    teamId?: string, 
    teamSize?: number,
    teamLocked?: boolean,
    teamJoinError?: number|null
): GameActionTypes {
    return {
        type: UPDATE_DEPLOY_TEAM,
        payload: { 
            teamId,
            teamSize,
            teamLocked,
            teamJoinError
        },
    };
}

export function updateCommoRose(show: boolean): GameActionTypes {
    return {
        type: UPDATE_COMMO_ROSE,
        payload: { show },
    };
}

export function resetGame(): GameActionTypes {
    return {
        type: RESET_GAME,
        payload: {},
    };
}
