import React, { useState } from "react";

/* Helpers */
import Vec3 from "./helpers/Vec3";
import Circle from "./helpers/Circle";
import Player from "./helpers/Player";

/* Components */
import ParaDropDistance from "./components/ParaDropDistance";
import MiniMap from "./components/MiniMap";
import AmmoAndHealthCounter from "./components/AmmoAndHealthCounter";
import MatchInfo from "./components/MatchInfo";
import PlaneMessage from "./components/PlaneMessage";
import KillAndAliveInfo from "./components/KillAndAliveInfo";
import Alert from "./components/Alert";
import SpactatorInfo from "./components/SpactatorInfo";
import Gameover from "./components/Gameover";
import DeployScreen from "./components/DeployScreen";

/* Style */
import './App.scss';

const App: React.FC = () => {
    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
        }
    }

    /*
    * Paradrop
    */
    const [paradropPercentage, setParadropPercentage] = useState<number>(100);
    const [paradropDistance, setParadropDistance] = useState<number>(100);


    /*
    * Gamestate
    */
    const [gameState, setGameState] = useState<string | null>("None");
    window.OnGameState = (state: string) => {
        setGameState(state);

        if (state === "Warmup") {
            setAlertPlaySound(false);
            setAlertString("The round is starting soon");
        }
    }

    const [time, setTime] = useState<number | null>(null);
    window.OnUpdateTimer = (time: number) => {
        setTime(time);
    }


    const [gameOverScreen, setGameOverScreen] = useState<boolean>(false);
    /*window.OnGameState = (state: string) => {
        setGameState(state);

        if (state === "Warmup") {
            setAlertPlaySound(false);
            setAlertString("The round is starting soon");
        }
    }*/

    /*
    * Player
    */
    const [players, setPlayers] = useState<Player[] | null>(null);
    window.OnPlayersInfo = (data: any) => {
        setPlayers(data);
    }

    const [minPlayersToStart, setMinPlayersToStart] = useState<number | null>(null);
    window.OnMinPlayersToStart = (minPlayersToStart: number) => {
        setMinPlayersToStart(minPlayersToStart);
    }

    const [localPlayer, setLocalPlayer] = useState<Player | null>(null);
    window.OnLocalPlayerInfo = (data: any) => {
        setLocalPlayer(data);
    }

    const SetDummyLocalPlayer = () => {
        setLocalPlayer({
            id: 1,
            name: 'KVN',
            kill: 15,
            alive: true,
        });
    }

    const [alertString, setAlertString] = useState<string | null>(null);
    const [alertPlaySound, setAlertPlaySound] = useState<boolean>(false);

    const [playerHealth, setPlayerHealth] = useState<number>(0);
    const [playerPrimaryAmmo, setPlayerPrimaryAmmo] = useState<number>(0);
    const [playerSecondaryAmmo, setPlayerSecondaryAmmo] = useState<number>(0);
    const [playerCurrentWeapon, setPlayerCurrentWeapon] = useState<string>('');

    window.OnPlayerHealth = (data: number) => {
        setPlayerHealth(data);
    }

    window.OnPlayerPrimaryAmmo = (data: number) => {
        setPlayerPrimaryAmmo(data);
    }

    window.OnPlayerSecondaryAmmo = (data: number) => {
        setPlayerSecondaryAmmo(data);
    }

    window.OnPlayerCurrentWeapon = (data: string) => {
        setPlayerCurrentWeapon(data);
    }


    /*
    * Spectator
    */
    const [spectating, setSpectating] = useState<boolean>(false);

    window.SpectatorEnabled = function (p_Enabled: boolean) {
        setSpectating(p_Enabled);
    }

    const [spectatorTarget, setSpectatorTarget] = useState<string>('');

    window.SpectatorTarget = function (p_TargetName: string) {
        setSpectatorTarget(p_TargetName);
    }


    /*
    * Plane
    */
    const [playerIsInPlane, setPlayerIsInPlane] = useState<boolean>(false);

    window.OnPlayerIsInPlane = (isInPlane: boolean) => {
        setPlayerIsInPlane(isInPlane);
    }


    /*
    * Map
    */
    const [openMap, setOpenMap] = useState<boolean>(false);
    const [showMinimap, setShowMinimap] = useState<boolean>(false);

    const [playerPos, setPlayerPos] = useState<Vec3 | null>(null);
    window.OnPlayerPos = (p_DataJson: any) => {
        setPlayerPos({
            x: p_DataJson.x,
            y: p_DataJson.y,
            z: p_DataJson.z,
        });
    }

    const [playerYaw, setPlayerYaw] = useState<number | null>(null);
    window.OnPlayerYaw = (p_YawRad: number) => {
        setPlayerYaw(p_YawRad);
    }

    window.OnMapSizeChange = () => {
        setOpenMap(prevState => !prevState);
    }

    window.OnMapShow = (show: boolean) => {
        setShowMinimap(show);
    }

    const [innerCircle, setInnerCircle] = useState<Circle | null>(null);
    const [outerCircle, setOuterCircle] = useState<Circle | null>(null);
    const [subPhaseIndex, setSubPhaseIndex] = useState<number>(1);

    window.OnUpdateCircles = (data: any) => {
        if (data.InnerCircle) {
            setInnerCircle({
                center: {
                    x: data.InnerCircle.Center.x,
                    y: data.InnerCircle.Center.y,
                    z: data.InnerCircle.Center.z,
                },
                radius: data.InnerCircle.Radius,
            });
        }

        if (data.OuterCircle) {
            setOuterCircle({
                center: {
                    x: data.OuterCircle.Center.x,
                    y: data.OuterCircle.Center.y,
                    z: data.OuterCircle.Center.z,
                },
                radius: data.OuterCircle.Radius,
            });
        }

        if (data.SubphaseIndex) {
            setSubPhaseIndex(data.SubphaseIndex);

            if (data.SubphaseIndex === 3) {
                setAlertPlaySound(true);
                setAlertString("Heads up, the Circle is moving");
            }
        }
    }

    /*
    * Deploy screen
    */
   const [deployScreen, setDeployScreen] = useState<boolean>(false);

    return (
        <>
            {debugMode &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        background: #333 url('/img/demo.png') 50% 50% no-repeat;
                        background-size: cover;
                    }

                    #debug {
                        display: block !important;
                        opacity: 0.1;
                    }
                `}} />
            }

            <div id="debug">
                {/*<input
                    type="range"
                    min="0"
                    max="100"
                    value={paradropPercentage}
                    onChange={(event: any) => setParadropPercentage(event.target.value)}
                    step="1"
                />*/}
                <button onClick={() => setShowMinimap(prevState => !prevState)}>Show Map</button>
                <button onClick={() => setOpenMap(prevState => !prevState)}>Open Map</button>
                <button onClick={() => window.OnPlayerPos({ x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000) })}>Set Random Player Pos</button>
                <button onClick={() => window.OnPlayerYaw(Math.random() * 100)}>Set Random Player Yaw</button>
                <button onClick={() => window.OnUpdateTimer(Math.random() * 60)}>Random Timer</button>
                <button onClick={() => setAlertString("Heads up, the Circle is moving")}>Set alert</button>
                <button onClick={() => setAlertPlaySound(prevState => !prevState)}>Set alert sounds</button>
                <button onClick={() => setSpectating(prevState => !prevState)}>Set Spectator</button>
                <button onClick={() => setGameOverScreen(prevState => !prevState)}>Set Gameover Screen</button>
                <button onClick={() => SetDummyLocalPlayer()}>SetDummyLocalPlayer</button>
            </div>

            <div id="VUBattleRoyale">
                {deployScreen 
                ?
                    <DeployScreen />
                :
                    <>
                        <KillAndAliveInfo
                            kills={localPlayer !== null ? localPlayer.kill : 0}
                            alive={players !== null ? Object.values(players).filter(player => player.alive === true).length : 0}
                            spectating={spectating}
                        />

                        <MatchInfo
                            state={gameState}
                            time={time}
                            noMap={!showMinimap || openMap}
                            players={players}
                            minPlayersToStart={minPlayersToStart}
                            subPhaseIndex={subPhaseIndex}
                            spectating={spectating}
                        />

                        <SpactatorInfo
                            spectating={spectating}
                            spectatorTarget={spectatorTarget}
                        />

                        {gameOverScreen &&
                            <Gameover 
                                localPlayer={localPlayer}
                            />
                        }

                        {!spectating &&
                            <>
                                <AmmoAndHealthCounter
                                    playerHealth={playerHealth}
                                    playerPrimaryAmmo={playerPrimaryAmmo}
                                    playerSecondaryAmmo={playerSecondaryAmmo}
                                    playerCurrentWeapon={playerCurrentWeapon}
                                />

                                <PlaneMessage
                                    playerIsInPlane={playerIsInPlane}
                                />

                                <Alert
                                    alert={alertString}
                                    afterInterval={() => setAlertString(null)}
                                    playSound={alertPlaySound}
                                />

                                {/*<ParaDropDistance 
                                    percentage={paradropPercentage}
                                    distance={300}
                                    warnPercentage={15}
                                />*/}

                                {showMinimap &&
                                    <MiniMap
                                        open={openMap}
                                        playerPos={playerPos}
                                        playerYaw={playerYaw}
                                        innerCircle={innerCircle}
                                        outerCircle={outerCircle}
                                        playerIsInPlane={playerIsInPlane}
                                    />
                                }
                            </>
                        }
                    </>
                }
            </div>
        </>
    );
};

export default App;

declare global {
    interface Window {
        OnPlayerPos: (p_DataJson: any) => void;
        OnPlayerYaw: (p_YawRad: number) => void;
        OnMapSizeChange: () => void;
        OnMapShow: (show: boolean) => void;
        OnUpdateCircles: (data: any) => void;
        OnGameState: (state: string) => void;
        OnUpdateTimer: (time: number) => void;
        OnPlayersInfo: (data: any) => void;
        OnLocalPlayerInfo: (data: any) => void;
        OnMinPlayersToStart: (minPlayersToStart: number) => void;
        OnPlayerHealth: (data: number) => void;
        OnPlayerPrimaryAmmo: (data: number) => void;
        OnPlayerSecondaryAmmo: (data: number) => void;
        OnPlayerCurrentWeapon: (data: string) => void;
        OnPlayerIsInPlane: (isInPlane: boolean) => void;
        SpectatorTarget: (p_TargetName: string) => void;
        SpectatorEnabled: (p_Enabled: boolean) => void;
    }
}
