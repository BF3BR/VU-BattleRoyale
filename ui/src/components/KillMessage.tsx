import React, { useEffect } from "react";

import "./KillMessage.scss";

interface Props {
    killed: boolean;
    enemyName: string|null;
    kills: number|null;
    resetMessage: () => void;
};

const KillMessage: React.FC<Props> = ({ killed, enemyName, kills, resetMessage }) => {
    useEffect(() => {
        if (killed !== null) {
            const interval = setInterval(() => {
                resetMessage();
            }, 4000);

            return () => {
                clearInterval(interval);
            }
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [killed]);

    return (
        <div id="KillMessage">
            {killed !== null &&
                <>
                    You {killed ? 'killed' : 'knocked out'} {enemyName??' - '}
                    {killed &&
                        <span>{kills??0} kills</span>
                    }
                </>
            }
        </div>
    );
};

export default KillMessage;
