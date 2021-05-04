import { 
    SpectatorActionTypes,
    UPDATE_SPECTATOR_ENABLED,
    UPDATE_SPECTATOR_TARGET,
} from "./ActionTypes";

export function updateSpectatorEnabled(enabled: boolean): SpectatorActionTypes {
    return {
        type: UPDATE_SPECTATOR_ENABLED,
        payload: { enabled },
    };
}

export function updateSpectatorTarget(target: string): SpectatorActionTypes {
    return {
        type: UPDATE_SPECTATOR_TARGET,
        payload: { target },
    };
}
