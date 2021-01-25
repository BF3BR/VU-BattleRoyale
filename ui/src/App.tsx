import React, { useEffect, useState } from "react";

/* Components */
import ParaDropDistance from "./components/ParaDropDistance";
import MiniMap from "./components/MiniMap";

/* Style */
import './App.scss';
import Vec3 from "./helpers/Vec3";

const App: React.FC = () => {
    /*
    * Debug
    */
    let debugMode: boolean = true;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
        }
    }
        
    /*
    * States
    */
    const [paradropPercentage, setParadropPercentage] = useState<number>(100);
    const [paradropDistance, setParadropDistance] = useState<number>(100);

    const [openMap, setOpenMap] = useState<boolean>(false);
    const [showMinimap, setShowMinimap] = useState<boolean>(false);
    
    const [playerPos, setPlayerPos] = useState<Vec3|null>(null);
    window.OnPlayerPos = (p_DataJson: any) => {
        setPlayerPos({
            x: p_DataJson.x,
            y: p_DataJson.y,
            z: p_DataJson.z,
        });
    }

    const [playerYaw, setPlayerYaw] = useState<number|null>(null);
    window.OnPlayerYaw = (p_YawRad: number) => {
        setPlayerYaw(p_YawRad);
    }

    return (
        <>
            {debugMode &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        /*background: #333;*/
                    }

                    #debug {
                        display: block !important;
                        opacity: 0.1;
                    }
                `}} />
            }

            <div id="debug">
                <input 
                    type="range" 
                    min="0" 
                    max="100"
                    value={paradropPercentage} 
                    onChange={(event: any) => setParadropPercentage(event.target.value)}
                    step="1"
                />
                <button onClick={() => setShowMinimap(prevState => !prevState)}>Show Map</button>
                <button onClick={() => setOpenMap(prevState => !prevState)}>Open Map</button>
                {/*
                <button onClick={() => setRandomMessages()}>Random messages</button>
                <button onClick={() =>  window.OnFocus(MessageTarget.CctSayAll)}>isTypingActive</button>
                <button onClick={() =>  window.OnChangeType()}>OnChangeType</button>
                <button onClick={() =>  window.OnClearChat()}>OnClearChat</button>
                <button onClick={() =>  window.OnCloseChat()}>OnCloseChat</button>
                */}
            </div>

            <div id="VUBattleRoyale">
                <ParaDropDistance 
                    percentage={paradropPercentage}
                    distance={300}
                    warnPercentage={15}
                />
                {showMinimap &&
                    <MiniMap 
                        open={openMap}
                        playerPos={playerPos}
                        playerYaw={playerYaw}
                    />
                }
            </div>
        </>
    );
};

export default App;

declare global {
    interface Window {
        OnPlayerPos: (p_DataJson: any) => void;
        OnPlayerYaw: (p_YawRad: number) => void;
    }
}
