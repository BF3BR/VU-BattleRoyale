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
                <div className="KillAndAliveBox Alive">
                    <h1>{alive}</h1>
                    <span>ALIVE</span>
                </div>
                {!spectating &&
                    <div className="KillAndAliveBox Kill">
                        <h1>{kills}</h1>
                        <span>KILLS</span>
                    </div>
                }
            </div>
            
        </>
    );
};

export default KillAndAliveInfo;
