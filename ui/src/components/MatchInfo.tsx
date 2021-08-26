import React from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import Timer from "./helpers/Timer";
import Player from "../helpers/PlayerHelper";

import "./MatchInfo.scss";

interface StateFromReducer {
    state: string;
    time: number;
    noMap: boolean;
    players: number;
    minPlayersToStart: number;
    subPhaseIndex: number;
    spectating: boolean;
    deployScreen: boolean;
}

type Props = StateFromReducer;

const MatchInfo: React.FC<Props> = ({
    state,
    time,
    noMap,
    players,
    minPlayersToStart,
    subPhaseIndex,
    spectating,
    deployScreen
}) => {
    const getStateString = (state: string, subPhaseIndex: number) => {
        switch (state) {
            default:
            case "None":
                return "Waiting for players";
            case "Warmup":
            case "Before Plane":
                return "Warmup";
            case "Plane":
                return "Plane";
            case "Before Match":
            case "Match":
                if (subPhaseIndex === 1) {
                    return "Begins in";
                } else if (subPhaseIndex === 2) {
                    return "Waiting";
                } else {
                    return "Moving";
                }
            case "EndGame":
                return "Round restarts in";
        }
    }

    return (
        <>
            <div id="MatchInfo" className={"card" + ((noMap || spectating) ? ' noMap' : '') + (deployScreen ? ' deployScreen': '')}>
                <div className="card-header">
                    <h1>
                        {getStateString(state, subPhaseIndex)}
                        <span>
                            {(state === 'None')
                            ?
                                <>
                                    {players??0} / {minPlayersToStart??0}
                                </> 
                            :
                                <Timer time={time} />
                            }
                        </span>
                    </h1>
                </div>
            </div>
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // MapReducer
        noMap: state.MapReducer.open || !state.MapReducer.show,
        // GameReducer
        state: state.GameReducer.gameState,
        time: state.GameReducer.time,
        players: state.GameReducer.players.all,
        minPlayersToStart: state.GameReducer.players.minPlayersToStart,
        deployScreen: state.GameReducer.deployScreen.enabled,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
        // CircleReducer
        subPhaseIndex: state.CircleReducer.subPhaseIndex,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MatchInfo);
