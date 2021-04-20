import React, { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { RootState } from "../RootReducer";
import { InteractivemsgState } from "./Types";

import "./InteractMessage.scss";

const InteractMessage: React.FC = () => {
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
            {localInteractivemsg !== null &&
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

export default InteractMessage;
