import React, { useEffect, useState } from "react";
import { sendToLua } from "../Helpers";
import Player from "../helpers/Player";

import arrow from "../assets/img/arrow.svg";

import "./DeployScreen.scss";
import BrSelect from "./BrSelect";

const AppearanceArray = [
    "RU Woodland",
    "US Woodland",
    "RU Urban",
    "US Urban",
];

const TeamType = [
    {
        value: 0,
        label: "Play as solo", // TeamJoinStrategy.NoJoin
    },
    {
        value: 1,
        label: "Join a random team", // TeamJoinStrategy.AutoJoin
    },
    {
        value: 2,
        label: "Custom team", // TeamJoinStrategy.Custom
    },
];

interface Props {
    setDeployScreen: (bool: boolean) => void;
    squad: Player[];
    squadSize: number;
    squadOpen: boolean;
    isSquadLeader: boolean;
    squadCode: string|null;
}

const DeployScreen: React.FC<Props> = ({ setDeployScreen, squad, squadSize, squadOpen, isSquadLeader, squadCode }) => {
    const [selectedAppearance, setSelectedAppearance] = useState<number>(0);
    const [selectedTeamType, setSelectedTeamType] = useState<number>(0);

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
        sendToLua('WebUI:Deploy'); // synced
        setDeployScreen(false);
    }

    const OnSquadOpenClose = () => {
        sendToLua('WebUI:ToggleLock'); // synced
    }

    const OnChangeTeamType = (data: any) => {
        sendToLua('WebUI:SetTeamJoinStrategy', data); // synced
        setSelectedTeamType(data);
    }

    const [joinCode, setJoinCode] = useState<string>('');

    const handleJoinCodeChange = (event: any) => {
        console.log(event);
        setJoinCode(event.target.value);
    }

    const handleFocus = () => {
        if (!navigator.userAgent.includes('VeniceUnleashed')) {
            if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                return;
            }
        }

        WebUI.Call('EnableKeyboard');
    }
    
    const OnJoinTeam = () => {
        if (joinCode !== '') {
            sendToLua('WebUI:JoinTeam', joinCode); // synced
            setJoinCode('');
        }
    }

    const items = []
    for (let index = 0; index < (squadSize - squad.length); index++) {
        items.push(
            <div className="SquadPlayer empty" key={index}>No player...</div>
        )
    }

    useEffect(() => {
        if (!navigator.userAgent.includes('VeniceUnleashed')) {
            if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                return;
            }
        }
        
        console.log('Deploy - Enable Keyboard and Mouse');
        WebUI.Call('EnableKeyboard');
        WebUI.Call('EnableMouse');

        return () => {
            console.log('Deploy - Reset Keyboard and Mouse');
            WebUI.Call('ResetKeyboard');
            WebUI.Call('ResetMouse');
        }
    }, [])

    return (
        <div id="DeployScreen">
            <div className="DeployBox">
                <h1 className="PageTitle">Battle Royale</h1>

                <h3 className="TeamType">Squad size: {squadSize??1}</h3>

                {squadSize > 1 && 
                    <div className="card TeamTypeBox">
                        <div className="card-header">
                            <h1>Team type</h1>
                        </div>
                        <div className="card-content">
                            <BrSelect 
                                options={TeamType} 
                                onChangeSelected={(selected: any) => OnChangeTeamType(selected)}
                                selectValue={{
                                    value: TeamType[selectedTeamType].value,
                                    label: TeamType[selectedTeamType].label,
                                }}
                            />
                        </div>
                    </div>
                }

                {selectedTeamType === 2 && // Custom
                    <>
                        <div className="card SquadBox">
                            <div className="card-header">
                                <h1>
                                    Your Squad
                                    <label>
                                        <input
                                            name="squadOpen"
                                            type="checkbox"
                                            disabled={!isSquadLeader}
                                            checked={squadOpen}
                                            onChange={OnSquadOpenClose}
                                        />
                                    </label>
                                    Open
                                    <span>Code: <b>{squadCode??''}</b></span>
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
                                    <input 
                                        type="text" 
                                        placeholder="Enter a Code to join a squad..." 
                                        value={joinCode} 
                                        onChange={handleJoinCodeChange} 
                                        onFocus={handleFocus}
                                    />
                                    <button className="btn btn-primary btn-small" onClick={OnJoinTeam}>
                                        Join
                                    </button>
                                </div>
                            </div>
                        </div>
                    </>
                }

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
