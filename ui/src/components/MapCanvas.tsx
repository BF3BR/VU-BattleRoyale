import React, { useRef, useEffect, useState } from 'react'

const MapCanvas = (props: any) => {
    const [winWidth, setWinWidth] = useState<number>(0);
    const [winHeight, setWinHeight] = useState<number>(0);

    const canvasRef = useRef(null);

    let mapImage = new Image();
    mapImage.src = 'img/finalimage.jpg';

    let arrowImage = new Image();
    arrowImage.src = 'img/up-arrow.svg';

    var topLeftPos = {
        x: 654.49,
        z: -318.81,
    };

    var terrainWidthHeight = 4096;

    const GetMapPos = (pos: number, topLeftPos: number, canvasSize: number)  => {
        if (props.open) {
            return (topLeftPos - pos) * (canvasSize / 1250);
        } else {
            return (topLeftPos - pos) * (terrainWidthHeight / 1250);
        }
    }

    const drawPlayer = (ctx: any, playerMapX: number, playerMapZ: number) => {
        ctx.save();
        ctx.shadowColor = "rgba(0,0,0,1)";
        ctx.shadowBlur = 12;
        ctx.shadowOffsetX = 0;
        ctx.shadowOffsetY = 0;
        drawCircle(ctx, playerMapX, playerMapZ, ctx.canvas.width, "rgba(255,225,0,0.8)");
        ctx.restore();

        drawCircle(ctx, playerMapX, playerMapZ, ctx.canvas.width / 4, "rgba(255,255,255,1)");
        drawArrow(ctx, playerMapX, playerMapZ);
    }

    const drawCircle = (ctx: any, playerMapX: number, playerMapZ: number, size: number, color: string) => {
        ctx.beginPath();

        if (props.open) {
            ctx.arc(playerMapX, playerMapZ, size / 80, 0, Math.PI * 2);
        } else {
            ctx.arc(ctx.canvas.width / 2, ctx.canvas.height / 2, size / 20, 0, Math.PI * 2);
        }

        ctx.fillStyle = color;
        ctx.fill();
        ctx.closePath();
    }

    const drawArrow = (ctx: any, playerMapX: number, playerMapZ: number) => {
        var arrowSize = ctx.canvas.width / 60;
        ctx.save();

        if (props.open) {
            ctx.translate(playerMapX, playerMapZ);
            ctx.rotate(Math.PI / 180 * props.playerYaw);
            ctx.translate(-(playerMapX), -(playerMapZ));
            ctx.drawImage(arrowImage, playerMapX - (ctx.canvas.width / 60) + (arrowSize / 2), playerMapZ - (ctx.canvas.width / 45), arrowSize, arrowSize);
        } else {
            arrowSize = arrowSize / 1.4;
            ctx.drawImage(arrowImage, (ctx.canvas.width / 2) - arrowSize * 2.5, (ctx.canvas.height / 2) - arrowSize * 7, arrowSize * 5, arrowSize * 5);
        }
        
        ctx.restore();
    }
    
    function drawMap(ctx: any, playerMapX: number, playerMapZ: number) {
        if (props.open) {
            ctx.drawImage(mapImage, 0, 0, terrainWidthHeight, terrainWidthHeight, 0, 0, ctx.canvas.width, ctx.canvas.height);
        } else {
            var buffer = (ctx.canvas.width / 2);
            var scale = 4;

            ctx.save();
            ctx.translate(ctx.canvas.width / 2, ctx.canvas.height / 2);
            ctx.rotate(Math.PI / 180 * -props.playerYaw);
            ctx.translate(-(ctx.canvas.width / 2), -(ctx.canvas.height / 2));

            playerMapZ = playerMapZ - ctx.canvas.width * scale / 2;
            playerMapX = playerMapX - ctx.canvas.width * scale / 2;
            
            ctx.drawImage(mapImage, 
                playerMapX - buffer, 
                playerMapZ  - buffer, 
                (ctx.canvas.width * scale) + (2 * buffer), 
                (ctx.canvas.width * scale) + (2 * buffer), 
                -buffer, 
                -buffer, 
                ctx.canvas.width + (2 * buffer), 
                ctx.canvas.height + (2 * buffer)
            );
            
            ctx.restore();
        }
    }

    const draw = (ctx: any, frameCount: number) => {
        ctx.canvas.width  = ctx.canvas.offsetWidth;
        ctx.canvas.height = ctx.canvas.offsetHeight;
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

        if (props.playerPos !== null) {
            var pX = GetMapPos(props.playerPos.x, topLeftPos.x, ctx.canvas.width);
            var pZ = GetMapPos(props.playerPos.z, topLeftPos.z, ctx.canvas.height);
            drawMap(ctx, pX, pZ);
            drawPlayer(ctx, pX, pZ);
        }
    }

    window.addEventListener('resize', () => {
        setWinWidth(window.innerWidth);
        setWinHeight(window.innerHeight);
    });

    useEffect(() => {
        const canvas = canvasRef.current;
        const context = canvas.getContext('2d');
        let frameCount: number = 0;
        let animationFrameId: any = null;
        
        //Our draw came here
        const render = () => {
            frameCount++
            draw(context, frameCount)
            animationFrameId = window.requestAnimationFrame(render)
        }
        render()

        return () => {
            window.cancelAnimationFrame(animationFrameId)
        }
    }, [draw, winHeight, winWidth]);

    return <canvas id="minimapCanvas" ref={canvasRef} {...props} />
}

export default MapCanvas
