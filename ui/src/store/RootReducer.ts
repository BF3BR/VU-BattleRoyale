
import { combineReducers } from "redux";
import PlayerReducer from "./player/Reducer";
import PingReducer from "./ping/Reducer";
import MapReducer from "./map/Reducer";
import PlaneReducer from "./plane/Reducer";
import CircleReducer from "./circle/Reducer";
import TeamReducer from "./team/Reducer";
import SpectatorReducer from "./spectator/Reducer";
import GameReducer from "./game/Reducer";
import AlertReducer from "./alert/Reducer";
import KillmsgReducer from "./killmsg/Reducer";
import InteractivemsgReducer from "./interactivemsg/Reducer";

export const RootReducer = combineReducers({
    PlayerReducer,
    PingReducer,
    MapReducer,
    PlaneReducer,
    CircleReducer,
    TeamReducer,
    SpectatorReducer,
    GameReducer,
    AlertReducer,
    KillmsgReducer,
    InteractivemsgReducer,
});

export type RootState = ReturnType<typeof RootReducer>;
