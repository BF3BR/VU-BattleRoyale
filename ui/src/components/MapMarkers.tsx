import React, { useCallback, useEffect, useState } from "react";

import { connect, ReactReduxContext } from "react-redux";
import { RootState } from "../store/RootReducer";

import Ping from "../helpers/PingHelper";

import ContextBridge from "./map/elements/ContextBridge";
import { Stage } from "@inlet/react-pixi";
import * as PIXI from 'pixi.js';
import { Graphics } from '@inlet/react-pixi';
import { GlowFilter } from "@pixi/filter-glow";

import "./MapMarkers.scss";
import { getConvertedPlayerColor } from "./map/elements/ElementHelpers";

interface StateFromReducer {
    pingsTable: Ping[] | null;
}

type Props = StateFromReducer;

const stageOptions = {
    antialias: true,
    autoDensity: false,
    backgroundAlpha: 0,
};

const MapMarkers: React.FC<Props> = ({ pingsTable }) => {
    const [dimensions, setDimensions] = useState({
        height: window.innerHeight,
        width: window.innerWidth
    });

    useEffect(() => {
        function handleResize() {
            setDimensions({
                height: window.innerHeight,
                width: window.innerWidth
            })
        }
        window.addEventListener('resize', handleResize)
        return () => {
            window.removeEventListener('resize', handleResize)
        }
    });

    function Circle(props: any) {
        const draw = useCallback((g) => {
            var color = getConvertedPlayerColor(props.color);
            g.clear();
            g.beginFill(color);
            g.lineStyle({
                width: 3,
                color: color,
                alpha: 1,
                join: PIXI.LINE_JOIN.MITER,
                miterLimit: 10,
            });
            g.drawCircle(props.x, props.y, 25);
            g.endFill();
            g.filters = [new GlowFilter({
                distance: 20,
                outerStrength: 1.5,
                innerStrength: .1,
                color: color,
            })];
        }, [props]);
        return <Graphics x={0} y={0} draw={draw} />;
    }

    return (
        <div id="mapMarkersHolder">
            <ContextBridge
                Context={ReactReduxContext}
                render={(children: any) => (
                    <Stage
                        width={dimensions.width}
                        height={dimensions.height}
                        options={stageOptions}
                    >
                        {children}
                    </Stage>
                )}
            >
                {console.log(pingsTable)}
                {pingsTable.map((ping: Ping, _: number) => (
                    <Circle
                        x={ping.worldPos.x}
                        y={ping.worldPos.y}
                        color={ping.color}
                        key={ping.id}
                    />
                ))}
            </ContextBridge>
        </div>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PingReducer
        pingsTable: state.PingReducer.pings,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MapMarkers);
