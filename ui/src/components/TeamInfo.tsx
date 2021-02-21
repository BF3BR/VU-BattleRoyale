import React from "react";

import Timer from "./Timer";

import { Player, Color } from "../helpers/Player";

import "./MatchInfo.scss";

interface Props {
    players: Player[]|null;
}

const TeamInfo: React.FC<Props> = ({ players }) => {

    return (
        <>
            <div id="TeamInfo">
                {players.map((player: Player, index: number) => (
                    <div className={"player " + "color-" + player.color.toString()} key={index}>
                        <span className="icon"></span>
                        <span className="icon">{player.name??''}</span>
                    </div>
                ))}
            </div>
        </>
    );
};

export default TeamInfo;
