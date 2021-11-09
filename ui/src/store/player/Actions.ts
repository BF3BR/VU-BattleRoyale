import Vec3 from "../../helpers/Vec3Helper";
import { 
    PlayerActionTypes,
    UPDATE_PLAYER_POSITION,
    UPDATE_PLAYER_YAW,
    UPDATE_PLAYER_HEALTH,
    UPDATE_PLAYER_ARMOR,
    UPDATE_PLAYER_PRIMARY_AMMO,
    UPDATE_PLAYER_SECONDARY_AMMO,
    UPDATE_PLAYER_FIRELOGIC,
    UPDATE_PLAYER_CURRENT_WEAPON,
    UPDATE_PLAYER_IS_ON_PLANE,
    UPDATE_PLAYER_DATA,
    UPDATE_CTRL_DOWN,
    RESET_PLAYER,
    UPDATE_PLAYER_HELMET
} from "./ActionTypes";

export function updatePlayerPosition(position: Vec3|null): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_POSITION,
        payload: { position },
    };
}

export function updatePlayerYaw(yaw: number|null): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_YAW,
        payload: { yaw },
    };
}

export function updatePlayerHealth(health: number): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_HEALTH,
        payload: { health },
    };
}

export function updatePlayerArmor(armor: number): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_ARMOR,
        payload: { armor },
    };
}

export function updatePlayerHelmet(helmet: number): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_HELMET,
        payload: { helmet },
    };
}

export function updatePlayerPrimaryAmmo(ammo: number): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_PRIMARY_AMMO,
        payload: { ammo },
    };
}

export function updatePlayerSecondaryAmmo(ammo: number): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_SECONDARY_AMMO,
        payload: { ammo },
    };
}

export function updatePlayerFireLogic(fireLogic: string): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_FIRELOGIC,
        payload: { fireLogic },
    };
}

export function updatePlayerCurrentWeapon(currentWeapon: string): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_CURRENT_WEAPON,
        payload: { currentWeapon },
    };
}

export function updatePlayerIsOnPlane(isOnPlane: boolean): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_IS_ON_PLANE,
        payload: { isOnPlane },
    };
}

export function updatePlayerData(playerData: any): PlayerActionTypes {
    return {
        type: UPDATE_PLAYER_DATA,
        payload: { playerData },
    };
}

export function updateCtrlDown(isDown: boolean): PlayerActionTypes {
    return {
        type: UPDATE_CTRL_DOWN,
        payload: { isDown },
    };
}

export function resetPlayer(): PlayerActionTypes {
    return {
        type: RESET_PLAYER,
        payload: {},
    };
}
