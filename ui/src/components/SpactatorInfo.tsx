import React from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import "./SpactatorInfo.scss";


interface StateFromReducer {
    spectating: boolean;
    spectatorTarget: string;
}

type Props = StateFromReducer;

const SpactatorInfo: React.FC<Props> = ({ spectating, spectatorTarget }) => {

    return (
        <>
            <div id="SpactatorInfo" className={"card " + (spectating ? 'show' : '')}>
                <div className="card-header">
                    <h1>
                        Spectating
                        <span>
                            {spectatorTarget??''}
                        </span>
                    </h1>
                </div>
            </div>
            
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
export default connect(mapStateToProps, mapDispatchToProps)(SpactatorInfo);

