import React from "react";

import health from "../../assets/img/medic.svg";

import ArmorIcon from "../icons/ArmorIcon";
import HelmetIcon from "../icons/HelmetIcon";

import "./PercentageCounter.scss";

interface Props {
    type: string,
    value: number,
    slot?: any,
}

const PercentageCounter: React.FC<Props> = ({ type, value, slot }) => {

    const getTierColor = () => {
        switch (slot?.Tier) {
            case 2:
                return "#52b0df";
            case 3:
                return "#ff9900";
            case 1:
            default:
                return "#fff";
        }
    }

    return (
        <>
            <div className={"PercentageCounter PercentageType" + type + (slot?.Tier !== undefined ? " tier-" + slot.Tier : "")}>
                {type === "Armor"
                ?
                    <ArmorIcon fill={getTierColor()} />
                :
                    <>
                        {type === "Helmet"
                        ?
                            <HelmetIcon fill={getTierColor()} />
                        :
                            <img src={health} alt="icon" />
                        }
                    </>
                }
                <div className="PercentageBg">
                    <div className="PercentageFg" style={{width: value + "%"}}></div>
                </div>
                <div className="PercentageText">{value ? Math.floor(value) : 0}</div>
            </div>
            
        </>
    );
};

export default PercentageCounter;
