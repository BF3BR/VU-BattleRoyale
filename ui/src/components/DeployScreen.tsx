import React, { useEffect, useState } from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";
import { UPDATE_DEPLOY_APPEARANCE, UPDATE_DEPLOY_SCREEN, UPDATE_DEPLOY_TEAM, UPDATE_DEPLOY_TEAM_TYPE } from "../store/game/ActionTypes";

import { sendToLua } from "../Helpers";
import Player, { rgbaToRgb } from "../helpers/PlayerHelper";
import BrSelect from "./helpers/BrSelect";

import arrow from "../assets/img/arrow.svg";
import lock from "../assets/img/lock.svg";
import lockOpen from "../assets/img/lock-open.svg";

import "./DeployScreen.scss";

let isFirstLoad = true;

const AppearanceArray = [
    "RU Woodland",
    "US Woodland",
    "RU Urban",
    "US Urban",
];

const TeamType = [
    {
        value: 1,
        label: "Play as solo", // TeamJoinStrategy.NoJoin
    },
    {
        value: 2,
        label: "Join a random team", // TeamJoinStrategy.AutoJoin
    },
    {
        value: 3,
        label: "Custom team", // TeamJoinStrategy.Custom
    },
];

interface DispatchFromReducer {
    setDeployScreen: (bool: boolean) => void;
    setTeamJoinError: (p_Error: number|null) => void;
    setSelectedAppearance: (data: number) => void;
    setSelectedTeamType: (data: number) => void;
}

interface StateFromReducer {
    team: Player[];
    teamSize: number;
    teamOpen: boolean;
    isTeamLeader: boolean;
    teamCode: string|null;
    teamJoinError: number|null;
    selectedAppearance: number;
    selectedTeamType: number;
}

type Props = DispatchFromReducer & StateFromReducer;

