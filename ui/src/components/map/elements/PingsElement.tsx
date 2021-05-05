import React, { useCallback } from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import { GlowFilter } from "@pixi/filter-glow";
import * as PIXI from 'pixi.js';
import { Graphics } from '@inlet/react-pixi';

import Ping from "../../../helpers/PingHelper";
import { getConvertedPlayerColor, getMapPos } from './ElementHelpers';


interface StateFromReducer {
    pingsTable: Ping[];
}

type Props = {
    topLeftPos: { x: number, z: number },
    textureWidthHeight: number,
    worldWidthHeight: number,
} & StateFromReducer;

const PingsElement: React.FC<Props> = ({ 
    // Props
    topLeftPos,
    textureWidthHeight,
    worldWidthHeight,
    // Reducer
    pingsTable,
}) => {
    function Pings(props: any) {
        const draw = useCallback((g) => {
            g.clear();
            pingsTable.forEach((ping: Ping) => {
                var color = getConvertedPlayerColor(ping.color);
                var f = new PIXI.Graphics();
                f.clear();
                f.beginFill(color, 0.3)
                g.lineStyle({
                    width: 3, 
                    color: color, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                f.drawCircle(
                    getMapPos(ping.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                    getMapPos(ping.position.z, topLeftPos.z, textureWidthHeight, worldWidthHeight),
                    7.5
                );
                f.closePath();
                f.endFill();
                f.filters = [new GlowFilter({ 
                    distance: 7.5, 
                    outerStrength: 1.5, 
                    innerStrength: .1,
                    color: color,
                })];
                g.addChild(f);
            });
            // eslint-disable-next-line react-hooks/exhaustive-deps
        }, [props]);
      
        return <Graphics x={0} y={0} draw={draw} />;
    }

    return (
        <>
            {(pingsTable !== null && pingsTable.length > 0) &&
                <Pings />
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PlaneReducer
        pingsTable: state.PingReducer.pings,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(PingsElement);
