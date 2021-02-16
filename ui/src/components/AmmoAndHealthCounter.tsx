import React, { useState, useEffect } from "react";

import PercentageCounter from "./PercentageCounter";
import { WeaponNames } from "../helpers/WeaponNames";

import "./AmmoAndHealthCounter.scss";

interface Props {
    playerHealth: number;
    playerPrimaryAmmo: number;
    playerSecondaryAmmo: number;
    playerCurrentWeapon: string;
}

const AmmoAndHealthCounter: React.FC<Props> = ({ playerHealth, playerPrimaryAmmo, playerSecondaryAmmo, playerCurrentWeapon }) => {
    const [visible, setVisible] = useState<boolean>(false);

    const padLeadingZeros = (num: number, playerCurrentWeapon: string) => {
        if (num === -1 || WeaponNames[playerCurrentWeapon] === 'Knife') {
            return ({
                __html: '<span class="zero">-</span><span class="zero">-</span><span class="zero">-</span>'
            });
        }

        var s = num + "";

        var ret = "";
        s.split("").forEach((char: string) => {
            ret +=  '<span class="number">' + char + '</span>';
        });

        while (s.length < 3) {
            s = "0" + s;
            ret = '<span class="zero">0</span>' + ret;
        }

        return ({
            __html: ret
        });
    }

    useEffect(() => {
        if (playerCurrentWeapon !== '') {
            setVisible(true);
            const interval = setTimeout(() => {
                setVisible(false);
            }, 3000);

            return () => {
                clearTimeout(interval);
                setVisible(false);
            }
        }
    }, [playerCurrentWeapon]);

    return (
        <>
            <div id="AmmoAndHealthCounter">
                <div className={"WeaponName " + (visible ? 'IsVisible' : '')}>
                    {playerCurrentWeapon !== '' &&
                        <>
                            {WeaponNames[playerCurrentWeapon]}
                        </>
                    }
                </div>
                <div className="AmmoCounter">
                    <div className="current" dangerouslySetInnerHTML={padLeadingZeros(playerPrimaryAmmo, playerCurrentWeapon)}></div>
                    <div className="left">
                        <span className="mag" dangerouslySetInnerHTML={padLeadingZeros(playerSecondaryAmmo, playerCurrentWeapon)}></span>
                        <span className="type">AUTO</span>
                    </div>
                </div>
                <PercentageCounter type="Armor" value={35} />
                <PercentageCounter type="Health" value={playerHealth} />
            </div>
            
        </>
    );
};

export default AmmoAndHealthCounter;
