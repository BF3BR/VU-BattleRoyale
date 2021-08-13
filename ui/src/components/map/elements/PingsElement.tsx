import React, { useCallback } from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import { GlowFilter } from "@pixi/filter-glow";
import * as PIXI from 'pixi.js';
import { Graphics, Sprite } from '@inlet/react-pixi';

import Ping from "../../../helpers/PingHelper";
import { getConvertedPlayerColor, getMapPos } from './ElementHelpers';

import medic from "../../../assets/img/medic.svg";
import shield from "../../../assets/img/inventory/shield.svg";
import running from "../../../assets/img/inventory/running.svg";
import rifle from "../../../assets/img/inventory/rifle.svg";
import bullets from "../../../assets/img/inventory/bullets.svg";
import crosshair from "../../../assets/img/inventory/crosshair.svg";

const medicTexture = PIXI.Texture.from(medic);
const shieldTexture = PIXI.Texture.from(shield);
const runningTexture = PIXI.Texture.from(running);
const rifleTexture = PIXI.Texture.from(rifle);
const bulletsTexture = PIXI.Texture.from(bullets);
const crosshairTexture = PIXI.Texture.from(crosshair);

interface StateFromReducer {
    pingsTable: Ping[];
    playerYaw: number;
    open: boolean;
    minimapRotation: boolean;
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
    playerYaw,
    open,
    minimapRotation
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
                    15
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

    const getPingTexture = (type: number) => {
        switch (type) {
            default:
            case 0:
                return crosshairTexture;
            case 1:
                return runningTexture;
            case 2:
                return rifleTexture;
            case 3:
                return bulletsTexture;
            case 4:
                return shieldTexture;
            case 5:
                return medicTexture;
        }
    }

    const getPingScale = (type: number) => {
        switch (type) {
            default:
            case 0:
                return 0.04;
            case 1:
                return 0.135;
            case 2:
                return 0.125;
            case 3:
                return 0.15;
            case 4:
                return 0.035;
            case 5:
                return 0.035;
        }
    }

    return (
        <>
            {(pingsTable !== null && pingsTable.length > 0) &&
                <>
                    {/*<Pings />*/}
                    {pingsTable.map((ping: Ping) => 
                        <Sprite
                            texture={getPingTexture(ping.type)}
                            anchor={0.5}
                            width={50}
                            height={50}
                            x={getMapPos(ping.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                            y={getMapPos(ping.position.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)}
                            scale={getPingScale(ping.type)}
                            angle={(open || !minimapRotation) ? 0 : playerYaw}
                            filters={[
                                new GlowFilter({
                                    distance: 35,
                                    outerStrength: 5,
                                    innerStrength: 0,
                                    color: getConvertedPlayerColor(ping.color),
                                })
                            ]}
                        />
                    )}
                </>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PlayerReducer
        playerYaw: state.PlayerReducer.player.yaw,
        // PingReducer
        pingsTable: state.PingReducer.pings,
        // MapReducer
        open: state.MapReducer.open,
        minimapRotation: state.MapReducer.minimapRotation,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(PingsElement);
