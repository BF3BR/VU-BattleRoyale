import React from "react";

import Circle from "../../helpers/Circle";
import Ping from "../../helpers/Ping";
import Player from "../../helpers/Player";
import Vec3 from "../../helpers/Vec3";

import MapCanvas from "./MapCanvas";
import MapPixi from "./MapPixi";

import "./MiniMap.scss";

interface Props {
    open: boolean;
    playerPos: Vec3|null;
    playerYaw: number|null;
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
            
        </>
    );
};

export default MiniMap;
