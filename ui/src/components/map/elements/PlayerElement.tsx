import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import { GlowFilter } from "@pixi/filter-glow";
import * as PIXI from 'pixi.js';
import { Graphics } from '@inlet/react-pixi';

import Vec3 from '../../../helpers/Vec3Helper';
import { drawPlayer, getConvertedPlayerColor, getMapPos } from './ElementHelpers';
import Circle from "../../../helpers/CircleHelper";

interface StateFromReducer {
    playerPos: Vec3|null;
    playerYaw: number|null;
    playerIsInPlane: boolean;
    color: string|null;
}

type Props = {
    forwardRef: any;
    topLeftPos: { x: number, z: number },
    textureWidthHeight: number,
    worldWidthHeight: number,
    innerCircle: Circle,
} & StateFromReducer;

const PlayerElement: React.FC<Props> = ({ 
    // Props
    forwardRef,
    topLeftPos,
    textureWidthHeight,
    worldWidthHeight,
    // Reducer
    playerPos, 
    playerYaw, 
    color,
    playerIsInPlane,
    innerCircle,
}) => {
    function isInsideTheRadius(x: number, y: number, cx: number, cy: number, r: number) {
        var distancesquared = (x - cx) * (x - cx) + (y - cy) * (y - cy);
        return distancesquared <= r * r;
    }

    const drawPlayerToInnerLine = React.useCallback((g: any, innerCircle: Circle, x: number, y: number) => {
        var innerCircleX = getMapPos(innerCircle.center.x, topLeftPos.x, textureWidthHeight, worldWidthHeight);
        var innerCircleY = getMapPos(innerCircle.center.z, topLeftPos.z, textureWidthHeight, worldWidthHeight);
        var innerCircleRadius = innerCircle.radius * (textureWidthHeight / worldWidthHeight);
        g.clear();

        if (isInsideTheRadius(x, y, innerCircleX, innerCircleY, innerCircleRadius)) {
            return;
        }

        var theta = Math.atan2(y - innerCircleY, x - innerCircleX);
        var Px = innerCircleX + innerCircleRadius * Math.cos(theta);
        var Py = innerCircleY + innerCircleRadius * Math.sin(theta);

        g.lineStyle({
            width: 3, 
            color: 0xffffff, 
            alpha: 1,
            join: PIXI.LINE_JOIN.MITER,
            miterLimit: 10,
        });
        g.moveTo(x, y);
        g.lineTo(Px, Py);
        g.filters = [new GlowFilter({ 
            distance: 15, 
            outerStrength: 1.5, 
            innerStrength: .1,
            color: 0xffffff,
        })];
    }, []);
    
    return (
        <>
            {(innerCircle !== null && playerPos !== null) &&
                <Graphics 
                    draw={(g: any) => drawPlayerToInnerLine(
                        g,
                        innerCircle,
                        getMapPos(playerPos.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                        getMapPos(playerPos.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)
                    )}
                    x={0}
                    y={0}
                    angle={0}
                    scale={1}
                    visible={!playerIsInPlane}
                />
            }

            <Graphics 
                draw={(g: any) => drawPlayer(g, color !== null ? getConvertedPlayerColor(color) : 0xff0000)}
                x={getMapPos(playerPos?.x??0, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                y={getMapPos(playerPos?.z??0, topLeftPos.z,  textureWidthHeight, worldWidthHeight)}
                angle={playerYaw}
                scale={0.5}
                visible={!playerIsInPlane}
                ref={forwardRef}
            />
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PlayerReducer
        playerPos: state.PlayerReducer.player.position,
        playerYaw: state.PlayerReducer.player.yaw,
        playerIsInPlane: state.PlayerReducer.isOnPlane,
        color: state.PlayerReducer.player.color,
        // CircleReducer
        innerCircle: state.CircleReducer.innerCircle,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(PlayerElement);
