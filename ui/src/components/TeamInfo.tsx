import React from "react";

import { Player, rgbaToRgb } from "../helpers/PlayerHelper";

import medic from "../assets/img/medic.svg";
import skull from "../assets/img/skull.svg";

import "./TeamInfo.scss";

interface Props {
    team: Player[] | null;
    deployScreen: boolean;
}

const TeamInfo: React.FC<Props> = ({ team, deployScreen }) => {

    const getStateIcon = (player: Player) => {
        switch (player.state) {
            default:
            case 1:
                return "";
            case 2:
                return <img src={medic} alt="Down" />;
            case 3:
                return <img src={skull} alt="Dead" />;
        }
    }

    return (
        <>
            <div id="TeamInfo" className={deployScreen ? "deployScreen" : ""}>
                {team.map((player: Player, index: number) => (
                    <div className={"TeamPlayer state" + player.state.toString()} style={{ color: rgbaToRgb(player.color), textShadow: "0 0 0.2vw " + player.color }} key={index}>
                        <div className="TeamPlayerName">
                            <span>
                                {player.name ?? ''}
                                {getStateIcon(player)}
                            </span>
                        </div>
                    </div>
                ))}
            </div>
        </>
    );
};

export default TeamInfo;
