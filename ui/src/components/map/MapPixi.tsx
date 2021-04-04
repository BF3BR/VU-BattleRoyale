import React, { useState, useEffect, useCallback, useRef, forwardRef } from 'react';
import { Stage, Sprite, PixiComponent, useApp, Graphics } from '@inlet/react-pixi';
import { Viewport } from 'pixi-viewport';
import {GlowFilter} from '@pixi/filter-glow';
import * as PIXI from 'pixi.js';
import '@pixi/graphics-extras';

import Vec3 from '../../helpers/Vec3Helper';
import Circle from '../../helpers/CircleHelper';
import Player from '../../helpers/PlayerHelper';
import Ping from '../../helpers/PingHelper';

import XP5_003 from "../../assets/img/XP5_003.jpg";
import airplane from "../../assets/img/airplane.svg";
import { MapsConfig } from '../../helpers/MapsConfigHelper';

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;

var airPlaneTexture = PIXI.Texture.from(airplane);

const width = 1024;
const height = 1024;

const stageOptions = {
    antialias: false,
    autoDensity: false,
    backgroundAlpha: 0
};

// Based on map config
let textureWidthHeight: number = 2048;
let worldWidthHeight: number = 1250;

let topLeftPos = {
    x: 0,
    z: 0,
};

var landscapeTexture: any = null;

window.OnLevelFinalized = (levelName?: string) => {
    switch (levelName) {
        case "Levels/XP5_003/XP5_003":
        default:
            landscapeTexture = PIXI.Texture.from(XP5_003);
            textureWidthHeight = MapsConfig["XP5_003"].textureWidthHeight;
            worldWidthHeight = MapsConfig["XP5_003"].worldWidthHeight;
            topLeftPos = MapsConfig["XP5_003"].topLeftPos;
            break;
    }
}

const getMapPos = (pos: number, topLeftPos: number)  => {
    return (topLeftPos - pos) * (textureWidthHeight / worldWidthHeight);
}

const getConvertedPlayerColor = (color: string) => {
    const rgba = color.replace(/^rgba?\(|\s+|\)$/g, '').split(',');
    const hex = `0x${((1 << 24) + (parseInt(rgba[0]) << 16) + (parseInt(rgba[1]) << 8) + parseInt(rgba[2])).toString(16).slice(1)}`;
    return parseInt(hex);
};

const PixiViewportComponent = PixiComponent("Viewport", {
    create(props: any) {
        const { app, ...viewportProps } = props;

        const viewport = new Viewport({
            ticker: props.app.ticker,
            interaction: props.app.renderer.plugins.interaction,
            ...viewportProps
        });

        viewport
            .drag()
            .pinch()
            .wheel({ percent: 1.35, smooth: 5 }) //, center: new PIXI.Point(500, 500)
            .decelerate()
            .bounce({ sides: 'all', time: 150, ease: 'easeInOutSine', underflow: 'center'})
            .clampZoom({ minWidth: 400, maxWidth: 2000 });

        return viewport;
    },
    applyProps(viewport: any, _oldProps: any, _newProps: any) {
        const { plugins: oldPlugins, children: oldChildren, ...oldProps } = _oldProps;
        const { plugins: newPlugins, children: newChildren, ...newProps } = _newProps;

        Object.keys(newProps).forEach((p) => {
            if (oldProps[p] !== newProps[p]) {
                viewport[p] = newProps[p];
            }
        });
    },
    didMount() {
        
    }
});

const PixiViewport = forwardRef((props: any, ref: any) => (
    <PixiViewportComponent ref={ref} app={useApp()} {...props} />
));

interface MapPixiProps {
    open: boolean;
    playerPos: Vec3;
    playerYaw: number;
    planePos: Vec3|null;
    planeYaw: number|null;
    innerCircle: Circle;
    outerCircle: Circle;
    pingsTable: Array<Ping>;
    team: Player[];
    localPlayer: Player;
    playerIsInPlane: boolean;
};

