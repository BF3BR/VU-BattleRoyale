import React, { useState } from "react";

import { PlaySound, Sounds } from "../helpers/SoundHelper";

import shield from "../assets/img/broken_shield.svg";

import "./ArmorSoundManager.scss";


const ArmorSoundManager: React.FC = () => {
    const [showShield, setShowShield] = useState<boolean>(false);

    window.OnShieldBreak = () => {
        setShowShield(true);

        setTimeout(() => {
            setShowShield(false);
        }, 2150);

        PlaySound(Sounds.ShieldBreak);
    }

    return (
        <>
            {showShield &&
                <div id="shieldBreak">
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
