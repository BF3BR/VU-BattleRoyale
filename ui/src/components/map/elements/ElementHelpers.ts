import React from "react";
import * as PIXI from 'pixi.js';
import { GlowFilter } from '@pixi/filter-glow';
import '@pixi/graphics-extras';

import viewAngles from "../../../assets/img/viewangles_texture.png";
const viewAnglesTexture = PIXI.Texture.from(viewAngles);

export const drawPlayer = (g: any, color: number) => {
    var sideLength = 20;
    g.clear();
    g.beginFill(color, 0.4);    
    g.lineStyle({
        width: 6,
        color: color,
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
    g.filters = [new GlowFilter({
        distance: 35,
        outerStrength: .8,
        innerStrength: 0,
        color: color,
    })];
};

export const drawPlayerVision = (g: any) => {
    var sideLength = 70;
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
    g.moveTo(-10, -7);
    g.lineTo(0 - sideLength, -sideLength * 1.5);
    g.lineTo(0 + sideLength, -sideLength * 1.5);
    g.lineTo(10, -7);
    g.lineTo(0, -20);
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

