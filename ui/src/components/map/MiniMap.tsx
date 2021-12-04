import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../store/RootReducer";

import MapPixi from "./MapPixi";

import "./MiniMap.scss";

interface StateFromReducer {
    open: boolean;
    showMinimap: boolean;
    minimapRotation: boolean;
    playerYaw: number|null;
    spectating: boolean;
}

type Props = StateFromReducer;

const MiniMap: React.FC<Props> = ({ 
    open,
    showMinimap,
    playerYaw,
    minimapRotation,
    spectating,
}) => {
    return (
        <>
            <div id="miniMap" className={(showMinimap ? "showMinimap" : "hideMinimap") + " " +  (open ? "open" : "")}>
                <div 
                    id="pixiRotator"
                    style={{transform: `rotate(-${minimapRotation ? playerYaw : 0}deg` }}
                >
                    <MapPixi />
                </div>
            </div>
            {!open &&
                <div className="nextmap-details">
                    <div className="detail">
                        <span className="keyboard">N</span>
                        ZOOM
                    </div>
                    <div className="detail">
                        <span className="keyboard">M</span>
                        MAP
                    </div>
                    <div className="detail">
                        <span className="keyboard">TAB</span>
                        INVENTORY
                    </div>
                </div>
            }
            {(open && !spectating) &&
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
        minimapRotation: state.MapReducer.minimapRotation,
        // PlayerReducer
        playerYaw: state.PlayerReducer.player.yaw,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MiniMap);
