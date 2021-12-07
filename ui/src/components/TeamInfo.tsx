import React from "react";
import { RootState } from "../store/RootReducer";
import { connect } from "react-redux";

import { Player, rgbaToRgb } from "../helpers/PlayerHelper";

import medic from "../assets/img/medic.svg";
import skull from "../assets/img/skull.svg";
import speaker from "../assets/img/speaker.svg";
import speaker_blue from "../assets/img/speaker_blue.svg";


import "./TeamInfo.scss";


interface StateFromReducer {
    team: Player[] | null;
    deployScreen: boolean;
}

type Props = StateFromReducer;

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

    const getVoiceIcon = (player: Player) => {
        switch (player.isSpeaking) {
            default:
            case 0:
                return "";
            case 1:
                return <img src={speaker} alt="Speaker" />;
            case 2:
                return <img src={speaker_blue} alt="Speaker (party)" />;
        }
    }

    return (
        <>
            {team.length > 1 &&
                <div id="TeamInfo" className={deployScreen ? "deployScreen" : ""}>
                    {team
                    .sort((a: Player, b: Player) => a.posInSquad - b.posInSquad)
                    .map((player: Player, index: number) => (
                        <div className={"TeamPlayer state" + player.state.toString()} key={index}>
                            <div className="TeamPlayerName">
                                <div className="index" style={{ background: rgbaToRgb(player.color) }}>
                                    {player.posInSquad??index}
                                </div>
                                <span style={{ color: rgbaToRgb(player.color), textShadow: "0 0 0.2vw " + player.color }}>
                                    {player.name ?? ''}
                                    {getStateIcon(player)}
                                </span>
                            </div>
                            {(player.health !== null && player.health > 0) &&
                                <div className="PercentageBg">
                                    <div className="PercentageFg" style={{width: player.health + "%"}}></div>
                                </div>
                            }
                            <div className="speaker">
                                {getVoiceIcon(player)}
                            </div>
                        </div>
                    ))}
                </div>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // TeamReducer
        team: state.TeamReducer.players,
        // GameReducer
        deployScreen: state.GameReducer.deployScreen.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(TeamInfo);
