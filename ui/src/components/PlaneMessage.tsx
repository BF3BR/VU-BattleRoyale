import React from "react";

import "./Messages.scss";

interface Props {
    playerIsInPlane: boolean;
};

const PlaneMessage: React.FC<Props> = ({ playerIsInPlane }) => {
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

export default PlaneMessage;
