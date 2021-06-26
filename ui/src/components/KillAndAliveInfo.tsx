import React from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import eye from "../assets/img/eye.svg";

import "./KillAndAliveInfo.scss";

interface StateFromReducer {
    kills: number;
    alive: number;
    spectating: boolean;
    spectatorCount: number | null;
}

type Props = StateFromReducer;

const KillAndAliveInfo: React.FC<Props> = ({ kills, alive, spectating, spectatorCount }) => {

    return (
        <>
            <div id="KillAndAliveInfo">
                <div className="KillAndAliveBox Alive">
                    <h1>{alive}</h1>
                    <span>ALIVE</span>
                </div>
                {!spectating &&
                    <>
                        <div className="KillAndAliveBox Kill">
                            <h1>{kills}</h1>
                            <span>KILLS</span>
                        </div>
                        {(spectatorCount !== null && spectatorCount > 0) &&
                            <div className="KillAndAliveBox SpectatorCount">
                                <h1>{spectatorCount??0}</h1>
                                <img src={eye} alt="Spectator count" />
                            </div>
                        }
                    </>
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
        spectatorCount: state.SpectatorReducer.count,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(KillAndAliveInfo);
