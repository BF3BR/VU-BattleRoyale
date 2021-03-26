import React, { useRef, useEffect } from 'react'
import Circle from '../../helpers/Circle';
import Ping from '../../helpers/Ping';

/* Icons */
const playerIcon = new Image();
playerIcon.src = 'img/compass.svg';

const airplaneIcon = new Image();
airplaneIcon.src = 'img/airplane.svg';

// TODO: Get levelname from server
const mapImage = new Image();
mapImage.src = 'img/XP5_003.jpg';


/* Map settings */
// TODO: Load in top left pos using levelname
const topLeftPos = {
    x: 667.28,
    z: -290.44,
};

const terrainWidthHeight = 2048; // The generated image size
const terrainResolution = 1250; // Coming from the minimap generator, depends on the map

// TODO: Create multiple camHeights
const camHeight = 600;

const MapCanvas = (props: any) => {
    const propsRef = useRef(null);
    const requestIdRef = useRef(null);

    /* Canvases */
    const canvasMainRef = useRef(null); // All the things get drawn here.
    const layerPingsRef = useRef(null);
    const layerCirclesRef = useRef(null);

    const getMapPos = (pos: number, topLeftPos: number, canvasSize: number)  => {
        if (propsRef.current.open) {
            return (topLeftPos - pos) * (canvasSize / terrainResolution);
        } else {
            return (topLeftPos - pos) * (terrainWidthHeight / terrainResolution);
        }
    }

    const parseColor = (input: string) => {
        return input.split("(")[1].split(")")[0].split(",");
    }

    /* --- Layer - Circles --- */
    const drawLayerCircles = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        if (propsRef.current !== null) {
            if (propsRef.current.innerCircle !== null) {
                drawACircle(ctx, propsRef.current.innerCircle, 'rgba(255, 255, 255, 0.9)');
            }
    
            if (propsRef.current.outerCircle !== null) {
                drawACircle(ctx, propsRef.current.outerCircle, 'rgba(255, 153, 0, 0.9)');
                drawTheOutsideArea(ctx, propsRef.current.outerCircle, 'rgba(255, 153, 0, 0.3)');
            }
        }
    }

    function drawACircle(ctx: any, circle: Circle, color: string) {
        var radius = circle.radius;
        radius = radius * (terrainWidthHeight / terrainResolution);
        
        ctx.beginPath();
        ctx.arc(
            getMapPos(circle.center.x, topLeftPos.x, ctx.canvas.width), 
            getMapPos(circle.center.z, topLeftPos.z, ctx.canvas.height), 
            radius, 
            0, 
            Math.PI * 2
        );
        ctx.strokeStyle = color;
        ctx.lineWidth = 5;
        ctx.stroke();
    }

    function drawTheOutsideArea(ctx: any, circle: Circle, color: string) {
        var radius = circle.radius;
        radius = radius * (terrainWidthHeight / terrainResolution);
        
        ctx.beginPath();
        ctx.arc(
            getMapPos(circle.center.x, topLeftPos.x, ctx.canvas.width), 
            getMapPos(circle.center.z, topLeftPos.z, ctx.canvas.height), 
            radius, 
            0, 
            Math.PI * 2,
            true
        );
        ctx.rect(0, 0, terrainWidthHeight, terrainWidthHeight);
        ctx.fillStyle = color;
        ctx.fill();
    }

    /* --- Layer - Pings --- */
    const drawLayerPings = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        if (propsRef.current !== null) {
            if (propsRef.current.pingsTable !== null && propsRef.current.pingsTable.length > 0) {
                propsRef.current.pingsTable.forEach((ping: Ping) => {
                    drawAPing(ctx, ping);
                });
            }
        }
    }
    
    const drawAPing = (ctx: any, ping: Ping) => {
        if (ping === undefined) {
            return;
        }

        ctx.beginPath();
        ctx.arc(
            getMapPos(ping.position.x, topLeftPos.x, ctx.canvas.width), 
            getMapPos(ping.position.z, topLeftPos.z, ctx.canvas.height), 
            propsRef.current.open ? 12 : 8, 
            0, 
            Math.PI * 2
        );
        ctx.fillStyle = ping.color;

        let colorVal = parseColor(ping.color);
        ctx.strokeStyle = "rgb(" + colorVal[0] + ", " + colorVal[1] + ", " + colorVal[2] + ")";
        ctx.lineWidth = propsRef.current.open ? 5 : 3;
        ctx.stroke();
        ctx.fill();
    }


    /* --- Main canvas --- */
    function drawBackground(ctx: any, playerMapX: number, playerMapZ: number) {
        var buffer = ctx.canvas.width / 2;
        if (propsRef.current.open) {
            ctx.drawImage(mapImage, 0, 0, terrainWidthHeight, terrainWidthHeight, 0, 0, ctx.canvas.width, ctx.canvas.height);
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
            ctx.restore();
        }
    }

    const drawPlayer = (ctx: any, playerMapX: number, playerMapZ: number) => {
        var image = playerIcon;

        if (propsRef.current.playerIsInPlane) {
            image = airplaneIcon;
        }

        var arrowWidth = image.width * (ctx.canvas.width / 600);
        var arrowHeight = image.height * (ctx.canvas.width / 600);

        if (propsRef.current.playerIsInPlane) {
            arrowWidth = arrowWidth / 4;
            arrowHeight = arrowHeight / 4;
        }

        ctx.save();
        ctx.shadowColor = "rgba(158, 197, 85, .8)";
        ctx.shadowBlur = 10;
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

    function addLayerToTheMainCanvas(ctx: any, playerMapX: number, playerMapZ: number, layer: any) {
        var buffer = ctx.canvas.width / 2;
        if (propsRef.current.open) {
            ctx.drawImage(layer, 0, 0, terrainWidthHeight, terrainWidthHeight, 0, 0, ctx.canvas.width, ctx.canvas.height);
        } else {
            ctx.save();
            ctx.translate(ctx.canvas.width / 2, ctx.canvas.height / 2);
            ctx.rotate(Math.PI / 180 * -propsRef.current.playerYaw);
            ctx.translate(-(ctx.canvas.width / 2), -(ctx.canvas.height / 2));
            ctx.drawImage(
                layer, 
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

    const draw = (ctx: any) => {
        ctx.canvas.width  = ctx.canvas.offsetWidth;
        ctx.canvas.height = ctx.canvas.offsetHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        if (propsRef.current !== null && propsRef.current.playerPos !== null) {
            var pX = getMapPos(propsRef.current.playerPos.x, topLeftPos.x, ctx.canvas.width);
            var pZ = getMapPos(propsRef.current.playerPos.z, topLeftPos.z, ctx.canvas.height);
            drawBackground(ctx, pX, pZ);
            addLayerToTheMainCanvas(ctx, pX, pZ, layerCirclesRef.current);
            addLayerToTheMainCanvas(ctx, pX, pZ, layerPingsRef.current);
            drawPlayer(ctx, pX, pZ);
        }
    }

    const tick = () => {
        /* Draw the layers first */
        let layerCircles = layerCirclesRef.current;
        drawLayerCircles(layerCircles.getContext('2d'));

        let layerPings = layerPingsRef.current;
        drawLayerPings(layerPings.getContext('2d'));

        /* Then draw the main canvas */
        let canvasMain = canvasMainRef.current;
        draw(canvasMain.getContext('2d'));

        requestIdRef.current = requestAnimationFrame(tick);
    };

    useEffect(() => {
        requestIdRef.current = requestAnimationFrame(tick);
        return () => {
            cancelAnimationFrame(requestIdRef.current);
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    useEffect(() => {
        propsRef.current = props;
    }, [props])

    return (
        <>
            <canvas id="backgroundCanvas" ref={canvasMainRef} />
            <canvas id="canvasPingsRef" className="hidden" ref={layerPingsRef} />
            <canvas id="circlesCanvas" className="hidden" ref={layerCirclesRef} />
        </>
    );
}

export default MapCanvas;
