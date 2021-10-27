import React, { useState } from "react";
import { sendToLua } from "../Helpers";

import Modal from "./Modal";

import "./MenuScreen.scss";

const MenuScreen: React.FC = () => {
    const [currentFocus, setCurrentFocus] = useState(0);
    const [currentModalFocus, setCurrentModalFocus] = useState(0);
    const [showQuitModal, setShowQuitModal] = useState(false);

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
            label: "Quit",
            onClick: () => setShowQuitModal(true),
        },
    ];

    const modalButtons = [
        {
            text: "OK", 
            handler: () => sendToLua("WebUI:TriggerMenuFunction", "quit"),
        },
        {
            text: "Cancel", 
            handler: () => setShowQuitModal(false),
        },
    ];
    
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
            setCurrentModalFocus(currentModalFocus === modalButtons.length - 1 ? 0 : currentModalFocus + 1);
        }
    }

    window.OnMenuArrowLeft = () => {
        if (showQuitModal) {
            setCurrentModalFocus(currentModalFocus === 0 ? modalButtons.length - 1 : currentModalFocus - 1);
        }
    }

    window.OnMenuEnter = () => {
        if (!showQuitModal) {
            buttons[currentFocus].onClick();
        } else {
            modalButtons[currentModalFocus].handler();
        }
    }

    window.OnMenuEsc = () => {
        if (!showQuitModal) {
            buttons[0].onClick();
        } else {
            setShowQuitModal(false);
            setCurrentModalFocus(0);
        }
    }
    
    return (
        <div id="MenuScreen">
            <div className="MenuBox">
                <h3 className="ModeType">Battle Royale</h3>

                <div className="buttonsHolder">
                    {buttons.map((button: any, key: number) => (
                        <button 
                            key={key}
                            onClick={button.onClick}
                            className={"btn" + (currentFocus === key ? " active" : "")}
                        >
                            {button.label??""}
                        </button>
                    ))}
                </div>
            </div>

            <Modal 
                show={showQuitModal}
                buttons={modalButtons}
                highlightedButtonIndex={currentModalFocus}
                title="Are you sure?"
                text="Are you sure you want to quit? Any unsaved progress will be lost."
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
            <div className="card CreditsBox">
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
            </div>
        </div>
    );
};

export default MenuScreen;

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
