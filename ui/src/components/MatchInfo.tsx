import React from "react";

import PercentageCounter from "./PercentageCounter";

import "./MatchInfo.scss";

interface Props {

}

const MatchInfo: React.FC<Props> = () => {

    return (
        <>
            <div id="MatchInfo">
                <span className="State">Warmup</span>
                <span className="Timer">01:20</span>
            </div>
            
        </>
    );
};

export default MatchInfo;
