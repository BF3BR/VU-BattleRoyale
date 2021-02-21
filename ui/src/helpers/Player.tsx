export enum Color {
    White,
    Red,
    Blue,
    Green,
}

export interface Player {
    id?: number,
    name: string;
    kill: number;
    alive: boolean;
    color: Color;
}

export default Player;
