import React, { useEffect, useState } from "react";

/* Helpers */
import Vec3 from "./helpers/Vec3";
import Circle from "./helpers/Circle";

/* Components */
import ParaDropDistance from "./components/ParaDropDistance";
import MiniMap from "./components/MiniMap";

/* Style */
import './App.scss';

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

    /*
    * Map
    */
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

    window.OnMapSizeChange = () => {
        setOpenMap(prevState => !prevState);
    }

    window.OnMapShow = (show: boolean) => {
        setShowMinimap(show);
    }

    const [innerCircle, setInnerCircle] = useState<Circle|null>(null);
    const [outerCircle, setOuterCircle] = useState<Circle|null>(null);
    window.OnUpdateCircles = (data: any) => {
        if (data.InnerCircle) {
            setInnerCircle({
                center: {
                    x: data.InnerCircle.Center.x,
                    y: data.InnerCircle.Center.y,
                    z: data.InnerCircle.Center.z,
                },
                radius: data.InnerCircle.Radius,
            });
        }

        if (data.OuterCircle) {
            setOuterCircle({
                center: {
                    x: data.OuterCircle.Center.x,
                    y: data.OuterCircle.Center.y,
                    z: data.OuterCircle.Center.z,
                },
                radius: data.OuterCircle.Radius,
            });
        }
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
                <button onClick={() => window.OnPlayerPos({x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000)})}>Set Random Player Pos</button>
                <button onClick={() => window.OnPlayerYaw(Math.random() * 100)}>Set Random Player Yaw</button>
                {/*
                <button onClick={() => setRandomMessages()}>Random messages</button>
                <button onClick={() =>  window.OnFocus(MessageTarget.CctSayAll)}>isTypingActive</button>
                <button onClick={() =>  window.OnChangeType()}>OnChangeType</button>
                <button onClick={() =>  window.OnClearChat()}>OnClearChat</button>
                <button onClick={() =>  window.OnCloseChat()}>OnCloseChat</button>
                */}
            </div>

            <div id="VUBattleRoyale">
                {/*<ParaDropDistance 
                    percentage={paradropPercentage}
                    distance={300}
                    warnPercentage={15}
                />*/}
                {showMinimap &&
                    <MiniMap 
                        open={openMap}
                        playerPos={playerPos}
                        playerYaw={playerYaw}
                        innerCircle={innerCircle}
                        outerCircle={outerCircle}
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
        OnMapSizeChange: () => void;
        OnMapShow: (show: boolean) => void;
        OnUpdateCircles: (data: any) => void;
    }
}
