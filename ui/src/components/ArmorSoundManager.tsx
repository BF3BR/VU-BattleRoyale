import React, { useState } from "react";

import { VolumeConst } from "../helpers/SoundHelper";

import shieldBreak from "../assets/sounds/shield_break.mp3";
import shield from "../assets/img/armor.svg";

import "./ArmorSoundManager.scss";

const shieldBreakAudio = new Audio(shieldBreak);
shieldBreakAudio.volume = VolumeConst * .8;
shieldBreakAudio.autoplay = false;
shieldBreakAudio.loop = false;
shieldBreakAudio.pause();

const ArmorSoundManager: React.FC = () => {
    const [showShield, setShowShield] = useState<boolean>(false);

    window.OnShieldBreak = () => {
        setShowShield(true);

        setTimeout(() => {
            setShowShield(false);
        }, 1500);

        shieldBreakAudio.currentTime = 0.0;
        shieldBreakAudio.pause();
        shieldBreakAudio.play();

        shieldBreakAudio.onended = function() {
            shieldBreakAudio.currentTime = 0.0;
            shieldBreakAudio.pause();
        };
    }

    return (
        <>
            {showShield &&
                <div id="shieldBreak" >
                    <img src={shield} alt="" />
                </div>
            }
        </>
    );
};

export default ArmorSoundManager;

declare global {
    interface Window {
        OnShieldBreak: () => void;
    }
}
