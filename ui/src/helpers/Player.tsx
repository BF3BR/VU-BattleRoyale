export enum Color {
    White,
    Red,
    Blue,
    Green,
}

export interface Player {
    name: string;
    kill: number;
    state: number;
    color: Color;
    isTeamLeader: boolean;
}

export default Player;
