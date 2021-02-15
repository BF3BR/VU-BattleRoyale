import React, { useEffect, useState } from "react";
import BrSelect from "./BrSelect";

import logo from "../assets/img/logo.svg";

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
                <img src={logo} alt="Logo" className="Logo" />

                <div className="card SquadBox">
                    <h2>Squad</h2>
                    <h4>Code: <span>QWX994</span></h4>
                    <div className="SquadPlayers">
                        <div className="SquadPlayer">KVN</div>
                        <div className="SquadPlayer empty">No player...</div>
                        <div className="SquadPlayer disable"></div>
                        <div className="SquadPlayer disable"></div>
                    </div>

                    <div className="SquadForm">
                        <input type="text" placeholder="Enter a Code to join a squad..." />
                        <button>
                            <span>
                                Join
                            </span>
                        </button>
                    </div>
                </div>

                <div className="card AppearanceBox">
                    <h2>Appearance</h2>
                    <BrSelect 
                        options={AppearanceArray} 
                        onChangeSelected={(selected: string) => OnSelectAppearanceChange(selected)}
                        selectValue={{
                            value: AppearanceArray[selectedAppearance].value,
                            label: AppearanceArray[selectedAppearance].label,
                        }}
                    />
                </div>

                <button className="Deploy">
                    <span>Ready</span>
                </button>
            </div>
        </div>
    );
};

export default DeployScreen;
