import React, { useEffect } from "react";
import Player from "../helpers/Player";

import winner from "../assets/sounds/winner.mp3";

import "./Gameover.scss";

interface Props {
    localPlayer: Player|null;
    afterInterval: () => void;
    gameOverPlace: number;
    gameOverIsWin: boolean;
}

const alertAudio = new Audio(winner);
alertAudio.volume = 0.3;
alertAudio.autoplay = false;
alertAudio.loop = false;

const Gameover: React.FC<Props> = ({ localPlayer, gameOverIsWin, gameOverPlace, afterInterval }) => {
    useEffect(() => {
        if (alert !== null && localPlayer !== null) {
            alertAudio.play();
            
            if (!navigator.userAgent.includes('VeniceUnleashed')) {
                if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                    return;
                }
            } else {
                WebUI.Call('EnableKeyboard');
                WebUI.Call('EnableMouse');    
            }

            return () => {
                alertAudio.currentTime = 0.0;
                alertAudio.pause();

                if (!navigator.userAgent.includes('VeniceUnleashed')) {
                    if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                        return;
                    }
                } else {
                    WebUI.Call('ResetKeyboard');
                    WebUI.Call('ResetMouse');
                }
            }
        }
    }, []);

    return (
        <>
            {localPlayer &&
                <div id="Gameover">
                    <span className="WonOrLost">
                        {gameOverIsWin ?
                            <span className="won">You Won!</span>
                        :
                            <span className="lost">You Lost!</span>
                        }
                    </span>
                    <span className="Name">
                        {localPlayer.name??''}
                    </span>
                    <div className="inline">
                        <span className="Rank">
                            Your place: <span>#{gameOverPlace??99}</span>
                        </span>
                        <span className="Kills">
                            Your Kills: <span>{localPlayer.kill??''}</span>
                        </span>
                    </div>
                    <button className="btn" onClick={afterInterval}>
                        Return to game
                    </button>
                </div>
            }
        </>
    );
};

export default Gameover;
