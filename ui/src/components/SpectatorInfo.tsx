import React from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import "./SpectatorInfo.scss";


interface StateFromReducer {
    spectating: boolean;
    spectatorTarget: string;
}

type Props = StateFromReducer;

const SpectatorInfo: React.FC<Props> = ({ spectating, spectatorTarget }) => {

    return (
        <>
            {spectatorTarget &&
                <div id="SpectatorInfo" className={"card " + (spectating ? 'show' : '')}>
                    <div className="card-header">
                        <h1>
                            You are spectating
                        </h1>
                    </div>
                    <div className="card-content">
                        {spectatorTarget ? spectatorTarget : ""}
                    </div>
                    <div className="card-footer">
                        <div className="left">
                            <span className="keyboard">
                                {"Arrow Left"}
                            </span>
                            Prev. player
                        </div>
                        <div className="right">
                            Next player
                            <span className="keyboard">
                                {"Arrow Right"}
                            </span>
                        </div>
                    </div>
                </div>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
        spectatorTarget: state.SpectatorReducer.target,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(SpectatorInfo);

