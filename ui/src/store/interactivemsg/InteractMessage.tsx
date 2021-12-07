import React, { useEffect, useState } from "react";
import { connect, useSelector } from "react-redux";
import { RootState } from "../RootReducer";
import { InteractivemsgState } from "./Types";

import "./InteractMessage.scss";

interface StateFromReducer {
    uiState: "hidden" | "loading" | "game" | "menu";
    deployScreen: boolean;
    spectating: boolean;
}

type Props = StateFromReducer;

const InteractMessage: React.FC<Props> = ({
    deployScreen,
    uiState,
    spectating
}) => {
    const interactivemsgFromReducer = useSelector(
        (state: RootState) => state.InteractivemsgReducer
    );

    const [localInteractivemsg, setLocalInteractivemsg] = useState<InteractivemsgState|null>(null);

    useEffect(() => {
        if (interactivemsgFromReducer.message !== null) {

            setLocalInteractivemsg({
                message: interactivemsgFromReducer.message,
                key: interactivemsgFromReducer.key,
            });
        }

        return () => {
            onEnd();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [interactivemsgFromReducer]);

    const onEnd = () => {
        setLocalInteractivemsg(null);
    }

    return (
        <div id="Messages">
            {(localInteractivemsg !== null && !deployScreen && uiState === "game" && !spectating) &&
                <>
                    {localInteractivemsg.message &&
                        <div className="MessageCenter">
                            {localInteractivemsg.key &&
                                <span className="keyboard">{localInteractivemsg.key??''}</span>
                            }
                            {localInteractivemsg.message??''}
                        </div>
                    }
                </>
            }
        </div>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // GameReducer
        uiState: state.GameReducer.uiState,
        deployScreen: state.GameReducer.deployScreen.enabled,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(InteractMessage);
