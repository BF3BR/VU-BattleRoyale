import React from "react";

import Timer from "./Timer";

import { Player, Color } from "../helpers/Player";

import "./TeamInfo.scss";

interface Props {
    team: Player[] | null;
    deployScreen: boolean;
}

const TeamInfo: React.FC<Props> = ({ team, deployScreen }) => {

    return (
        <>
            <div id="TeamInfo" className={deployScreen ? "deployScreen" : ""}>
                {team.map((player: Player, index: number) => (
                    <div className={"TeamPlayer " + player.color.toString() + " " + (player.alive? "isAlive" : "isDead")} key={index}>
                        <div className="TeamPlayerName">
                            <span>{player.name ?? ''}</span>
                        </div>
                    </div>
                ))}
            </div>
        </>
    );
};

export default TeamInfo;
