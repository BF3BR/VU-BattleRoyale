import React, { useCallback } from "react";
import { Graphics } from "@inlet/react-pixi";

interface GridProps {
    width: number;
    height: number;
}

const GridElement = ({ width, height }: GridProps) => {
    const draw = useCallback((g) => {
        g.clear();
        g.lineStyle({
            width: 3, 
            color: 0xffffff, 
            alpha: 0.015,
        });
        for (var x = 0; x <= width; x += 128) {
            for (var y = 0; y <= height; y += 128) {
                g.moveTo(x, 0);
                g.lineTo(x, height);
                g.moveTo(0, y);
                g.lineTo(width, y);
            }
        }
    }, []);

    return <Graphics
        draw={draw}
        x={0}
        y={0}
    />;
};

export default GridElement;
