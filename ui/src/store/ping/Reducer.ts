import { PingState } from "./Types";
import { 
    PingActionTypes,
    ADD_PING,
    REMOVE_PING,
    UPDATE_PING,
    LAST_PING,
    RESET_PING
} from "./ActionTypes";
import Ping from "../../helpers/PingHelper";

const initialState: PingState = {
    pings: [],
    lastPing: null,
};

const PingReducer = (
    state = initialState,
    action: PingActionTypes
): PingState => {
    switch (action.type) {
        case ADD_PING:
            return {
                ...state,
                pings: [
                    ...state.pings,
                    action.payload.ping,
                ],
            };
        case REMOVE_PING:
            return {
                ...state,
                pings: state.pings.filter((ping: Ping, _: number) => ping.id !== action.payload.id),
            };
        case UPDATE_PING:
            return { 
                ...state, 
                pings: state.pings.map((ping: Ping, _: number) => ping.id === action.payload.id ? 
                    {
                        ...ping,
                        worldPos: {
                            ...ping.worldPos,
                            x: action.payload.x,
                            y: action.payload.y,
                        }
                    }
                : 
                    ping
                )
             }
        case LAST_PING:
            return {
                ...state,
                lastPing: action.payload.id,
            };
        case RESET_PING:
            return initialState;
        default:
            return state;
    }
};

export default PingReducer;
