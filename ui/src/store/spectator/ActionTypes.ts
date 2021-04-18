export const UPDATE_SPECTATOR_ENABLED = "UPDATE_SPECTATOR_ENABLED";
export const UPDATE_SPECTATOR_TARGET = "UPDATE_SPECTATOR_TARGET";

interface UpdateSpectatorEnabled {
    type: typeof UPDATE_SPECTATOR_ENABLED;
    payload: { enabled: boolean };
}

interface UpdateSpectatorTarget {
    type: typeof UPDATE_SPECTATOR_TARGET;
    payload: { target: string };
}

export type SpectatorActionTypes = 
    | UpdateSpectatorEnabled
    | UpdateSpectatorTarget
;
