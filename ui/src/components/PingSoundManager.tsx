import React, { useEffect } from "react";
import { connect } from "react-redux";
import Ping from "../helpers/PingHelper";
import { RootState } from "../store/RootReducer";

import ping from "../assets/sounds/ping.mp3";
import pingEnemy from "../assets/sounds/ping_enemy.mp3";
import { lastPing } from "../store/ping/Actions";
import { VolumeConst } from "../helpers/SoundHelper";

const pingAudio = new Audio(ping);
pingAudio.volume = VolumeConst;
pingAudio.autoplay = false;
pingAudio.loop = false;
pingAudio.pause();

const pingEnemyAudio = new Audio(pingEnemy);
pingEnemyAudio.volume = VolumeConst;
pingEnemyAudio.autoplay = false;
pingEnemyAudio.loop = false;
pingEnemyAudio.pause();

/*
	Default = 0,
	Enemy = 1,
	Weapon = 2,
	Ammo = 3,
	Armor = 4,
	Health = 5
*/

interface StateFromReducer {
    pingsTable: Ping[];
    lastPing: string|null;
}

type Props = StateFromReducer;

const SpectatorInfo: React.FC<Props> = ({ pingsTable, lastPing }) => {
    
    let interval: any = null;
    useEffect(() => {
        const latestPing = pingsTable.filter((ping: Ping) => ping.id === lastPing);
        if (latestPing.length > 0) {
            if (latestPing[0].type === 1) {
                pingEnemyAudio.play();
            } else {
                pingAudio.play();
            }
    
            interval = setInterval(() => {
                onEnd();
            }, 1000);
        }

        return () => {
            onEnd();
        }
    }, [pingsTable]);

    const onEnd = () => {
        pingAudio.currentTime = 0.0;
        pingAudio.pause();

        pingEnemyAudio.currentTime = 0.0;
        pingEnemyAudio.pause();

        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (
        <> 
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PingReducer
        pingsTable: state.PingReducer.pings,
        lastPing: state.PingReducer.lastPing,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(SpectatorInfo);

