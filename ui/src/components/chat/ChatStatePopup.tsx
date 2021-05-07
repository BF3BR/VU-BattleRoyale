import React, { useEffect, useState } from "react";
import { ChatState, ChatStateString } from "../../helpers/chat/ChatState";

interface Props {
    chatState: ChatState;
    deployScreen: boolean;
}

const BombPlantInfoBox: React.FC<Props> = ({ chatState, deployScreen }) => {
    const [firstRun, setFirstRun] = useState<boolean>(true);
    const [visible, setVisible] = useState<boolean>(false);

    useEffect(() => {
        if (firstRun) {
            setFirstRun(false);
            return;
        }
        setVisible(true);
        const interval = setTimeout(() => {
            setVisible(false);
        }, 1000);
        return () => {
            clearTimeout(interval);
        }
    }, [chatState]);

    return (
        <>
            {visible &&
                <div id="VuChatStatePopup" className={deployScreen ? "deployScreen": ""}>
                    Chat mode: {ChatStateString[chatState]??''}
                </div>
            }
        </>
    );
};

export default BombPlantInfoBox;
