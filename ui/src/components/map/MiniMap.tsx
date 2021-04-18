import React from "react";
import { connect } from "react-redux";

import Circle from "../../helpers/CircleHelper";
import Ping from "../../helpers/PingHelper";
import Player from "../../helpers/PlayerHelper";
import Vec3 from "../../helpers/Vec3Helper";
import { RootState } from "../../store/RootReducer";

import MapPixi from "./MapPixi";

import "./MiniMap.scss";

interface StateFromReducer {
    open: boolean;
    showMinimap: boolean;
    playerPos: Vec3|null;
    playerYaw: number|null;
}

type Props = StateFromReducer;

const MiniMap: React.FC<Props> = ({ 
    open, 
    showMinimap,
    playerPos, 
    playerYaw, 
}) => {
    return (
        <>
            <div id="miniMap" className={(showMinimap ? "showMinimap" : "hideMinimap") + " " +  (open?'open':'')}>
                {(playerPos !== null && playerYaw !== null) &&
                    <MapPixi />
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

const mapStateToProps = (state: RootState) => {
    return {
        // MapReducer
        open: state.MapReducer.open,
        showMinimap: state.MapReducer.show,
        // PlayerReducer
        playerPos: state.PlayerReducer.player.position,
        playerYaw: state.PlayerReducer.player.yaw,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MiniMap);