const MapPixi: React.FC<MapPixiProps> = ({ 
    open, 
    playerPos, 
    playerYaw, 
    planePos, 
    planeYaw, 
    innerCircle, 
    outerCircle, 
    pingsTable,
    team,
    localPlayer,
    playerIsInPlane
}) => {
    const viewportRef = useRef(null);
    const followPlayer = useRef(null);

    const [snapZoomHeight, setSnapZoomHeight] = useState<number>(600);

    const focus = useCallback(() => {
        const viewport = viewportRef.current;
        const [x, y, width, height] = [1000, 1000, 2000, 2000];

        if (viewport == null) {
            return;
        }

        // pause following
        viewport.plugins.pause('follow');

        viewport.plugins.resume('wheel');
        viewport.plugins.resume('drag');

        // and snap to selected
        viewport.snapZoom({ width, height, removeOnComplete: true, time: 100 });
        viewport.snap(x, y, { removeOnComplete: true, time: 100 });
    }, []);

    const follow = useCallback((snapZoomHeight: number) => {
        const viewport = viewportRef.current;

        if (viewport == null) {
            return;
        }

        viewport.plugins.pause('wheel');
        viewport.plugins.pause('drag');

        viewport.snapZoom({ width: snapZoomHeight, height: snapZoomHeight, time: 100 });
        viewport.follow(followPlayer.current, { speed: 50 });
    }, []);

    useEffect(() => {
        if (open) {
            focus();
        } else {
            follow(snapZoomHeight);

            if (!navigator.userAgent.includes('VeniceUnleashed')) {
                if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                    return;
                }
            }
            WebUI.Call('ResetMouse');
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open]);

    window.OnMapEnableMouse = () => {
        if (open) {
            if (!navigator.userAgent.includes('VeniceUnleashed')) {
                if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
                    return;
                }
            }
            WebUI.Call('EnableMouse');
        }
    }

    window.OnMapZoomChange = () => {
        if (!open) {
            switch (snapZoomHeight) {
                case 600:
                    setSnapZoomHeight(900);
                    follow(900);
                    break;
                case 900:
                    setSnapZoomHeight(1100);
                    follow(1100);
                    break;
                case 1100:
                default:
                    setSnapZoomHeight(600);
                    follow(600);
                    break;
            }
        }
    }

    const drawPlayer = React.useCallback((g: any, color: number, local: boolean) => {
        var sideLegnth = 25;
        g.clear();
        g.beginFill(color, 0.3);
        g.lineStyle({
            width: 4, 
            color: color, 
            alpha: 1,
            join: PIXI.LINE_JOIN.MITER,
            miterLimit: 10,
        });
        g.moveTo(0, 0 + sideLegnth / 2);
        g.lineTo(0 - sideLegnth, 0 + sideLegnth);
        g.lineTo(0, 0 - sideLegnth);
        g.lineTo(0 + sideLegnth, 0 + sideLegnth);
        g.lineTo(0, 0 + sideLegnth / 2);
        g.closePath();
        g.endFill();
        g.filters = [new GlowFilter({ 
            distance: 15, 
            outerStrength: 1.5, 
            innerStrength: .1,
            color: color,
        })];
    }, []);

    function Circle(props: any) {
        const draw = useCallback((g) => {
            var radius = props.circle.radius ?? 100;
            radius = radius * (textureWidthHeight / worldWidthHeight);

            g.clear();

            if (props.outer) {
                g.beginFill(0xff9900, 0.3)
                g.drawTorus(getMapPos(props.circle.center.x, topLeftPos.x), getMapPos(props.circle.center.z, topLeftPos.z), radius, textureWidthHeight * 2);
                g.endFill();

                var f = new PIXI.Graphics();
                f.lineStyle({
                    width: 5, 
                    color: 0xff9900, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                f.drawCircle(getMapPos(props.circle.center.x, topLeftPos.x), getMapPos(props.circle.center.z, topLeftPos.z), radius);
                f.filters = [new GlowFilter({ 
                    distance: 20, 
                    outerStrength: 1.5, 
                    innerStrength: .1,
                    color: 0xff9900,
                })];
                g.addChild(f);
            } else {
                g.lineStyle({
                    width: 5, 
                    color: 0xffffff, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                g.drawCircle(getMapPos(props.circle.center.x, topLeftPos.x), getMapPos(props.circle.center.z, topLeftPos.z), radius);
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

    function Pings(props: any) {
        const draw = useCallback((g) => {
            g.clear();
            pingsTable.forEach((ping: Ping) => {
                var color = getConvertedPlayerColor(ping.color)
                var f = new PIXI.Graphics();
                f.clear();
                f.beginFill(color, 0.3)
                g.lineStyle({
                    width: 5, 
                    color: color, 
                    alpha: 1,
                    join: PIXI.LINE_JOIN.MITER,
                    miterLimit: 10,
                });
                f.drawCircle(
                    getMapPos(ping.position.x, topLeftPos.x),
                    getMapPos(ping.position.z, topLeftPos.z),
                    15
                );
                f.closePath();
                f.endFill();
                f.filters = [new GlowFilter({ 
                    distance: 15, 
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
            <Stage 
                width={width} 
                height={height} 
                options={stageOptions}
                style={{ transform: "rotate(-" + playerYaw + "deg)" }}
            >
                <PixiViewport
                    ref={viewportRef}
                    plugins={["drag", "pinch", "wheel", "decelerate"]}
                    screenWidth={width}
                    screenHeight={height}
                    worldWidth={textureWidthHeight}
                    worldHeight={textureWidthHeight}
                >
                    {landscapeTexture !== null &&
                        <Sprite
                            texture={landscapeTexture}
                            anchor={0}
                            scale={1}
                            width={textureWidthHeight}
                            height={textureWidthHeight}
                            angle={0}
                        />
                    }

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

                    {(team !== null && team.length > 0 && localPlayer !== null) &&
                        team
                        .filter((player: Player) => player.name !== localPlayer.name)
                        .filter((player: Player) => player.state !== 3)
                        .filter((player: Player) => (player.position.x !== null && player.position.z !== null))
                        .map((player: Player, key: number) => (
                            <Graphics 
                                draw={(g: any) => drawPlayer(g, getConvertedPlayerColor(player.color), false)}
                                x={getMapPos(player.position.x, topLeftPos.x)}
                                y={getMapPos(player.position.z, topLeftPos.z)}
                                angle={player.yaw}
                                scale={1}
                                key={key}
                            />
                        ))
                    }

                    {planePos !== null &&
                        <>
                            <Sprite
                                texture={airPlaneTexture}
                                anchor={0.5}
                                width={50}
                                height={50}
                                x={getMapPos(planePos.x, topLeftPos.x)}
                                y={getMapPos(planePos.z, topLeftPos.z)}
                                angle={planeYaw}
                                scale={open ? .35 : 0.35}
                            />                        
                        </>
                    }

                    <Graphics 
                        draw={(g: any) => drawPlayer(g, localPlayer !== null ? getConvertedPlayerColor(localPlayer.color) : 0xff0000, true)}
                        x={getMapPos(playerPos.x, topLeftPos.x)}
                        y={getMapPos(playerPos.z, topLeftPos.z)}
                        angle={playerYaw}
                        ref={followPlayer}
                        scale={1}
                        visible={!playerIsInPlane}
                    />

                    {(pingsTable !== null && pingsTable.length > 0) &&
                        <Pings />
                    }
                </PixiViewport>
            </Stage>
        </>
    );
};

export default MapPixi;

declare global {
    interface Window {
        OnMapZoomChange: () => void;
        OnMapEnableMouse: () => void;
        OnLevelFinalized: (levelName?: any) => void;
    }
}
