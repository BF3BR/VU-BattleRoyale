import React, { useCallback, useEffect, useState } from "react";
import { sendToLua } from "../Helpers";

import Modal from "./Modal";

import "./MenuScreen.scss";

const MenuScreen: React.FC = () => {
    const [currentFocus, setCurrentFocus] = useState(-1);
    const [showQuitModal, setShowQuitModal] = useState(false);

    const buttons = [
        {
            label: "Resume",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "resume"),
        },
        {
            label: "Team / Squad",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "team"),
        },
        {
            label: "Inventory",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "inventory"),
        },
        {
            label: "Options",
            onClick: () => sendToLua("WebUI:TriggerMenuFunction", "options"),
        },
        {
            label: "Quit",
            onClick: () => setShowQuitModal(true),
        },
    ];

    const handleKeyDown = useCallback(
        e => {
            if (!showQuitModal) {
                if (e.keyCode === 40) {
                    // Down arrow
                    e.preventDefault();
                    setCurrentFocus(currentFocus === buttons.length - 1 ? 0 : currentFocus + 1);
                } else if (e.keyCode === 38) {
                    // Up arrow
                    e.preventDefault();
                    setCurrentFocus(currentFocus === 0 ? buttons.length - 1 : currentFocus - 1);
                } else if (e.keyCode === 13) {
                    // Enter
                    e.preventDefault();
                    buttons[currentFocus].onClick();
                } else if (e.keyCode === 27) {
                    // Esc
                    e.preventDefault();
                    sendToLua("WebUI:TriggerMenuFunction", "resume");
                }
            } else {
                if (e.keyCode === 27) {
                    // Esc
                    e.preventDefault();
                    setShowQuitModal(false);
                }
            }
        },
        [buttons.length, currentFocus, setCurrentFocus, showQuitModal]
    );

    useEffect(() => {
        document.addEventListener("keydown", handleKeyDown, false);
        return () => {
            document.removeEventListener("keydown", handleKeyDown, false);
        };
    }, [handleKeyDown]);
    
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
                buttons={[
                    {
                        text: "OK", 
                        handler: () => sendToLua("WebUI:TriggerMenuFunction", "quit"),
                    },
                    {
                        text: "Cancel", 
                        handler: () => setShowQuitModal(false),
                    },
                ]}
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
                        <li>Visit our website: <b>totalynotbf3br.co.uk</b></li>
                    </ul>
                </div>
            </div>
            <div className="card CreditsBox">
                <div className="card-header">
                    <h1>Credits</h1>
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
        </div>
    );
};

export default MenuScreen;
