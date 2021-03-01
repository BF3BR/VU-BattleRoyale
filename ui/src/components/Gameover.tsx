import React, { useEffect } from "react";
import Player from "../helpers/Player";

import winner from "../assets/sounds/winner.mp3";

import "./Gameover.scss";

interface Props {
    localPlayer: Player|null;
}

const alertAudio = new Audio(winner);
alertAudio.volume = 0.3;
alertAudio.autoplay = false;
alertAudio.loop = false;

const Gameover: React.FC<Props> = ({ localPlayer }) => {
    useEffect(() => {
        if (alert !== null) {
            alertAudio.play();

            return () => {
                alertAudio.currentTime = 0.0;
                alertAudio.pause();
            }
        }
    }, [localPlayer]);

    return (
        <>
            {localPlayer &&
                <div id="Gameover">
                    <span className="Name">
                        {localPlayer.name??''}
                    </span>
                    <div className="Separator"></div>
                    <span className="Rank">
                        RANK <span>#{localPlayer.kill??''}</span>
                    </span>
                    <span className="Kills">
                        KILLS <span>{localPlayer.kill??''}</span>
                    </span>
                </div>
            }
        </>
    );
};

export default Gameover;
