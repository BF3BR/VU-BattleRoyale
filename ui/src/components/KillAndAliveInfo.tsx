import React from "react";

import "./KillAndAliveInfo.scss";

interface Props {
    kills: number;
    alive: number;
}

const KillAndAliveInfo: React.FC<Props> = ({ kills, alive }) => {

    return (
        <>
            <div id="KillAndAliveInfo">
                <div className="KillAndAliveBox">
                    <span>{alive}</span>
                    <span>ALIVE</span>
                </div>
                <div className="KillAndAliveBox">
                    <span>{kills}</span>
                    <span>KILLS</span>
                </div>
            </div>
            
        </>
    );
};

export default KillAndAliveInfo;
