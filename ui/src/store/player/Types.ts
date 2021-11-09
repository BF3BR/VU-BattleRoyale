import Player from "../../helpers/PlayerHelper";

export interface PlayerState {
    hud: {
        health: number,
        armor: number,
        helmet: number,
        primaryAmmo: number,
        secondaryAmmo: number,
        fireLogic: string,
        currentWeapon: string,
    },
    isOnPlane: boolean,
    player: Player,
    isCtrlDown: boolean,
}
