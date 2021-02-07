import React from "react";

import "./KillAndAliveInfo.scss";

interface Props {
    kills: number;
    alive: number;
    spectating: boolean;
}

const KillAndAliveInfo: React.FC<Props> = ({ kills, alive, spectating }) => {

    return (
        <>
            <div id="KillAndAliveInfo">
                <div className="KillAndAliveBox">
                    <span>{alive}</span>
                    <span>ALIVE</span>
                </div>
                {!spectating &&
                    <div className="KillAndAliveBox">
                        <span>{kills}</span>
                        <span>KILLS</span>
                    </div>
                }
            </div>
            
        </>
    );
};

export default KillAndAliveInfo;
