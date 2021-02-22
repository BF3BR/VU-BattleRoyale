import React from "react";

import Timer from "./Timer";

import Player from "../helpers/Player";

import "./MatchInfo.scss";

interface Props {
    state: string;
    time: number|null;
    noMap: boolean;
    players: Player[]|null;
    minPlayersToStart: number|null;
    subPhaseIndex: number;
    spectating: boolean;
    deployScreen: boolean;
}

const MatchInfo: React.FC<Props> = ({ state, time, noMap, players, minPlayersToStart, subPhaseIndex, spectating, deployScreen }) => {

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
                                <span>
                                    {players !== null ? players.length : 0} / {minPlayersToStart??0}
                                </span> 
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

export default MatchInfo;
