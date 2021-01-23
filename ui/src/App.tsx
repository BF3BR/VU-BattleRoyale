import React, { useEffect, useState } from "react";

/* Components */
import ParaDropDistance from "./components/ParaDropDistance";

/* Style */
import './App.scss';

const App: React.FC = () => {
    /*
    * Debug
    */
    let debugMode: boolean = false;
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

    return (
        <>
            {debugMode &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        background: #333;
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
            </div>
        </>
    );
};

export default App;

declare global {
    interface Window {

    }
}
