import React, { useEffect } from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import Ping from "../helpers/PingHelper";
import { PlaySound, Sounds } from "../helpers/SoundHelper";

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

const PingSoundManager: React.FC<Props> = ({ pingsTable, lastPing }) => {
    
    let interval: any = null;
    useEffect(() => {
        const latestPing = pingsTable.filter((ping: Ping) => ping.id === lastPing);
        if (latestPing.length > 0) {
            if (latestPing[0].type === 1) {
                PlaySound(Sounds.PingEnemy);
            } else {
                PlaySound(Sounds.Ping);
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
        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (<></>);
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
export default connect(mapStateToProps, mapDispatchToProps)(PingSoundManager);

