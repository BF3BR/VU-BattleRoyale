import React from "react";
import { sendToLua } from "../Helpers";

import "./MenuScreen.scss";

const MenuScreen: React.FC = () => {
    return (
        <div id="MenuScreen">
            <div className="MenuBox">
                <h3 className="ModeType">Battle Royale</h3>

                <div className="buttonsHolder">
                    <button className="btn" onClick={() => sendToLua("WebUI:TriggerMenuFunction", "resume")}>
                        Resume
                    </button>
                    <button className="btn" onClick={() => sendToLua("WebUI:TriggerMenuFunction", "inventory")}>
                        Inventory
                    </button>
                    <button className="btn" onClick={() => sendToLua("WebUI:TriggerMenuFunction", "options")}>
                        Options
                    </button>
                    <button className="btn" onClick={() => sendToLua("WebUI:TriggerMenuFunction", "quit")}>
                        Quit
                    </button>
                </div>
            </div>

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
