import { PlayerState } from "./Types";
import { 
    PlayerActionTypes,
    UPDATE_CTRL_DOWN,
    UPDATE_PLAYER_ARMOR,
    UPDATE_PLAYER_CURRENT_WEAPON,
    UPDATE_PLAYER_DATA,
    UPDATE_PLAYER_FIRELOGIC,
    UPDATE_PLAYER_HEALTH,
    UPDATE_PLAYER_IS_ON_PLANE,
    UPDATE_PLAYER_POSITION,
    UPDATE_PLAYER_PRIMARY_AMMO,
    UPDATE_PLAYER_SECONDARY_AMMO,
    UPDATE_PLAYER_YAW
} from "./ActionTypes";

const initialState: PlayerState = {
    hud: {
        health: 0,
        armor: 0,
        primaryAmmo: 0,
        secondaryAmmo: 0,
        fireLogic: "AUTO",
        currentWeapon: "",
    },
    isOnPlane: false,
    player: {
        name: "",
        kill: 0,
        state: 1,
        isTeamLeader: false,
        color: "rgba(255, 0, 0, 0.3)",
        position: null,
        yaw: null,
    },
    isCtrlDown: false,
};

const PlayerReducer = (
    state = initialState,
    action: PlayerActionTypes
): PlayerState => {
    switch (action.type) {
        case UPDATE_PLAYER_POSITION:
            return {
                ...state,
                player: {
                    ...state.player,
                    position: action.payload.position,
                },
            };
        case UPDATE_PLAYER_YAW:
            return {
                ...state,
                player: {
                    ...state.player,
                    yaw: action.payload.yaw,
                },
            };
        case UPDATE_PLAYER_IS_ON_PLANE:
            return {
                ...state,
                isOnPlane: action.payload.isOnPlane,
            };
        case UPDATE_PLAYER_HEALTH:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    health: action.payload.health,
                },
            };
        case UPDATE_PLAYER_ARMOR:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    armor: action.payload.armor,
                },
            };
        case UPDATE_PLAYER_PRIMARY_AMMO:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    primaryAmmo: action.payload.ammo,
                },
            };
        case UPDATE_PLAYER_SECONDARY_AMMO:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    secondaryAmmo: action.payload.ammo,
                },
            };
        case UPDATE_PLAYER_FIRELOGIC:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    fireLogic: action.payload.fireLogic,
                },
            };
        case UPDATE_PLAYER_CURRENT_WEAPON:
            return {
                ...state,
                hud: {
                    ...state.hud,
                    currentWeapon: action.payload.currentWeapon,
                },
            };
        case UPDATE_PLAYER_DATA:
            return {
                ...state,
                player: {
                    ...state.player,
                    name: action.payload.playerData.name ?? "",
                    kill: action.payload.playerData.kill ?? 0,
                    state: action.payload.playerData.state ?? 1,
                    isTeamLeader: action.payload.playerData.isTeamLeader ?? false,
                    color: action.payload.playerData.color ?? "rgba(255, 0, 0, 0.3)",
                },
            };
        case UPDATE_CTRL_DOWN:
            return {
                ...state,
                isCtrlDown: action.payload.isDown,
            };
        default:
            return state;
    }
};

export default PlayerReducer;
