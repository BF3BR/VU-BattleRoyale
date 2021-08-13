import React, { useEffect, useState } from "react";
import { useSelector } from "react-redux";
import { RootState } from "../RootReducer";
import { KillmsgState } from "./Types";

import kill from "../../assets/sounds/kill.mp3";
import downed from "../../assets/sounds/downed.mp3";

import "./KillMessage.scss";

const killAudio = new Audio(kill);
killAudio.volume = 0.3;
killAudio.autoplay = false;
killAudio.loop = false;

const downAudio = new Audio(downed);
downAudio.volume = 0.3;
downAudio.autoplay = false;
downAudio.loop = false;

const KillMessage: React.FC = () => {
    const killmsgFromReducer = useSelector(
        (state: RootState) => state.KillmsgReducer
    );

    const [localKillmsg, setLocalKillmsg] = useState<KillmsgState|null>(null);

    let interval: any = null;
    useEffect(() => {
        if (killmsgFromReducer.killed !== null) {
            
            if (killmsgFromReducer.killed) {
                killAudio.play();
            } else {
                downAudio.play();
            }

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
        killAudio.currentTime = 0.0;
        killAudio.pause();

        downAudio.currentTime = 0.0;
        downAudio.pause();

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
