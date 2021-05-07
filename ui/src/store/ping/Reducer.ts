import { PingState } from "./Types";
import { 
    PingActionTypes,
    ADD_PING,
    REMOVE_PING,
    UPDATE_PING
} from "./ActionTypes";
import Ping from "../../helpers/PingHelper";

const initialState: PingState = {
    pings: [],
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
        default:
            return state;
    }
};

export default PingReducer;
