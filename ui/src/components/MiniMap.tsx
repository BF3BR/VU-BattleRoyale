import React from "react";
import Vec3 from "../helpers/Vec3";
import MapCanvas from "./MapCanvas";

import "./MiniMap.scss";

interface Props {
    open: boolean;
    playerPos: Vec3|null;
    playerYaw: number|null;
}

const MiniMap: React.FC<Props> = ({ open, playerPos, playerYaw }) => {

    return (
        <>
            <div id="miniMap" className={open?'open':''}>
                <MapCanvas open={open} playerPos={playerPos} playerYaw={playerYaw} />
            </div>
            
        </>
    );
};

export default MiniMap;
