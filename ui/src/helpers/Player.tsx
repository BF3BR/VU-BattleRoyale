import Vec3 from "./Vec3";

export interface Player {
    name: string;
    kill: number;
    state: number;
    isTeamLeader: boolean;
    color?: string;
    position?: Vec3;
    yaw?: number;
}

export default Player;
