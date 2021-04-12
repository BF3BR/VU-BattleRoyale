import React, { useEffect, useState } from "react";

import Ping from "../helpers/PingHelper";

import "./MapMarkers.scss";

interface Props {
    pingsTable: Ping[]|null;
};

const MapMarkers: React.FC<Props> = ({ pingsTable }) => {
    const [pingsScreenTable, setPingsScreenTable] = useState<Ping[]>([]);

    window.OnUpdateMarker = (p_Key: string, p_WorldToScreenX: number, p_WorldToScreenY: number) => {
        /*let pingIndex = pingsScreenTable.findIndex((ping: Ping, _: number) => ping.id === p_Key);
        if (pingIndex !== undefined && pingIndex !== null) {
            let pings = [ ...pingsScreenTable ];
            let ping = { ...pings[pingIndex] };
            ping.worldPos = {
                x: p_WorldToScreenX,
                y: p_WorldToScreenY,
                z: 0,
            };
            pings[pingIndex] = ping;
            setPingsScreenTable(pings);
        }*/
    }

    /*useEffect(() => {
        setPingsScreenTable(pingsTable);
    }, [pingsTable]);*/

    return (
        <div id="mapMarkersHolder">
            {/*pingsScreenTable.map((ping: Ping, _: number) => (
                <div 
                    key={ping.id} 
                    className="screenMarker" 
                    style={{ left: ping.worldPos.x, top: ping.worldPos.y }}
                >
                    <span>👋</span>
                </div>
            ))*/}
        </div>
    );
};

export default MapMarkers;

declare global {
    interface Window {
        OnUpdateMarker: (p_Key: string, p_WorldToScreenX: number, p_WorldToScreenY: number) => void;
    }
}
