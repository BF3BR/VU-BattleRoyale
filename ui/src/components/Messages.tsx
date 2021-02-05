import React, { useState } from "react";

import "./Messages.scss";

interface Props {
    playerIsInPlane: boolean;
};

const Messages: React.FC<Props> = ({ playerIsInPlane }) => {
    return (
        <div id="Messages">
            {playerIsInPlane &&
                <div className="MessageCenter">
                    Press <span className="keyboard">E</span> to jump out of the plane.
                </div>
            }
        </div>
    );
};

export default Messages;

declare global {
    interface Window {
        OnPlayerIsInPlane: (isInPlane: boolean) => void;
    }
}
