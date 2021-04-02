import React, { useRef, useEffect } from 'react'
import Circle from '../../helpers/CircleHelper';
import Ping from '../../helpers/PingHelper';
import Player from '../../helpers/PlayerHelper';

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
let camHeight: number = 600;

const gridGaps = 256;

const MapCanvas = (props: any) => {
    const propsRef = useRef(null);
    const requestIdRef = useRef(null);

    /* Canvases */
    const canvasMainRef = useRef(null);

    const canvasLocalPlayerRef = useRef(null);
    const layerLocalPlayerRef = useRef(null); 

    const canvasGridRef = useRef(null);
    const layerGridRef = useRef(null);

    const canvasCirclesRef = useRef(null);
    const layerCirclesRef = useRef(null);

    const layerPingsRef = useRef(null);
    const layerTeammatesRef = useRef(null);
   

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

    /* --- Layer - Teammates --- */
    const drawLayerTeammates = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        if (propsRef.current !== null) {
            if (propsRef.current.team !== null && propsRef.current.team.length > 0) {
                let team = propsRef.current.team;
                if (propsRef.current.localPlayer !== null) {
                    team = team.filter((player: Player) => player.name !== propsRef.current.localPlayer.name);
                }
                team.filter((player: Player) => player.state !== 3)
                .forEach((player: Player) => {
                    drawATeammate(ctx, player);
                });
            }
        }
    }
    
    const drawATeammate = (ctx: any, player: Player) => {
        if (player === undefined) {
            return;
        }

        let playerMapX = getMapPos(player.position.x, topLeftPos.x, ctx.canvas.width);
        let playerMapZ = getMapPos(player.position.z, topLeftPos.z, ctx.canvas.height);
        let rotation = Math.PI / 180 * player.yaw;
        let sideLegnth = propsRef.current.open ? 22 : 12;
        
        ctx.save();

        ctx.shadowColor = "rgba(0, 0, 0, .6)";
        ctx.shadowBlur = 10;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;

        ctx.translate(playerMapX, playerMapZ);
        ctx.rotate(rotation);
        ctx.translate(-(playerMapX), -(playerMapZ));

        ctx.beginPath();
        ctx.moveTo(playerMapX, playerMapZ + sideLegnth / 2);
        ctx.lineTo(playerMapX - sideLegnth, playerMapZ + sideLegnth);
        ctx.lineTo(playerMapX, playerMapZ - sideLegnth);
        ctx.lineTo(playerMapX + sideLegnth, playerMapZ + sideLegnth);
        ctx.lineTo(playerMapX, playerMapZ + sideLegnth / 2);
        ctx.fillStyle = player.color;
        let colorVal = parseColor(player.color);
        ctx.strokeStyle = "rgb(" + colorVal[0] + ", " + colorVal[1] + ", " + colorVal[2] + ")";
        ctx.lineWidth = propsRef.current.open ? 5 : 3;
        ctx.stroke();
        ctx.fill();
        ctx.restore();
    }

    /* --- Layer - Local Player --- */
    const drawLayerLocalPlayer = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
        if (propsRef.current !== null) {
            if (propsRef.current.team !== null && propsRef.current.team.length > 0) {
                drawLocalPlayer(ctx);
            }
        }
    }
    
    const drawLocalPlayer = (ctx: any) => {
        var color = "rgba(255, 0, 0, 0.3)";
        if (propsRef.current.localPlayer !== undefined && propsRef.current.localPlayer !== null) {
            color = propsRef.current.localPlayer.color;
        }

        let playerMapX = getMapPos(propsRef.current.playerPos.x, topLeftPos.x, ctx.canvas.width);
        let playerMapZ = getMapPos(propsRef.current.playerPos.z, topLeftPos.z, ctx.canvas.height);
        let rotation = Math.PI / 180 * propsRef.current.playerYaw;
        let sideLegnth = propsRef.current.open ? 22 : 19;
        
        ctx.save();

        ctx.shadowColor = "rgba(0, 0, 0, 0.6)";
        ctx.shadowBlur = 10;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;

        ctx.translate(playerMapX, playerMapZ);
        ctx.rotate(rotation);
        ctx.translate(-(playerMapX), -(playerMapZ));

        ctx.beginPath();
        ctx.moveTo(playerMapX, playerMapZ + sideLegnth / 2);
        ctx.lineTo(playerMapX - sideLegnth, playerMapZ + sideLegnth);
        ctx.lineTo(playerMapX, playerMapZ - sideLegnth);
        ctx.lineTo(playerMapX + sideLegnth, playerMapZ + sideLegnth);
        ctx.lineTo(playerMapX, playerMapZ + sideLegnth / 2);
        ctx.fillStyle = color;
        let colorVal = parseColor(color);
        ctx.strokeStyle = "rgb(" + colorVal[0] + ", " + colorVal[1] + ", " + colorVal[2] + ")";
        ctx.lineWidth = propsRef.current.open ? 5 : 3;
        ctx.stroke();
        ctx.fill();
        ctx.restore();
    }


    /* --- Layer - Grid --- */
    const drawLayerGrid = (ctx: any) => {
        ctx.canvas.width = terrainWidthHeight;
        ctx.canvas.height = terrainWidthHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        for (var x = gridGaps; x < terrainWidthHeight; x += gridGaps) {
            ctx.moveTo(x, 0);
            ctx.lineTo(x, terrainWidthHeight);
        }
            
        for (var y = gridGaps; y < terrainWidthHeight; y += gridGaps) {
            ctx.moveTo(0, y);
            ctx.lineTo(terrainWidthHeight, y);
        }

        ctx.strokeStyle = "rgba(255,255,255,0.25)";
        ctx.lineWidth = 2;
        ctx.stroke();
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
            //addLayerToTheMainCanvas(ctx, pX, pZ, layerCirclesRef.current);
            //addLayerToTheMainCanvas(ctx, pX, pZ, layerPingsRef.current);
            //addLayerToTheMainCanvas(ctx, pX, pZ, layerTeammatesRef.current);
            //addLayerToTheMainCanvas(ctx, pX, pZ, layerLocalPlayerRef.current);
            //addLayerToTheMainCanvas(ctx, pX, pZ, layerGridRef.current);
        }
    }

    const drawLayer = (ctx: any, layer: any) => {
        ctx.canvas.width  = ctx.canvas.offsetWidth;
        ctx.canvas.height = ctx.canvas.offsetHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        if (propsRef.current !== null && propsRef.current.playerPos !== null) {
            var pX = getMapPos(propsRef.current.playerPos.x, topLeftPos.x, ctx.canvas.width);
            var pZ = getMapPos(propsRef.current.playerPos.z, topLeftPos.z, ctx.canvas.height);
            addLayerToTheMainCanvas(ctx, pX, pZ, layer);
        }
    }

    const tick = () => {
        /* Draw the layers first */
        //let layerCircles = layerCirclesRef.current;
        //drawLayerCircles(layerCircles.getContext('2d'));

        //let layerPings = layerPingsRef.current;
        //drawLayerPings(layerPings.getContext('2d'));

        //let layerTeammates = layerTeammatesRef.current;
        //drawLayerTeammates(layerTeammates.getContext('2d'));

        /* Then draw the main canvas */
        let canvasMain = canvasMainRef.current;
        draw(canvasMain.getContext('2d'));

        /* Local Player canvas and layer */
        let layerLocalPlayer = layerLocalPlayerRef.current;
        drawLayerLocalPlayer(layerLocalPlayer.getContext('2d'));
        drawLayer(canvasLocalPlayerRef.current.getContext('2d'), layerLocalPlayer);

        /* Circles canvas and layer */
        /*let layerCircles = layerCirclesRef.current;
        drawLayerCircles(layerCircles.getContext('2d'));
        drawLayer(canvasCirclesRef.current.getContext('2d'), layerCircles);

        /* Circles canvas and layer */
        let layerCircles = layerCirclesRef.current;
        drawLayerCircles(layerCircles.getContext('2d'));
        drawLayer(canvasCirclesRef.current.getContext('2d'), layerCircles);
        

        //requestIdRef.current = requestAnimationFrame(tick);
    };

    useEffect(() => {
        propsRef.current = props;
        requestIdRef.current = requestAnimationFrame(tick);
        return () => {
            cancelAnimationFrame(requestIdRef.current);
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [props]);

    /*useEffect(() => {
        let layerGrid = layerGridRef.current;
        drawLayerGrid(layerGrid.getContext('2d'));
        drawLayer(canvasGridRef.current.getContext('2d'), layerGrid);
    }, []);*/

    window.OnMapZoomChange = () => {
        switch (camHeight) {
            case 600:
                camHeight = 900;
                break;
            case 900:
                camHeight = 1100;
                break;
            case 1100:
            default:
                camHeight = 600;
                break;
        }
    }

    return (
        <>
            <canvas id="backgroundCanvas" ref={canvasMainRef} />

            <canvas id="localPlayerCanvas" ref={canvasLocalPlayerRef} />
            <canvas id="localPlayerLayer" className="hidden" ref={layerLocalPlayerRef} />

            <canvas id="circlesCanvas" ref={canvasCirclesRef} />
            <canvas id="layerCircles" className="hidden" ref={layerCirclesRef} />

            {/*<canvas id="gridCanvas" ref={canvasGridRef} />
            <canvas id="gridLayer" className="hidden" ref={layerGridRef} />*/}
            
            <canvas id="canvasPingsRef" className="hidden" ref={layerPingsRef} />
            
            <canvas id="canvasTeammates" className="hidden" ref={layerTeammatesRef} />
            
        </>
    );
}

export const MemoizedMapCanvas = React.memo(MapCanvas);
export default MemoizedMapCanvas;

declare global {
    interface Window {
        OnMapZoomChange: () => void;
    }
}
