import Vec3 from "../../helpers/Vec3Helper";

export const UPDATE_PLAYER_POSITION = "UPDATE_PLAYER_POSITION";
export const UPDATE_PLAYER_YAW = "UPDATE_PLAYER_YAW";
export const UPDATE_PLAYER_HEALTH = "UPDATE_PLAYER_HEALTH";
export const UPDATE_PLAYER_ARMOR = "UPDATE_PLAYER_ARMOR";
export const UPDATE_PLAYER_PRIMARY_AMMO = "UPDATE_PLAYER_PRIMARY_AMMO";
export const UPDATE_PLAYER_SECONDARY_AMMO = "UPDATE_PLAYER_SECONDARY_AMMO";
export const UPDATE_PLAYER_FIRELOGIC = "UPDATE_PLAYER_FIRELOGIC";
export const UPDATE_PLAYER_CURRENT_WEAPON = "UPDATE_PLAYER_CURRENT_WEAPON";
export const UPDATE_PLAYER_IS_ON_PLANE = "UPDATE_PLAYER_IS_ON_PLANE";
export const UPDATE_PLAYER_DATA = "UPDATE_PLAYER_DATA";
export const UPDATE_CTRL_DOWN = "UPDATE_CTRL_DOWN";
export const RESET_PLAYER = "RESET_PLAYER";

interface UpdatePlayerPosition {
    type: typeof UPDATE_PLAYER_POSITION;
    payload: { position: Vec3|null };
}

interface UpdatePlayerYaw {
    type: typeof UPDATE_PLAYER_YAW;
    payload: { yaw: number };
}

interface UpdatePlayerHealth {
    type: typeof UPDATE_PLAYER_HEALTH;
    payload: { health: number };
}

interface UpdatePlayerArmor {
    type: typeof UPDATE_PLAYER_ARMOR;
    payload: { armor: number };
}

interface UpdatePlayerPrimaryAmmo {
    type: typeof UPDATE_PLAYER_PRIMARY_AMMO;
    payload: { ammo: number };
}

interface UpdatePlayerSecondaryAmmo {
    type: typeof UPDATE_PLAYER_SECONDARY_AMMO;
    payload: { ammo: number };
}

interface UpdatePlayerFireLogic {
    type: typeof UPDATE_PLAYER_FIRELOGIC;
    payload: { fireLogic: string };
}

interface UpdatePlayerCurrentWeapon {
    type: typeof UPDATE_PLAYER_CURRENT_WEAPON;
    payload: { currentWeapon: string };
}

interface UpdatePlayerIsOnPlane {
    type: typeof UPDATE_PLAYER_IS_ON_PLANE;
    payload: { isOnPlane: boolean };
}

interface UpdatePlayerData {
    type: typeof UPDATE_PLAYER_DATA;
    payload: { playerData: any };
}

interface UpdateCtrlDown {
    type: typeof UPDATE_CTRL_DOWN;
    payload: { isDown: boolean };
}

interface ResetPlayer {
    type: typeof RESET_PLAYER;
    payload: {};
}

export type PlayerActionTypes = 
    | UpdatePlayerPosition
    | UpdatePlayerYaw
    | UpdatePlayerHealth
    | UpdatePlayerArmor
    | UpdatePlayerPrimaryAmmo
    | UpdatePlayerSecondaryAmmo
    | UpdatePlayerFireLogic
    | UpdatePlayerCurrentWeapon
    | UpdatePlayerIsOnPlane
    | UpdatePlayerData
    | UpdateCtrlDown
    | ResetPlayer
;
