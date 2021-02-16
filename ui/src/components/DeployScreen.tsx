import React, { useState } from "react";
import BrSelect from "./BrSelect";

import circle from "../assets/img/circle.svg";

import "./DeployScreen.scss";

const AppearanceArray = [
    {
        value: 0,
        label: "RU Woodland",
    },
    {
        value: 1,
        label: "US Woodland",
    },
    {
        value: 2,
        label: "RU Urban",
    },
    {
        value: 3,
        label: "US Urban",
    }
];

const DeployScreen: React.FC = () => {
    const [selectedAppearance, setSelectedAppearance] = useState<number>(0);

    const OnSelectAppearanceChange = (selected: string) => {
        setSelectedAppearance(parseInt(selected));
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
                            <div className="SquadPlayer white">
                                <div className="circle"></div>
                                <span>KVN</span>
                            </div>
                            <div className="SquadPlayer red">
                                <div className="circle"></div>
                                <span>Gaben</span>
                            </div>
                            <div className="SquadPlayer blue">
                                <div className="circle"></div>
                                <span>Hideo Kojima</span>
                            </div>
                            <div className="SquadPlayer green">
                                <div className="circle"></div>
                                <span>Snoop Dogg</span>
                            </div>
                            <div className="SquadPlayer empty">No player...</div>
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

                <div className="card AppearanceBox">
                    <div className="card-header">
                        <h1>Appearance</h1>
                    </div>
                    <div className="card-content">
                        <BrSelect 
                            options={AppearanceArray} 
                            onChangeSelected={(selected: string) => OnSelectAppearanceChange(selected)}
                            selectValue={{
                                value: AppearanceArray[selectedAppearance].value,
                                label: AppearanceArray[selectedAppearance].label,
                            }}
                        />
                    </div>
                </div>

                <button className="btn btn-full-width Deploy">
                    Ready
                </button>
            </div>
        </div>
    );
};

export default DeployScreen;
