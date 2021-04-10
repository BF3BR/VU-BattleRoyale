import React from "react";

import Circle from "../../helpers/CircleHelper";
import Ping from "../../helpers/PingHelper";
import Player from "../../helpers/PlayerHelper";
import Vec3 from "../../helpers/Vec3Helper";

import MapPixi from "./MapPixi";

import "./MiniMap.scss";

interface Props {
    open: boolean;
    playerPos: Vec3|null;
    playerYaw: number|null;
    planePos: Vec3|null;
    planeYaw: number|null;
    innerCircle: Circle|null;
    outerCircle: Circle|null;
    playerIsInPlane: boolean;
    pingsTable: Array<Ping>;
    team: Player[];
    localPlayer: Player;
    showMinimap: boolean;
}

const MiniMap: React.FC<Props> = ({ 
    open, 
    playerPos, 
    playerYaw, 
    planePos, 
    planeYaw, 
    innerCircle, 
    outerCircle, 
    playerIsInPlane, 
    pingsTable,
    team,
    localPlayer,
    showMinimap
}) => {
    return (
        <>
            <div id="miniMap" className={(showMinimap ? "showMinimap" : "hideMinimap") + " " +  (open?'open':'')}>
                {playerPos !== null && playerYaw !== null ?
                    <MapPixi 
                        open={open}
                        playerPos={playerPos} 
                        playerYaw={playerYaw} 
                        planePos={planePos}
                        planeYaw={planeYaw}
                        innerCircle={innerCircle}
                        outerCircle={outerCircle}
                        team={team}
                        localPlayer={localPlayer}
                        pingsTable={pingsTable}
                        playerIsInPlane={playerIsInPlane}
                    />
                :   
                    <></>
                }
            </div>
            {open &&
                <div className="details">
                    <div className="detail">
                        <span className="keyboard">LMB</span>
                        Place marker
                    </div>
                    <div className="detail">
                        <span className="keyboard">RMB</span>
                        Remove marker
                    </div>
                    <div className="detail">
                        <span className="keyboard">Wheel</span>
                        Zoom In / Out
                    </div>
                </div>
            }
        </>
    );
};

export default MiniMap;
