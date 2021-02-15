import React, { useRef, useEffect } from 'react'
import Circle from '../helpers/Circle';

const arrowImage = new Image();
arrowImage.src = 'img/compass.svg';

const airplaneImage = new Image();
airplaneImage.src = 'img/airplane.svg';

// TODO: Get levelname from server
const mapImage = new Image();
mapImage.src = 'img/XP5_003.jpg';


// TODO: Load in top left pos using levelname
const topLeftPos = {
    x: 667.28,
    z: -290.44,
};

const terrainWidthHeight = 2048;

// TODO: Create multiple camHeights
const camHeight = 600;

const MapCanvas = (props: any) => {
    const propsRef = useRef(null);
    const requestIdRef = useRef(null);

    /*const [playerLocalPos, setPlayerLocalPos] = useState<Vec3|null>(null);
    const [playerLocalYaw, setPlayerLocalYaw] = useState<number|null>(null);

    const playerLocalPosRef = useRef(playerLocalPos);
    const playerLocalYawRef = useRef(playerLocalYaw);*/

    const canvasMinimapRef = useRef(null);
    const canvasCirclesRef = useRef(null);

    const getMapPos = (pos: number, topLeftPos: number, canvasSize: number)  => {
        if (propsRef.current.open) {
            return (topLeftPos - pos) * (canvasSize / 1250);
        } else {
            return (topLeftPos - pos) * (terrainWidthHeight / 1250);
        }
    }

    const drawPlayer = (ctx: any, playerMapX: number, playerMapZ: number) => {
        drawArrow(ctx, playerMapX, playerMapZ);
    }

    const drawArrow = (ctx: any, playerMapX: number, playerMapZ: number) => {
        var image = arrowImage;

        if (propsRef.current.playerIsInPlane) {
            image = airplaneImage;
        }

        var arrowWidth = image.width * (ctx.canvas.width / 550);
        var arrowHeight = image.height * (ctx.canvas.width / 550);

        if (propsRef.current.playerIsInPlane) {
            arrowWidth = arrowWidth / 4;
            arrowHeight = arrowHeight / 4;
        }

        ctx.save();

        ctx.shadowColor = "rgba(0,0,0,0.7)";
        ctx.shadowBlur = 12;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;

        if (propsRef.current.open) {
            arrowWidth = arrowWidth / 4;
            arrowHeight = arrowHeight / 4;
            ctx.translate(playerMapX, playerMapZ);
            ctx.rotate(Math.PI / 180 * propsRef.current.playerYaw);
            ctx.translate(-(playerMapX), -(playerMapZ));
            ctx.drawImage(
                image, 
                playerMapX - (arrowWidth / 2), 
                playerMapZ - (arrowHeight / 2), 
                arrowWidth, 
                arrowHeight
            );
        } else {
            ctx.drawImage(
                image, 
                (ctx.canvas.width / 2) - arrowWidth / 2, 
                (ctx.canvas.height / 2) - arrowHeight / 2, 
                arrowWidth, 
                arrowHeight
            );
        }
        
        ctx.restore();
    }
    
    function drawMap(ctx: any, playerMapX: number, playerMapZ: number, circlesCanvas: any) {
        var buffer = ctx.canvas.width / 2;

        if (propsRef.current.open) {
            ctx.drawImage(mapImage, 0, 0, terrainWidthHeight, terrainWidthHeight, 0, 0, ctx.canvas.width, ctx.canvas.height);
            ctx.drawImage(circlesCanvas, 0, 0, terrainWidthHeight, terrainWidthHeight, 0, 0, ctx.canvas.width, ctx.canvas.height);
        } else {
            ctx.save();
            ctx.translate(ctx.canvas.width / 2, ctx.canvas.height / 2);
            ctx.rotate(Math.PI / 180 * -propsRef.current.playerYaw);
            ctx.translate(-(ctx.canvas.width / 2), -(ctx.canvas.height / 2));
            ctx.drawImage(
                mapImage, 
                playerMapX - (camHeight / 2), 
                playerMapZ  - (camHeight / 2), 
                camHeight, 
                camHeight, 
                -buffer, 
                -buffer, 
                ctx.canvas.width + (2 * buffer), 
                ctx.canvas.height + (2 * buffer)
            );
            ctx.drawImage(
                circlesCanvas, 
                playerMapX - (camHeight / 2), 
                playerMapZ  - (camHeight / 2), 
                camHeight, 
                camHeight, 
                -buffer, 
                -buffer, 
                ctx.canvas.width + (2 * buffer), 
                ctx.canvas.height + (2 * buffer)
            );
            ctx.restore();
        }
    }

    const draw = (ctx: any, circlesCanvas: any) => {
        ctx.canvas.width  = ctx.canvas.offsetWidth;
        ctx.canvas.height = ctx.canvas.offsetHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        if (propsRef.current !== null && propsRef.current.playerPos !== null) {
            var pX = getMapPos(propsRef.current.playerPos.x, topLeftPos.x, ctx.canvas.width);
            var pZ = getMapPos(propsRef.current.playerPos.z, topLeftPos.z, ctx.canvas.height);
            drawMap(ctx, pX, pZ, circlesCanvas);
            drawPlayer(ctx, pX, pZ);
        }
    }

    function drawSingleCircle(ctx: any, circle: Circle, color: string, blue?: boolean) {
        var radius = circle.radius;

        var scaledCenterX = getMapPos(circle.center.x, topLeftPos.x, ctx.canvas.width);
        var scaledCenterZ = getMapPos(circle.center.z, topLeftPos.z, ctx.canvas.height);
        
        ctx.lineWidth = ctx.canvas.width / 400;
        radius = radius * (terrainWidthHeight / 1250);

        ctx.beginPath();
        ctx.arc(scaledCenterX, scaledCenterZ, radius, 0, Math.PI * 2);
        ctx.strokeStyle = color;
        ctx.stroke();
    }
    
    const drawCircles = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        if (propsRef.current !== null) {
            if (propsRef.current.innerCircle !== null) {
                drawSingleCircle(ctx, propsRef.current.innerCircle, 'rgba(255, 255, 255, 0.8');
            }
    
            if (propsRef.current.outerCircle !== null) {
                drawSingleCircle(ctx, propsRef.current.outerCircle, 'rgba(0, 0, 255, 0.8)');
            }
        }
    }

    const tick = () => {
        let minimapCanvas = canvasMinimapRef.current;
        let minimapContext = minimapCanvas.getContext('2d');

        let circlesCanvas = canvasCirclesRef.current;
        let circlesContext = circlesCanvas.getContext('2d');

        drawCircles(circlesContext);
        draw(minimapContext, circlesCanvas);

        requestIdRef.current = requestAnimationFrame(tick);
    };

    useEffect(() => {
        requestIdRef.current = requestAnimationFrame(tick);
        return () => {
            cancelAnimationFrame(requestIdRef.current);
        };
    }, []);

    useEffect(() => {
        propsRef.current = props;
    }, [props])

    return (
        <>
            <canvas id="minimapCanvas" ref={canvasMinimapRef} />
            <canvas id="circlesCanvas" ref={canvasCirclesRef} />
        </>
    );
}

export default MapCanvas;
