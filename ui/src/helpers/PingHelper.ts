import Vec3 from "./Vec3Helper";

interface Ping {
    id: string;
    position: Vec3;
    color: string;
    worldPos: Vec3;
    type: number|null;
}

export default Ping;
