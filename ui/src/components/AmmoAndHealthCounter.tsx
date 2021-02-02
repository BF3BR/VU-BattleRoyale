import React from "react";

import PercentageCounter from "./PercentageCounter";

import "./AmmoAndHealthCounter.scss";

interface Props {

}

const AmmoAndHealthCounter: React.FC<Props> = () => {

    return (
        <>
            <div id="AmmoAndHealthCounter">
                <div className="AmmoCounter">
                    <div className="current">
                        <span>0</span>98
                    </div>
                    <div className="left">
                        <span className="mag">
                            <span>0</span>98
                        </span>
                        <span className="type">AUTO</span>
                    </div>
                </div>
                <PercentageCounter type="Armor" value={70} />
                <PercentageCounter type="Health" value={100} />
            </div>
            
        </>
    );
};

export default AmmoAndHealthCounter;