const DeployScreen: React.FC<Props> = ({ 
    setDeployScreen, 
    team, 
    teamSize, 
    teamOpen, 
    isTeamLeader, 
    teamCode, 
    teamJoinError, 
    setTeamJoinError,
    selectedAppearance,
    setSelectedAppearance,
    selectedTeamType,
    setSelectedTeamType
}) => {
    const OnAppearanceRight = () => {
        if (selectedAppearance === AppearanceArray.length - 1) {
            setSelectedAppearance(0);
        } else {
            setSelectedAppearance(selectedAppearance + 1);
        }
    }

    const OnAppearanceLeft = () => {
        if (selectedAppearance === 0) {
            setSelectedAppearance(Object.keys(AppearanceArray).length - 1);
        } else {
            setSelectedAppearance(selectedAppearance - 1);
        }
    }

    const OnDeploy = () => {
        sendToLua('WebUI:Deploy'); // synced
        setDeployScreen(false);
    }

    const OnTeamOpenClose = () => {
        sendToLua('WebUI:ToggleLock'); // synced
    }

    const OnChangeTeamType = (data: any) => {
        sendToLua('WebUI:SetTeamJoinStrategy', data); // synced
        setSelectedTeamType(data);
    }

    const [joinCode, setJoinCode] = useState<string>('');

    const handleJoinCodeChange = (event: any) => {
        if (teamJoinError !== null) {
            setTeamJoinError(null);
        }
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
    for (let index = 0; index < (teamSize - team.length); index++) {
        items.push(
            <div className="TeamPlayer empty" key={index}>No player...</div>
        )
    }

    const [btnDisabled, setBtnDisabled] = useState<boolean>(isFirstLoad);
    useEffect(() => {
        setTimeout(() => {
            setBtnDisabled(false);
            isFirstLoad = false;
        }, 3000);
    }, []);

    return (
        <div id="DeployScreen">
            <div className="DeployBox">
                <h1 className="PageTitle">Battle Royale</h1>

                <h3 className="TeamType">Team size: {teamSize??1}</h3>

                {teamSize > 1 && 
                    <div className="card TeamTypeBox">
                        <div className="card-header">
                            <h1>Team type</h1>
                        </div>
                        <div className="card-content">
                            <BrSelect 
                                options={TeamType} 
                                onChangeSelected={(selected: any) => OnChangeTeamType(selected)}
                                selectValue={{
                                    value: TeamType[selectedTeamType - 1].value,
                                    label: TeamType[selectedTeamType - 1].label,
                                }}
                            />
                        </div>
                    </div>
                }

                {TeamType[selectedTeamType - 1].value === 3 && // Custom
                    <>
                        <div className="card TeamBox">
                            <div className="card-header">
                                <h1>
                                    Your Team                                    
                                    <span>Code: <b className="codeNumbers">{teamCode??' - '}</b></span>
                                    <label id="TeamOpenClose" className={teamOpen ? "isOpen" : "isClose"}>
                                        {teamOpen ?
                                            <img src={lockOpen} alt="FILL" />
                                        :
                                            <img src={lock} alt="NO FILL" />
                                        }
                                        <input
                                            name="teamOpen"
                                            type="checkbox"
                                            disabled={!isTeamLeader}
                                            checked={teamOpen}
                                            onChange={OnTeamOpenClose}
                                        />
                                        {teamOpen ?
                                            <>
                                                FILL
                                            </>
                                        :
                                            <>
                                                NO FILL
                                            </>
                                        }
                                    </label>
                                </h1>
                            </div>
                            <div className="card-content">
                                <div className="TeamPlayers">
                                    {team.map((player: Player, index: number) => (
                                        <div className={"TeamPlayer"} key={index}>
                                            <div className="TeamPlayerName">
                                                <div className="circle" style={{ background: rgbaToRgb(player.color), boxShadow: "0 0 0.5vw " + rgbaToRgb(player.color) }}></div>
                                                <span>{player.name??''}</span>
                                            </div>
                                            {player.isTeamLeader &&
                                                <span className="teamLeader">[LEADER]</span>
                                            }
                                        </div>
                                    ))}
                                    {items??''}
                                </div>
                            </div>
                        </div>

                        <div className="card TeamBox TeamJoinBox">
                            <div className="card-header">
                                <h1>
                                    Join a team
                                </h1>
                            </div>
                            <div className="card-content">
                                <div className="TeamForm">
                                    <input 
                                        type="text" 
                                        placeholder="Enter a code to join a team..." 
                                        value={joinCode} 
                                        onChange={handleJoinCodeChange} 
                                        onFocus={handleFocus}
                                        className={teamJoinError ? 'isError' : ''}
                                    />
                                    <button className="btn btn-primary btn-small" onClick={OnJoinTeam}>
                                        Join
                                    </button>
                                </div>
                                {teamJoinError &&
                                    <span className="JoinCodeError">
                                        {teamJoinError === 2 ?
                                            <>
                                                The team is full.
                                            </>
                                        :
                                            <>
                                                Invalid team code.
                                            </>
                                        }
                                    </span>
                                }
                            </div>
                        </div>
                    </>
                }

                <div className="card AppearanceBox TeamBox">
                    <div className="card-header">
                        <h1>Appearance</h1>
                    </div>
                    <div className="card-content">
                        <button onClick={OnAppearanceLeft}><img src={arrow} className="left" alt="Left" /></button>
                        <div className="AppearanceText">{AppearanceArray[selectedAppearance]}</div>
                        <button onClick={OnAppearanceRight}><img src={arrow} className="right" alt="Right" /></button>
                    </div>
                </div>

                <button className="btn btn-full-width Deploy" disabled={btnDisabled} onClick={OnDeploy}>
                    Ready
                </button>
            </div>
        </div>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PlayerReducer
        team: state.TeamReducer.players,
        // GameReducer
        teamSize: state.GameReducer.deployScreen.teamSize,
        teamOpen: !state.GameReducer.deployScreen.teamLocked,
        teamCode: state.GameReducer.deployScreen.teamId ?? "-",
        teamJoinError: state.GameReducer.deployScreen.teamJoinError,
        selectedAppearance: state.GameReducer.deployScreen.selectedAppearance,
        selectedTeamType: state.GameReducer.deployScreen.selectedTeamType,
        // PlayerReducer
        isTeamLeader: state.PlayerReducer.player.isTeamLeader ?? false,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {
        setTeamJoinError: (p_Error: number|null) => {
            dispatch({
                type: UPDATE_DEPLOY_TEAM, 
                payload: {
                    teamJoinError: p_Error
                }
            });
        },
        setDeployScreen: (bool: boolean) => {
            dispatch({
                type: UPDATE_DEPLOY_SCREEN, 
                payload: {
                    enabled: bool
                }
            });
        },
        setSelectedAppearance: (data: number) => {
            dispatch({
                type: UPDATE_DEPLOY_APPEARANCE, 
                payload: {
                    selectedAppearance: data
                }
            });
        },
        setSelectedTeamType: (data: number) => {
            dispatch({
                type: UPDATE_DEPLOY_TEAM_TYPE, 
                payload: {
                    selectedTeamType: data
                }
            });
        },
    };
}
export default connect(mapStateToProps, mapDispatchToProps)(DeployScreen);
