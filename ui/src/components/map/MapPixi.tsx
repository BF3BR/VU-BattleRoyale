import React, { useState, useEffect, useCallback, useRef, forwardRef } from 'react';
import { connect, ReactReduxContext } from "react-redux";
import { RootState } from '../../store/RootReducer';

import { Stage, Sprite, PixiComponent, useApp } from '@inlet/react-pixi';
import { Viewport } from 'pixi-viewport';

import XP5_003 from "../../assets/img/XP5_003.jpg";
import { MapsConfig } from '../../helpers/MapsConfigHelper';
import { sendToLua } from '../../Helpers';

import * as PIXI from 'pixi.js';
import '@pixi/graphics-extras';

import PlayerElement from './elements/PlayerElement';
import ContextBridge from './elements/ContextBridge';
import CircleElement from './elements/CircleElement';
import PlaneElement from './elements/PlaneElement';
import PingsElement from './elements/PingsElement';
import TeamElement from './elements/TeamElement';
import GridElement from './elements/GridElement';
import { getGamePos } from './elements/ElementHelpers';

PIXI.settings.SCALE_MODE = PIXI.SCALE_MODES.NEAREST;

const stageOptions = {
    antialias: false,
    autoDensity: false,
    backgroundAlpha: 0
};

const widthAndHeight = 1024;

// Based on map config
let textureWidthHeight: number = 1024;
let worldWidthHeight: number = 2500;

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

const PixiViewportComponent = PixiComponent("Viewport", {
    create(props: any) {
        const { app, ...viewportProps } = props;

        const viewport = new Viewport({
            ticker: props.app.ticker,
            interaction: props.app.renderer.plugins.interaction,
            ...viewportProps
        });

        const handleClick = (data: any) => {
            if (data.world !== null) {
                if (data.event.data.originalEvent.which === 3) {
                    sendToLua("WebUI:PingRemoveFromMap");
                } else {
                    sendToLua("WebUI:PingFromMap", JSON.stringify({ 
                        x: getGamePos(data.world.x, topLeftPos.x, textureWidthHeight, worldWidthHeight),
                        y: getGamePos(data.world.y, topLeftPos.z, textureWidthHeight, worldWidthHeight)
                    }));
                }
            }
        }

        viewport
            .drag({ factor: .65 })
            .pinch()
            .wheel({ percent: .65, smooth: 10 })
            .decelerate()
            .bounce({ sides: 'all', time: 100, ease: 'easeInOutSine', underflow: 'center'})
            .clampZoom({ minWidth: 200, maxWidth: 1024 })
            .on('clicked', handleClick);

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
    }
});

const PixiViewport = forwardRef((props: any, ref: any) => (
    <PixiViewportComponent ref={ref} app={useApp()} {...props} />
));

interface StateFromReducer {
    open: boolean;
}

type Props = StateFromReducer;

const MapPixi: React.FC<Props> = ({ open }) => {
    const viewportRef = useRef(null);
    const followPlayer = useRef(null);

    const [snapZoomHeight, setSnapZoomHeight] = useState<number>(150);

    const focus = useCallback(() => {
        const viewport = viewportRef.current;

        if (viewport === null || viewport === undefined) {
            return;
        }

        const [x, y, width, height] = [512, 512, 1024, 1024];

        // pause following
        viewport.plugins.pause('follow');

        viewport.plugins.resume('wheel');
        viewport.plugins.resume('drag');
        viewport.plugins.resume('bounce');

        // and snap to selected
        viewport.snapZoom({ width, height, removeOnComplete: true, time: 50 });
        viewport.snap(x, y, { removeOnComplete: true, time: 50 });
    }, []);

    const follow = useCallback((snapZoomHeight: number) => {
        const viewport = viewportRef.current;

        if (viewport === null || viewport === undefined) {
            return;
        }

        viewport.plugins.pause('wheel');
        viewport.plugins.pause('drag');
        viewport.plugins.pause('bounce');

        viewport.snapZoom({ width: snapZoomHeight, height: snapZoomHeight, time: 100 });
        if (followPlayer && followPlayer.current !== null) {
            viewport.follow(followPlayer.current, { speed: 50 });
        }
    }, []);

    useEffect(() => {
        if (open) {
            focus();
        } else {
            follow(snapZoomHeight);
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [open]);

    window.OnMapZoomChange = () => {
        if (!open) {
            switch (snapZoomHeight) {
                case 150:
                    setSnapZoomHeight(300);
                    follow(300);
                    break;
                case 300:
                    setSnapZoomHeight(600);
                    follow(600);
                    break;
                case 600:
                default:
                    setSnapZoomHeight(150);
                    follow(150);
                    break;
            }
        }
    }

    return (
        <ContextBridge
            Context={ReactReduxContext}
            render={(children: any) => (
                <Stage 
                    width={widthAndHeight} 
                    height={widthAndHeight} 
                    options={stageOptions}
                >
                    {children}
                </Stage>
            )}
        >
            <PixiViewport
                ref={viewportRef}
                plugins={["drag", "pinch", "wheel", "decelerate"]}
                screenWidth={widthAndHeight}
                screenHeight={widthAndHeight}
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

                <GridElement 
                    width={widthAndHeight}
                    height={widthAndHeight}
                />

                <CircleElement 
                    topLeftPos={topLeftPos}
                    textureWidthHeight={textureWidthHeight}
                    worldWidthHeight={worldWidthHeight}
                />

                <TeamElement
                    topLeftPos={topLeftPos}
                    textureWidthHeight={textureWidthHeight}
                    worldWidthHeight={worldWidthHeight}
                />

                <PlaneElement 
                    topLeftPos={topLeftPos}
                    textureWidthHeight={textureWidthHeight}
                    worldWidthHeight={worldWidthHeight}
                />

                <PingsElement
                    topLeftPos={topLeftPos}
                    textureWidthHeight={textureWidthHeight}
                    worldWidthHeight={worldWidthHeight}
                />

                <PlayerElement 
                    forwardRef={followPlayer}
                    topLeftPos={topLeftPos}
                    textureWidthHeight={textureWidthHeight}
                    worldWidthHeight={worldWidthHeight}
                />
            </PixiViewport>
        </ContextBridge>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // MapReducer
        open: state.MapReducer.open,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(MapPixi);

declare global {
    interface Window {
        OnMapZoomChange: () => void;
        OnLevelFinalized: (levelName?: any) => void;
    }
}
