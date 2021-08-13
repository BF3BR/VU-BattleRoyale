import Ping from "../../helpers/PingHelper";

export interface PingState {
    pings: Ping[],
    lastPing: string|null,
}
