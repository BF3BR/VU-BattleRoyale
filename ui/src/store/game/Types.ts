export interface GameState {
    players: {
        alive: number;
        dead: number;
        all: number;
        minPlayersToStart: number;
    };
    gameState: string|null;
    uiState: "hidden" | "loading" | "game" | "menu";
    time: number|null;
    gameOver: {
        enabled: boolean;
        place: number;
        win: boolean;
        team: any;
    };
    deployScreen: {
        enabled: boolean;
        selectedAppearance: number;
        selectedTeamType: number;
        teamId: string;
        teamSize: number;
        teamLocked: boolean;
        teamJoinError: number|null;
    };
    showCommoRose: boolean;
}
