import React, { useEffect, useState } from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";
import { sendToLua } from "../Helpers";
import { Player, rgbaToRgb } from "../helpers/PlayerHelper";
import Modal from "./Modal";

import "./MenuScreen.scss";
import { PlaySound, Sounds } from "../helpers/SoundHelper";

interface StateFromReducer {
    team: Player[];
    localPlayerName: string;
}

type Props = StateFromReducer;

const MenuScreen: React.FC<Props> = ({ team, localPlayerName }) => {
    const [currentFocus, setCurrentFocus] = useState(0);
    const [currentModalFocus, setCurrentModalFocus] = useState(0);
    const [showQuitModal, setShowQuitModal] = useState(false);
    const [showCreditsModal, setShowCreditModal] = useState(false);

    const buttons = [
        {
            label: "Resume",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "resume"),
        },
        /*{
            label: "Team / Squad",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "team"),
        },
        {
            label: "Inventory",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "inventory"),
        },*/
        {
            label: "Options",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "options"),
        },
        {
            label: "Credits",
            onClick: () => setShowCreditModal(true),
        },
        {
            label: "Quit",
            onClick: () => setShowQuitModal(true),
        },
    ];

    const quitModalButtons = [
        {
            text: "OK", 
            handler: () => sendToLua("WebUI:TriggerMenuFunction", "quit"),
        },
        {
            text: "Cancel", 
            handler: () => setShowQuitModal(false),
        },
    ];

    const creditModalButtons = [
        {
            text: "OK", 
            handler: () => setShowCreditModal(false),
        },
    ];
    
    const OnMute = (player: Player) => {
        sendToLua('WebUI:VoipMutePlayer', JSON.stringify({
            playerName: player.name,
            mute: typeof player.isMuted === "boolean" ? !player.isMuted : true,
        }));
    }

    window.OnMenuArrowDown = () => {
        if (!showQuitModal) {
            setCurrentFocus(currentFocus === buttons.length - 1 ? 0 : currentFocus + 1);
        }
    }

    window.OnMenuArrowUp = () => {
        if (!showQuitModal) {
            setCurrentFocus(currentFocus === 0 ? buttons.length - 1 : currentFocus - 1);
        }
    }

    window.OnMenuArrowRight = () => {
        if (showQuitModal) {
            setCurrentModalFocus(currentModalFocus === quitModalButtons.length - 1 ? 0 : currentModalFocus + 1);
        }
    }

    window.OnMenuArrowLeft = () => {
        if (showQuitModal) {
            setCurrentModalFocus(currentModalFocus === 0 ? quitModalButtons.length - 1 : currentModalFocus - 1);
        }
    }

    window.OnMenuEnter = () => {
        PlaySound(Sounds.Click);

        if (showQuitModal) {  
            quitModalButtons[currentModalFocus].handler();
            return;
        }

        if (showCreditsModal) {
            creditModalButtons[currentModalFocus].handler();
            return;
        }

        buttons[currentFocus].onClick();
    }

    window.OnMenuEsc = () => {
        if (showQuitModal) {
            setShowQuitModal(false);
            setCurrentModalFocus(0);
            return;
        }

        if (showCreditsModal) {
            setShowCreditModal(false);
            setCurrentModalFocus(0);
            return;
        }

        buttons[0].onClick();
    }

    useEffect(() => {
        PlaySound(Sounds.Navigate);
    }, [currentFocus])
    
    return (
        <div id="MenuScreen">
            <div className="MenuBox">
                <h3 className="ModeType">Battle Royale</h3>

                <div className="buttonsHolder">
                    {buttons.map((button: any, key: number) => (
                        <button 
                            key={key}
                            onClick={() => {
                                PlaySound(Sounds.Click);
                                button.onClick();
                            }}
                            className={"btn" + (currentFocus === key ? " active" : "")}
                            onMouseEnter={() => {
                                PlaySound(Sounds.Navigate);
                            }}
                        >
                            {button.label??""}
                        </button>
                    ))}
                </div>
            </div>

            {team.length > 0 &&
                <div className="card TeamBox">
                    <div className="card-header">
                        <h1>Squad</h1>
                    </div>
                    <div className="card-content">
                        <div className="TeamPlayers">
                            {team.map((player: Player, index: number) => (
                                <div className={"TeamPlayer"} key={index}>
                                    <div className="TeamPlayerName">
                                        <div className="circle" style={{ 
                                            background: rgbaToRgb(player.color), 
                                            boxShadow: "0 0 0.5vw " + rgbaToRgb(player.color) 
                                        }}></div>
                                        <span>
                                            {player.name??''}
                                            {player.isTeamLeader &&
                                                <span className="teamLeader">[LEADER]</span>
                                            }
                                        </span>
                                    </div>
                                    {player.name !== localPlayerName &&                                            
                                        <button className="btn btn-small" onClick={() => OnMute(player)}>
                                            {player.isMuted ?
                                                "Unmute"
                                            :
                                                "Mute"
                                            }
                                        </button>
                                    }
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            }

            <Modal 
                show={showQuitModal}
                buttons={quitModalButtons}
                highlightedButtonIndex={currentModalFocus}
                title="Are you sure?"
                text={<p>Are you sure you want to quit? Any unsaved progress will be lost.</p>}
                dismiss={() => setShowQuitModal(false)}
            />

            <Modal 
                show={showCreditsModal}
                buttons={creditModalButtons}
                highlightedButtonIndex={currentModalFocus}
                title="Credits"
                text={
                    <div className="credits">
                        <div className="credits-left">
                            <b>Developers</b>
                            <ul>
                                <li>breaknix</li>
                                <li>Bree_Arnold</li>
                                <li>FoolHen</li>
                                <li>Janssent</li>
                                <li>keku645</li>
                                <li>kiwidog</li>
                                <li>KVN</li>
                            </ul>
                        </div>
                        <div className="credits-right">
                            <b>Associates</b>
                            <ul>
                                <li>Nofate</li>
                                <li>Milk</li>
                                <li>Paul</li>
                                <li>Imposter</li>
                                <li>IllustrisJack</li>
                                <li>Greatapo</li>
                                <li>Powback</li>
                                <li>Afroh Music</li>
                                <li>alx1f9k</li>
                            </ul>
                        </div>
                    </div>
                }
                dismiss={() => setShowQuitModal(false)}
            />

            <div className="card CommunityBox">
                <div className="card-header">
                    <h1>Community</h1>
                </div>
                <div className="card-content">
                    <ul>
                        <li>Join our discord: <b>https://discord.gg/9nuXa4Sx5c</b></li>
                        <li>Visit our website: <b>https://bf3br.github.io</b></li>
                    </ul>
                </div>
            </div>
            {/*<div className="card CreditsBox">
                <div className="card-header">
                    <h1>Developers</h1>
                </div>
                <div className="card-content">
                    <ul>
                        <li>breaknix</li>
                        <li>Bree_Arnold</li>
                        <li>FoolHen</li>
                        <li>Janssent</li>
                        <li>keku645</li>
                        <li>kiwidog</li>
                        <li>KVN</li>
                    </ul>
                </div>
            </div>
            <div className="card AssociatesBox">
                <div className="card-header">
                    <h1>Associates</h1>
                </div>
                <div className="card-content">
                    <ul>
                        <li>Nofate</li>
                        <li>Milk</li>
                        <li>Paul</li>
                        <li>Imposter</li>
                        <li>IllustrisJack</li>
                        <li>Greatapo</li>
                        <li>Powback</li>
                        <li>Afroh Music</li>
                        <li>alx1f9k</li>
                    </ul>
                </div>
            </div>*/}
        </div>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // TeamReducer
        team: state.TeamReducer.players,
        // PlayerReducer
        localPlayerName: state.PlayerReducer.player.name ?? "",
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MenuScreen);

declare global {
    interface Window {
        OnMenuArrowUp: () => void;
        OnMenuArrowDown: () => void;
        OnMenuEnter: () => void;
        OnMenuEsc: () => void;
        OnMenuArrowRight: () => void;
        OnMenuArrowLeft: () => void;
    }
}
