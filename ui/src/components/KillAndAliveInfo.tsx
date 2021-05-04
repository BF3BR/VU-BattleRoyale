import React from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import "./KillAndAliveInfo.scss";

interface StateFromReducer {
    kills: number;
    alive: number;
    spectating: boolean;
}

type Props = StateFromReducer;

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

const mapStateToProps = (state: RootState) => {
    return {
        // PlayerReducer
        kills: state.PlayerReducer.player.kill,
        // GameReducer
        alive: state.GameReducer.players.alive,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(KillAndAliveInfo);
