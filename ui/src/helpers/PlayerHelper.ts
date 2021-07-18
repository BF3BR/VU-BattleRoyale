import Vec3 from "./Vec3Helper";

export interface Player {
    name: string;
    kill: number;
    state: number;
    isTeamLeader: boolean;
    color?: string;
    position?: Vec3;
    yaw?: number;
    health?: number|null;
    armor?: number|null;
}

export const rgbaToRgb = (input: string) => {
    var colorVal = input.split("(")[1].split(")")[0].split(",");
    return "rgb(" + colorVal[0] + ", " + colorVal[1] + ", " + colorVal[2] + ")";
}

export default Player;
