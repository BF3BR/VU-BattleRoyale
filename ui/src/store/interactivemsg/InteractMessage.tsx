import React, { useEffect, useState } from "react";
import { connect, useSelector } from "react-redux";
import { RootState } from "../RootReducer";
import { InteractivemsgState } from "./Types";

import "./InteractMessage.scss";

interface StateFromReducer {
    gameState: string;
    uiState: "hidden" | "loading" | "game" | "menu";
    gameOverScreen: boolean;
    deployScreen: boolean;
}

type Props = StateFromReducer;

const InteractMessage: React.FC<Props> = ({
    deployScreen,
    uiState
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
            {(localInteractivemsg !== null && !deployScreen && uiState === "game") &&
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
        gameState: state.GameReducer.gameState,
        uiState: state.GameReducer.uiState,
        gameOverScreen: state.GameReducer.gameOver.enabled,
        deployScreen: state.GameReducer.deployScreen.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(InteractMessage);
