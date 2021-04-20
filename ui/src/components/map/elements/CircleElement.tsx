import React, { useCallback } from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import { GlowFilter } from "@pixi/filter-glow";
import * as PIXI from 'pixi.js';
import { Graphics } from '@inlet/react-pixi';

import { getMapPos } from './ElementHelpers';
import Circle from "../../../helpers/CircleHelper";

interface StateFromReducer {
    innerCircle: Circle;
    outerCircle: Circle;
}

type Props = {
    topLeftPos: { x: number, z: number },
    textureWidthHeight: number,
    worldWidthHeight: number,
} & StateFromReducer;

const CircleElement: React.FC<Props> = ({ 
    // Props
    topLeftPos,
    textureWidthHeight,
    worldWidthHeight,
    // Reducer
    innerCircle,
    outerCircle,
}) => {

    function Circle(props: any) {
        const draw = useCallback((g) => {
            var radius = props.circle.radius ?? 100;
            radius = radius * (textureWidthHeight / worldWidthHeight);

            g.clear();

            if (props.outer) {
                g.beginFill(0xff9900, 0.3)
                g.drawTorus(
                    getMapPos(props.circle.center.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                    getMapPos(props.circle.center.z, topLeftPos.z, textureWidthHeight, worldWidthHeight),
                    radius,
                    textureWidthHeight * 2
                );
                g.endFill();

                var f = new PIXI.Graphics();
                f.lineStyle({
                    width: 3, 
                    color: 0xff9900, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                f.drawCircle(
                    getMapPos(props.circle.center.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                    getMapPos(props.circle.center.z, topLeftPos.z, textureWidthHeight, worldWidthHeight),
                    radius
                );
                f.filters = [new GlowFilter({ 
                    distance: 20, 
                    outerStrength: 1.5, 
                    innerStrength: .1,
                    color: 0xff9900,
                })];
                g.addChild(f);
            } else {
                g.lineStyle({
                    width: 3, 
                    color: 0xffffff, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                g.drawCircle(
                    getMapPos(props.circle.center.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                    getMapPos(props.circle.center.z, topLeftPos.z, textureWidthHeight, worldWidthHeight),
                    radius
                );
                g.filters = [new GlowFilter({ 
                    distance: 20, 
                    outerStrength: 1.5, 
                    innerStrength: .1,
                    color: 0xffffff,
                })];
            }
        }, [props]);
      
        return <Graphics x={0} y={0} draw={draw} />;
    }
    
    return (
        <>
            {innerCircle !== null &&
                <Circle 
                    circle={innerCircle}
                    outer={false}
                />
            }

            {(outerCircle !== null && outerCircle.radius < 4000) &&
                <Circle 
                    circle={outerCircle}
                    outer={true}
                />
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // CircleReducer
        innerCircle: state.CircleReducer.innerCircle,
        outerCircle: state.CircleReducer.outerCircle,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(CircleElement);
