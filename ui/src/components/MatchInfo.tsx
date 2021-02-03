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
}

const MatchInfo: React.FC<Props> = ({ state, time, noMap, players, minPlayersToStart }) => {

    const getStateString = (state: string) => {
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
                return "Match";
            case "EndGame":
                return "Round restarts in";
        }
    }

    return (
        <>
            <div id="MatchInfo" className={noMap ? 'noMap' : ''}>
                <span className="MatchInfoState">
                    {getStateString(state)}
                </span>
                <span className="MatchInfoTimerOrPlayer">
                    {(state === 'None')
                    ?
                        <span>
                            {players !== null ? players.length : 0} / {minPlayersToStart??0}
                        </span> 
                    :
                        <Timer time={time} />
                    }
                </span>
            </div>
            
        </>
    );
};

export default MatchInfo;
