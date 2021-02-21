import React, { useState } from "react";
import { sendToLua } from "../Helpers";
import Player from "../helpers/Player";

import arrow from "../assets/img/arrow.svg";

import "./DeployScreen.scss";

const AppearanceArray = [
    "RU Woodland",
    "US Woodland",
    "RU Urban",
    "US Urban",
];

interface Props {
    setDeployScreen: (bool: boolean) => void;
    squad: Player[];
    squadSize: number;
}

const DeployScreen: React.FC<Props> = ({ setDeployScreen, squad, squadSize }) => {
    const [selectedAppearance, setSelectedAppearance] = useState<number>(0);

    const OnAppearanceRight = () => {
        if (selectedAppearance === AppearanceArray.length - 1) {
            setSelectedAppearance(0);
        } else {
            setSelectedAppearance(prevState => prevState + 1);
        }
    }

    const OnAppearanceLeft = () => {
        if (selectedAppearance === 0) {
            setSelectedAppearance(Object.keys(AppearanceArray).length - 1);
        } else {
            setSelectedAppearance(prevState => prevState - 1);
        }
    }

    const OnDeploy = () => {
        sendToLua('WebUI:Deploy');
        setDeployScreen(false);
    }

    const items = []
    for (let index = 0; index < (squadSize - squad.length); index++) {
        items.push(
            <div className="SquadPlayer empty">No player...</div>
        )
    }

    return (
        <div id="DeployScreen">
            <div className="DeployBox">
                <h1 className="PageTitle">Battle Royale</h1>
                <div className="card SquadBox">
                    <div className="card-header">
                        <h1>
                            Your Squad
                            <span>Code: <b>QWX994</b></span>
                        </h1>
                    </div>
                    <div className="card-content">
                        <div className="SquadPlayers">
                            {squad.map((player: Player, index: number) => (
                                <div className={"SquadPlayer " + player.color.toString()} key={index}>
                                    <div className="circle"></div>
                                    <span>{player.name??''}</span>
                                </div>
                            ))}
                            {items??''}
                        </div>
                    </div>
                </div>

                <div className="card SquadBox">
                    <div className="card-header">
                        <h1>
                            Join a squad
                        </h1>
                    </div>
                    <div className="card-content">
                        <div className="SquadForm">
                            <input type="text" placeholder="Enter a Code to join a squad..." />
                            <button className="btn btn-primary btn-small">
                                Join
                            </button>
                        </div>
                    </div>
                </div>

                <div className="card AppearanceBox SquadBox">
                    <div className="card-header">
                        <h1>Appearance</h1>
                    </div>
                    <div className="card-content">
                        <button onClick={OnAppearanceLeft}><img src={arrow} className="left" /></button>
                        <div className="AppearanceText">{AppearanceArray[selectedAppearance]}</div>
                        <button onClick={OnAppearanceRight}><img src={arrow} className="right" /></button>
                    </div>
                </div>

                <button className="btn btn-full-width Deploy" onClick={OnDeploy}>
                    Ready
                </button>
            </div>
        </div>
    );
};

export default DeployScreen;
