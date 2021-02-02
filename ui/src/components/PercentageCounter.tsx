import React from "react";

import armor from "../assets/img/armor.svg";
import health from "../assets/img/medic.svg";

import "./PercentageCounter.scss";

interface Props {
    type: string,
    value: number,
}

const PercentageCounter: React.FC<Props> = ({ type, value }) => {

    return (
        <>
            <div className={"PercentageCounter PercentageType" + type}>
                {type === "Armor"
                ?
                    <img src={armor} alt="icon" />
                :
                    <img src={health} alt="icon" />
                }
                <div className="PercentageBg">
                    <div className="PercentageFg" style={{width: value + "%"}}></div>
                </div>
            </div>
            
        </>
    );
};

export default PercentageCounter;
