import React from "react";

import Circle from "../helpers/Circle";
import Vec3 from "../helpers/Vec3";

import MapCanvas from "./MapCanvas";

import "./MiniMap.scss";

interface Props {
    open: boolean;
    playerPos: Vec3|null;
    playerYaw: number|null;
    innerCircle: Circle|null;
    outerCircle: Circle|null;
    playerIsInPlane: boolean;
}

const MiniMap: React.FC<Props> = ({ open, playerPos, playerYaw, innerCircle, outerCircle, playerIsInPlane }) => {

    return (
        <>
            <div id="miniMap" className={open?'open':''}>
                {playerPos !== null && playerYaw !== null ?
                    <MapCanvas 
                        open={open} 
                        playerPos={playerPos} 
                        playerYaw={playerYaw} 
                        innerCircle={innerCircle} 
                        outerCircle={outerCircle} 
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
