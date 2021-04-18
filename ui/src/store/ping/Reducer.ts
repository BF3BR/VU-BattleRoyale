import { PingState } from "./Types";
import { 
    PingActionTypes,
    ADD_PING,
    REMOVE_PING
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
        default:
            return state;
    }
};

export default PingReducer;
