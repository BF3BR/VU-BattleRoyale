import React, { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { RootState } from "../RootReducer";
import { KillmsgState } from "./Types";

import "./KillMessage.scss";

const KillMessage: React.FC = () => {
    const killmsgFromReducer = useSelector(
        (state: RootState) => state.KillmsgReducer
    );

    const [localKillmsg, setLocalKillmsg] = useState<KillmsgState|null>(null);

    let interval: any = null;
    useEffect(() => {
        if (killmsgFromReducer.killed !== null) {

            setLocalKillmsg({
                killed: killmsgFromReducer.killed,
                kills: killmsgFromReducer.kills,
                enemyName: killmsgFromReducer.enemyName,
            });

            interval = setInterval(() => {
                onEnd();
            }, 4000);
        }

        return () => {
            if (interval !== null) {
                onEnd();
            }
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [killmsgFromReducer]);

    const onEnd = () => {
        setLocalKillmsg(null);

        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (
        <>
            {localKillmsg !== null &&
                <div id="KillMessage">
                    {localKillmsg.killed !== null &&
                        <>
                            You {localKillmsg.killed ? 'killed' : 'knocked out'} {localKillmsg.enemyName??' - '}
                            {localKillmsg.killed &&
                                <span>{localKillmsg.kills??0} kills</span>
                            }
                        </>
                    }
                </div>
            }
        </>
    );
};

export default KillMessage;
