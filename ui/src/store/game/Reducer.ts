import { GameState } from "./Types";
import { 
    GameActionTypes,
    SWITCH_DEPLOY_SCREEN,
    UPDATE_COMMO_ROSE,
    UPDATE_DEPLOY_APPEARANCE,
    UPDATE_DEPLOY_SCREEN,
    UPDATE_DEPLOY_TEAM,
    UPDATE_DEPLOY_TEAM_TYPE,
    UPDATE_GAMEOVER,
    UPDATE_GAME_STATE,
    UPDATE_MIN_PLAYERS,
    UPDATE_PLAYERS,
    UPDATE_TIME,
    UPDATE_UI_STATE
} from "./ActionTypes";

const initialState: GameState = {
    players: {
        alive: 0,
        dead: 0,
        all: 0,
        minPlayersToStart: null,
    },
    gameState: "None",
    uiState: "loading",
    time: 0,
    gameOver: {
        enabled: false,
        place: 99,
        win: false,
    },
    deployScreen: {
        enabled: false,
        selectedAppearance: 0,
        selectedTeamType: 1,
        teamId: "-",
        teamSize: 4,
        teamLocked: false,
        teamJoinError: null,
    },
    showCommoRose: false,
};

const GameReducer = (
    state = initialState,
    action: GameActionTypes
): GameState => {
    switch (action.type) {
        case UPDATE_GAME_STATE:
            return {
                ...state,
                gameState: action.payload.gameState,
            };
        case UPDATE_UI_STATE:
            return {
                ...state,
                uiState: action.payload.uiState,
            };
        case UPDATE_GAMEOVER:
            return {
                ...state,
                gameOver: {
                    ...state.gameOver,
                    enabled: action.payload.enabled ?? state.gameOver.enabled,
                    place: action.payload.place ?? state.gameOver.place,
                    win: action.payload.win ?? state.gameOver.win,
                },
            };
        case UPDATE_TIME:
            return {
                ...state,
                time: action.payload.time,
            };
        case UPDATE_MIN_PLAYERS:
            return {
                ...state,
                players: {
                    ...state.players,
                    minPlayersToStart: action.payload.minPlayersToStart,
                }
            };
        case UPDATE_PLAYERS:
            return {
                ...state,
                players: {
                    ...state.players,
                    alive: action.payload.alive ?? state.players.alive,
                    dead: action.payload.dead ?? state.players.dead,
                    all: action.payload.all ?? state.players.all,
                }
            };
        case UPDATE_DEPLOY_SCREEN:
            return {
                ...state,
                deployScreen: {
                    ...state.deployScreen,
                    enabled: action.payload.enabled,
                }
            };
        case SWITCH_DEPLOY_SCREEN:
            return {
                ...state,
                deployScreen: {
                    ...state.deployScreen,
                    enabled: !state.deployScreen.enabled,
                }
            };
        case UPDATE_DEPLOY_TEAM:
            return {
                ...state,
                deployScreen: {
                    ...state.deployScreen,
                    teamId: action.payload.teamId ?? state.deployScreen.teamId,
                    teamSize: action.payload.teamSize ?? state.deployScreen.teamSize,
                    teamLocked: action.payload.teamLocked ?? state.deployScreen.teamLocked,
                    teamJoinError: action.payload.teamJoinError !== undefined ? action.payload.teamJoinError : state.deployScreen.teamJoinError,
                }
            };
        case UPDATE_DEPLOY_APPEARANCE:
            return {
                ...state,
                deployScreen: {
                    ...state.deployScreen,
                    selectedAppearance: action.payload.selectedAppearance,
                }
            };
        case UPDATE_DEPLOY_TEAM_TYPE:
            return {
                ...state,
                deployScreen: {
                    ...state.deployScreen,
                    selectedTeamType: action.payload.selectedTeamType,
                }
            };
        case UPDATE_COMMO_ROSE:
            return {
                ...state,
                showCommoRose: action.payload.show,
            };
        default:
            return state;
    }
};

export default GameReducer;
