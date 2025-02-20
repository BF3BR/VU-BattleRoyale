import * as PIXI from 'pixi.js';
import '@pixi/graphics-extras';

import viewAngles from "../../../assets/img/viewangles_texture.png";
const viewAnglesTexture = PIXI.Texture.from(viewAngles);

export const drawPlayer = (g: any, color: number, spectating?: boolean) => {
    const sideLength = 12;
    let _color = color;

    if (spectating) {
        _color = 0xffffff;
    }

    g.clear();
    g.beginFill(_color, 0.4);    
    g.lineStyle({
        width: 4,
        color: _color,
        alpha: 1,
        join: PIXI.LINE_JOIN.ROUND,
        miterLimit: 10,
    });
    g.moveTo(0, 0 + sideLength / 2);
    g.lineTo(0 - sideLength, 0 + sideLength);
    g.lineTo(0, 0 - sideLength);
    g.lineTo(0 + sideLength, 0 + sideLength);
    g.lineTo(0, 0 + sideLength / 2);
    g.closePath();
    g.endFill();
};

export const drawPlayerVision = (g: any) => {
    const sideLength = 50;
    g.filters = [];
    g.clear();
    
    const textureMatrix = new PIXI.Matrix();
    textureMatrix.rotate(-Math.PI / 2);
    textureMatrix.scale(2, 2);

    g.beginTextureFill({
        texture: viewAnglesTexture,
        matrix: textureMatrix,
        alpha: 0.35,
    });
    g.moveTo(-5, -7);
    g.lineTo(0 - sideLength, -sideLength * 1.5);
    g.lineTo(0 + sideLength, -sideLength * 1.5);
    g.lineTo(5, -7);
    g.lineTo(0, -10);
    g.closePath();
    g.endFill();
};

export const getConvertedPlayerColor = (color: string) => {
    const rgba = color.replace(/^rgba?\(|\s+|\)$/g, '').split(',');
    const hex = `0x${((1 << 24) + (parseInt(rgba[0]) << 16) + (parseInt(rgba[1]) << 8) + parseInt(rgba[2])).toString(16).slice(1)}`;
    return parseInt(hex);
};

export const getMapPos = (pos: number, topLeftPos: number, textureWidthHeight: number, worldWidthHeight: number)  => {
    return (topLeftPos - pos) * (textureWidthHeight / worldWidthHeight);
};

export const getGamePos = (pos: number, topLeftPos: number, textureWidthHeight: number, worldWidthHeight: number)  => {
    return topLeftPos - (pos * (worldWidthHeight / textureWidthHeight));
};

