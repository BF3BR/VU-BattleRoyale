export const UPDATE_GAME_STATE = "UPDATE_GAME_STATE";
export const UPDATE_UI_STATE = "UPDATE_UI_STATE";
export const UPDATE_GAMEOVER = "UPDATE_GAMEOVER";
export const UPDATE_TIME = "UPDATE_TIME";
export const UPDATE_MIN_PLAYERS = "UPDATE_MIN_PLAYERS";
export const UPDATE_PLAYERS = "UPDATE_PLAYERS";
export const UPDATE_DEPLOY_SCREEN = "UPDATE_DEPLOY_SCREEN";
export const SWITCH_DEPLOY_SCREEN = "SWITCH_DEPLOY_SCREEN";
export const UPDATE_DEPLOY_TEAM = "UPDATE_DEPLOY_TEAM";
export const UPDATE_DEPLOY_APPEARANCE = "UPDATE_DEPLOY_APPEARANCE";
export const UPDATE_DEPLOY_TEAM_TYPE = "UPDATE_DEPLOY_TEAM_TYPE";
export const UPDATE_COMMO_ROSE = "UPDATE_COMMO_ROSE";

interface UpdateGameState {
    type: typeof UPDATE_GAME_STATE;
    payload: { gameState: string };
}

interface UpdateUiState {
    type: typeof UPDATE_UI_STATE;
    payload: { uiState: "hidden" | "loading" | "game" | "menu" };
}

interface UpdateGameover {
    type: typeof UPDATE_GAMEOVER;
    payload: { 
        enabled?: boolean;
        win?: boolean;
        place?: number;
    };
}

interface UpdateTime {
    type: typeof UPDATE_TIME;
    payload: { time: number|null };
}

interface UpdateMinPlayers {
    type: typeof UPDATE_MIN_PLAYERS;
    payload: { minPlayersToStart: number|null };
}

interface UpdatePlayers {
    type: typeof UPDATE_PLAYERS;
    payload: { 
        alive?: number;
        dead?: number;
        all?: number;
    };
}

interface UpdateDeployScreen {
    type: typeof UPDATE_DEPLOY_SCREEN;
    payload: { enabled: boolean };
}

interface SwitchDeployScreen {
    type: typeof SWITCH_DEPLOY_SCREEN;
    payload: {};
}

interface UpdateDeployTeam {
    type: typeof UPDATE_DEPLOY_TEAM;
    payload: {
        teamId?: string;
        teamSize?: number;
        teamLocked?: boolean;
        teamJoinError?: number|null;
    };
}

interface UpdateDeployAppearance {
    type: typeof UPDATE_DEPLOY_APPEARANCE;
    payload: {
        selectedAppearance: number;
    };
}

interface UpdateDeployTeamType {
    type: typeof UPDATE_DEPLOY_TEAM_TYPE;
    payload: {
        selectedTeamType: number;
    };
}

interface UpdateCommoRose {
    type: typeof UPDATE_COMMO_ROSE;
    payload: {
        show: boolean;
    };
}


export type GameActionTypes = 
    | UpdateGameState
    | UpdateUiState
    | UpdateGameover
    | UpdateTime
    | UpdateMinPlayers
    | UpdatePlayers
    | UpdateDeployScreen
    | SwitchDeployScreen
    | UpdateDeployTeam
    | UpdateDeployAppearance
    | UpdateDeployTeamType
    | UpdateCommoRose
;
