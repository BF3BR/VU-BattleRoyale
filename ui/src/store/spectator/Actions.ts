import { 
    RESET_SPECTATOR,
    SpectatorActionTypes,
    UPDATE_SPECTATOR_COUNT,
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

export function updateSpectatorCount(count: number | null): SpectatorActionTypes {
    return {
        type: UPDATE_SPECTATOR_COUNT,
        payload: { count },
    };
}

export function resetSpectator(): SpectatorActionTypes {
    return {
        type: RESET_SPECTATOR,
        payload: {},
    };
}
