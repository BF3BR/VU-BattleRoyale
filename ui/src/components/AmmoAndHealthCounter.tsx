import React from "react";

import PercentageCounter from "./PercentageCounter";

import "./AmmoAndHealthCounter.scss";

interface Props {
    playerHealth: number;
    playerPrimaryAmmo: number;
    playerSecondaryAmmo: number;
    playerCurrentWeapon: string;
}

const AmmoAndHealthCounter: React.FC<Props> = ({ playerHealth, playerPrimaryAmmo, playerSecondaryAmmo, playerCurrentWeapon }) => {

    const padLeadingZeros = (num: number) => {
        var s = num + "";
        var ret = num + "";

        while (s.length < 3) {
            s = "0" + s;
            ret = "<span>0</span>" + ret;
        }

        return (
            {__html: ret}
        );
    }

    return (
        <>
            <div id="AmmoAndHealthCounter">
                <div className="AmmoCounter">
                    <div className="current" dangerouslySetInnerHTML={padLeadingZeros(playerPrimaryAmmo)}></div>
                    <div className="left">
                        <span className="mag" dangerouslySetInnerHTML={padLeadingZeros(playerSecondaryAmmo)}></span>
                        <span className="type">AUTO</span>
                    </div>
                </div>
                <PercentageCounter type="Armor" value={0} />
                <PercentageCounter type="Health" value={playerHealth} />
            </div>
            
        </>
    );
};

export default AmmoAndHealthCounter;
