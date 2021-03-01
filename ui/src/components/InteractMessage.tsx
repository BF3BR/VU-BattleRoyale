import React from "react";

import "./InteractMessage.scss";

interface Props {
    message: string|null;
    keyboard: string|null;
};

const InteractMessage: React.FC<Props> = ({ message, keyboard }) => {
    return (
        <div id="Messages">
            {message &&
                <div className="MessageCenter">
                    {keyboard &&
                        <span className="keyboard">{keyboard??''}</span>
                    }
                    {message??''}
                </div>
            }
        </div>
    );
};

export default InteractMessage;
