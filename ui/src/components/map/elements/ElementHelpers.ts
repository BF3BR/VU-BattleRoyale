import React from "react";
import * as PIXI from 'pixi.js';
import '@pixi/graphics-extras';
import { GlowFilter } from '@pixi/filter-glow';

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

