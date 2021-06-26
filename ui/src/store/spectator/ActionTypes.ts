export const UPDATE_SPECTATOR_ENABLED = "UPDATE_SPECTATOR_ENABLED";
export const UPDATE_SPECTATOR_TARGET = "UPDATE_SPECTATOR_TARGET";
export const UPDATE_SPECTATOR_COUNT = "UPDATE_SPECTATOR_COUNT";

interface UpdateSpectatorEnabled {
    type: typeof UPDATE_SPECTATOR_ENABLED;
    payload: { enabled: boolean };
}

interface UpdateSpectatorTarget {
    type: typeof UPDATE_SPECTATOR_TARGET;
    payload: { target: string };
}

interface UpdateSpectatorCount {
    type: typeof UPDATE_SPECTATOR_COUNT;
    payload: { count: number | null };
}

export type SpectatorActionTypes = 
    | UpdateSpectatorEnabled
    | UpdateSpectatorTarget
    | UpdateSpectatorCount
;
