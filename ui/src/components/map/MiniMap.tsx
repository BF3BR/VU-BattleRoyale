import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../store/RootReducer";

import MapPixi from "./MapPixi";

import "./MiniMap.scss";

interface StateFromReducer {
    open: boolean;
    showMinimap: boolean;
    playerYaw: number|null;
}

type Props = StateFromReducer;

const MiniMap: React.FC<Props> = ({ 
    open,
    showMinimap,
    playerYaw,
}) => {
    return (
        <>
            <div id="miniMap" className={(showMinimap ? "showMinimap" : "hideMinimap") + " " +  (open ? "open" : "")}>
                <div 
                    id="pixiRotator"
                    style={{transform: `rotate(-${playerYaw}deg` }}
                >
                    <MapPixi />
                </div>
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
        playerYaw: state.PlayerReducer.player.yaw,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MiniMap);
