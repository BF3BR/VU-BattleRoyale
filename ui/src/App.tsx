import React, { useState } from "react";

/* Helpers */
import Vec3 from "./helpers/Vec3Helper";
import Circle from "./helpers/CircleHelper";
import Player from "./helpers/PlayerHelper";
import { FireLogicType } from "./helpers/FireLogicTypeHelper";
import { Sounds } from "./helpers/SoundsHelper";
import Ping from "./helpers/PingHelper";

/* Components */
import MiniMap from "./components/map/MiniMap";
import AmmoAndHealthCounter from "./components/AmmoAndHealthCounter";
import MatchInfo from "./components/MatchInfo";
import InteractMessage from "./components/InteractMessage";
import KillAndAliveInfo from "./components/KillAndAliveInfo";
import Alert from "./components/Alert";
import SpactatorInfo from "./components/SpactatorInfo";
import Gameover from "./components/Gameover";
import DeployScreen from "./components/DeployScreen";
import TeamInfo from "./components/TeamInfo";
import KillMessage from "./components/KillMessage";
import LoadingScreen from "./components/LoadingScreen";

/* Style */
import './App.scss';

const App: React.FC = () => {
    /*
    * UI State
    */
    const [uiState, setUIState] = useState<"hidden" | "loading" | "game">("loading");
    window.OnSetUIState = (p_Toggle: "hidden" | "loading" | "game") => {
        setUIState(p_Toggle);
    }

    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
            if (uiState !== "game") {
                setUIState("game");
            }
        }
    }


    /*
    * Gamestate
    */
    const [gameState, setGameState] = useState<string | null>("None");
    window.OnGameState = (state: string) => {
        setGameState(state);

        if (state === "None") {
            setGameOverScreen(false);
        } else if (state === "Warmup") {
            setGameOverScreen(false);
            setAlertPlaySound(Sounds.Notification);
            setAlertLength(6);
            setAlertString("The round is starting soon...");
        } else if (state === "EndGame" && gameOverScreen === false) {
            setAlertPlaySound(Sounds.Notification);
            setAlertLength(6);
            setAlertString("The round is ended, restarting soon...");
        }
    }

    const [time, setTime] = useState<number | null>(null);
    window.OnUpdateTimer = (time: number) => {
        setTime(time);

        if (Math.floor(time) <= 5 && Math.floor(time) > 0 && gameState === "Warmup") {
            setAlertPlaySound(Sounds.CountDown);
            setAlertLength(0.85);
            setAlertString("The round is starting in: " + Math.floor(time));
        }
    }

    const [gameOverScreen, setGameOverScreen] = useState<boolean>(false);
    const [gameOverPlace, setGameOverPlace] = useState<number>(99);
    const [gameOverIsWin, setGameOverIsWin] = useState<boolean>(false);
    
    window.OnGameOverScreen = (data: any) => {
        // setGameOverPlace(data.place);
        setGameOverIsWin(data.isWin);
        setGameOverScreen(true);
    }

    window.OnUpdatePlacement = (placement: number | null) => {
        if (placement !== null) {
            setGameOverPlace(placement);
        } else {
            setGameOverPlace(99);
        }
    }

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
            name: 'KVN',
            kill: 15,
            state: 1,
            isTeamLeader: true,
            color: "rgba(255, 0, 0, 0.3)",
        });
    }

    const [alertString, setAlertString] = useState<string | null>(null);
    const [alertPlaySound, setAlertPlaySound] = useState<Sounds>(Sounds.None);
    const [alertLength, setAlertLength] = useState<number>(4);

    const [playerHealth, setPlayerHealth] = useState<number>(0);
    const [playerArmor, setPlayerArmor] = useState<number>(0);
    const [playerPrimaryAmmo, setPlayerPrimaryAmmo] = useState<number>(0);
    const [playerSecondaryAmmo, setPlayerSecondaryAmmo] = useState<number>(0);
    const [playerFireLogic, setPlayerFireLogic] = useState<string>("AUTO");
    const [playerCurrentWeapon, setPlayerCurrentWeapon] = useState<string>('');

    window.OnPlayerHealth = (data: number) => {
        setPlayerHealth(Math.ceil(data));
    }

    window.OnPlayerArmor = (data: number) => {
        setPlayerArmor(data);
    }

    window.OnPlayerPrimaryAmmo = (data: number) => {
        setPlayerPrimaryAmmo(data);
    }

    window.OnPlayerSecondaryAmmo = (data: number) => {
        setPlayerSecondaryAmmo(data);
    }

    window.OnPlayerFireLogic = (data: number) => {
        setPlayerFireLogic(FireLogicType[data]??"AUTO");
    }

    window.OnPlayerCurrentWeapon = (data: string) => {
        setPlayerCurrentWeapon(data);
    }

    window.OnPlayerWeapons = (data: any) => {
        //console.log(data);
    }

    const [interactiveMessage, setInteractiveMessage] = useState<string|null>(null);
    const [interactiveKey, setInteractiveKey] = useState<string|null>(null);

    const setInteractiveMessageAndKey = (msg: string|null, key: string|null) => {
        setInteractiveMessage(msg);
        setInteractiveKey(key);
    }

    window.OnInteractiveMessageAndKey = (data: any) => {
        if (data !== undefined && data !== null) {
            setInteractiveMessage(data.msg);
            setInteractiveKey(data.key);
        }
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

        if (isInPlane) {
            setInteractiveMessageAndKey('Jump out of the plane', 'E');
        } else {
            setInteractiveMessageAndKey(null, null);
        }
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

    const [planePos, setPlanePos] = useState<Vec3 | null>(null);
    window.OnPlanePos = (p_DataJson: any) => {
        console.log(p_DataJson);
        if (p_DataJson !== undefined && p_DataJson.x !== undefined && p_DataJson.y !== undefined && p_DataJson.z !== undefined) {
            setPlanePos({
                x: p_DataJson.x,
                y: p_DataJson.y,
                z: p_DataJson.z,
            });
        } else {
            setPlanePos(null);
        }
    }

    const [planeYaw, setPlaneYaw] = useState<number | null>(null);
    window.OnPlaneYaw = (p_YawRad: number) => {
        setPlaneYaw(p_YawRad);
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
                setAlertPlaySound(Sounds.Alert);
                setAlertLength(6);
                setAlertString("Heads up, the Circle is moving");
            }
        }
    }


    /*
    * Deploy screen
    */
    const [deployScreen, setDeployScreen] = useState<boolean>(false);
    window.ToggleDeployMenu = (p_Toggle?: boolean) => {
        if (p_Toggle !== undefined) {
            setDeployScreen(p_Toggle);
        } else {
            setDeployScreen(prevState => !prevState);
        }
    }

    const [selectedAppearance, setSelectedAppearance] = useState<number>(0);
    const [selectedTeamType, setSelectedTeamType] = useState<number>(1);

    const [team, setTeam] = useState<Player[]>([]);
    const [downedTeammatesCount, setDownedTeammatesCount] = useState<number>(0);
    window.OnUpdateTeamPlayers = (p_Team: any) => {
        let tempDownedTeammatesCount = 0;
        let tempTeam: Player[] = [];
        if (p_Team !== undefined && p_Team.length > 0) {
            p_Team.forEach((teamPlayer: any) => {
                tempTeam.push({
                    name: teamPlayer.Name,
                    state: teamPlayer.State,
                    kill: 0,
                    isTeamLeader: teamPlayer.IsTeamLeader,
                    color: teamPlayer.Color,
                    position: {
                        x: teamPlayer.Position?.x,
                        y: teamPlayer.Position?.y,
                        z: teamPlayer.Position?.z,
                    },
                    yaw: teamPlayer.Yaw,
                });

                if (teamPlayer.State === 2) {
                    tempDownedTeammatesCount++;
                }
            });
        }
        setTeam(tempTeam);

        if (tempDownedTeammatesCount > downedTeammatesCount) {
            setAlertPlaySound(Sounds.Alert);
            setAlertLength(4);
            setAlertString("One of your teammate is downed");
        }
        setDownedTeammatesCount(tempDownedTeammatesCount);
    }

    const CreateRandomTeam = () => {
        let tempTeam: Player[] = [];
        tempTeam.push({
            name: "Test 1",
            state: 1,
            kill: 0,
            isTeamLeader: false,
            color: "rgba(255, 187, 86, 0.3)",
            position: {
                x: 522.175720,
                y: 155.705505,
                z: -822.253479,
            },
            yaw: 60,
        });
        tempTeam.push({
            name: "Test 2",
            state: 1,
            kill: 0,
            isTeamLeader: false,
            color: "rgba(158, 197, 85, 0.3)",
            position: {
                x: 522.175720,
                y: 155.705505,
                z: -922.253479,
            },
            yaw: 30,
        });
        tempTeam.push({
            name: "Test 3",
            state: 2,
            kill: 0,
            isTeamLeader: false,
            color: "rgba(255, 159, 128, 0.3)",
            position: {
                x: 522.175720,
                y: 155.705505,
                z: -922.253479,
            },
            yaw: 30,
        });
        tempTeam.push({
            name: "Test 4",
            state: 2,
            kill: 0,
            isTeamLeader: false,
            color: "rgba(148, 205, 243, 0.3)",
            position: {
                x: 522.175720,
                y: 155.705505,
                z: -922.253479,
            },
            yaw: 30,
        });
        setTeam(tempTeam);
    }

    const [teamId, setTeamId] = useState<string>('-');
    window.OnUpdateTeamId = (p_Id: string) => {
        setTeamId(p_Id);
    }

    const [teamSize, setTeamSize] = useState<number>(4);
    window.OnUpdateTeamSize = (p_Size: number) => {
        setTeamSize(p_Size);
    }

    const [teamLocked, setTeamLocked] = useState<boolean>(false);
    window.OnUpdateTeamLocked = (p_Locked: boolean) => {
        setTeamLocked(p_Locked);
    }

    const [teamJoinError, setTeamJoinError] = useState<number|null>(null);
    window.OnTeamJoinError = (p_Error: number) => {
        setTeamJoinError(p_Error);
    }

    const [killedMessageKilled, setKilledMessageKilled] = useState<boolean|null>(null);
    const [killedMessageKills, setKilledMessageKills] = useState<number|null>(null);
    const [killedMessageEnemyName, setKilledMessageEnemyName] = useState<string|null>(null);

    const SetKilledMessage = (killed: boolean, enemyName: string, kills: number) => {
        setKilledMessageKilled(killed);
        setKilledMessageEnemyName(enemyName);
        setKilledMessageKills(kills);
    }


    window.OnNotifyInflictorAboutKillOrKnock = (data: any) => {
        if (data !== undefined && data !== null) {
            SetKilledMessage(data.isKill, data.name, data.kills);
        }
    }

    const [pingsTable, setPingsTable] = useState<Array<Ping>>([]);
    window.OnCreateMarker = (p_Key: string, p_Color: string, p_PositionX: number, p_PositionZ: number) => {
        let pings = pingsTable.filter((ping: Ping, _: number) => ping.id !== p_Key);
        pings.push({
            id: p_Key,
            color: p_Color,
            position: {
                x: p_PositionX,
                y: 0,
                z: p_PositionZ,
            }
        });
        setPingsTable(pings);
    }

    window.OnRemoveMarker = (p_Key: string) => {
        let pings = pingsTable.filter((ping: Ping, _: number) => ping.id !== p_Key);
        setPingsTable(pings);
    }

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
                        display: flex !important;
                        opacity: 0.1;
                    }
                `}} />
            }

            {uiState === "hidden" &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        opacity: 0 !important;
                        pointer-events: none !important;
                    }
                `}} />
            }

            {uiState === "loading" &&
                <LoadingScreen />
            }

            <div id="debug">
                <button onClick={() => setShowMinimap(prevState => !prevState)}>Show Map</button>
                <button onClick={() => setOpenMap(prevState => !prevState)}>Open Map</button>
                <button onClick={() => window.OnPlayerPos({ x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000) })}>Set Random Player Pos</button>
                <button onClick={() => window.OnPlayerYaw(Math.random() * 100)}>Set Random Player Yaw</button>
                <button onClick={() => window.OnPlanePos({ x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000) })}>Set Random Plane Pos</button>
                <button onClick={() => window.OnPlaneYaw(Math.random() * 100)}>Set Random Plane Yaw</button>
                <button onClick={() => window.OnUpdateTimer(3)}>Random Timer</button>
                <button onClick={() => setAlertString("Heads up, the Circle is moving")}>Set alert</button>
                <button onClick={() => setSpectating(prevState => !prevState)}>Set Spectator</button>
                <button onClick={() => setGameOverScreen(prevState => !prevState)}>Set Gameover Screen</button>
                <button onClick={() => SetDummyLocalPlayer()}>SetDummyLocalPlayer</button>
                <button onClick={() => {
                    setInnerCircle({
                        center: {
                            x: 148,
                            y: 555,
                            z: -864,
                        },
                        radius: 150,
                    });
                    setOuterCircle({
                        center: {
                            x: 148,
                            y: 555,
                            z: -864,
                        },
                        radius: 250,
                    });
                }}>setRandomCircle</button>
                <button onClick={() => SetKilledMessage(false, 'TestUser', 3)}>SetKillMsg</button>
                <button onClick={() => setDeployScreen(true)}>setDeployScreen</button>
                <button onClick={CreateRandomTeam}>CreateRandomTeam</button>
                <button onClick={() => window.OnPlayerIsInPlane(true)}>OnPlayerIsInPlane true</button>
                <button onClick={() => window.OnPlayerIsInPlane(false)}>OnPlayerIsInPlane false</button>
            </div>

            <div id="VUBattleRoyale">
                <MatchInfo
                    state={gameState}
                    time={time}
                    noMap={!showMinimap || openMap}
                    players={players}
                    minPlayersToStart={minPlayersToStart}
                    subPhaseIndex={subPhaseIndex}
                    spectating={spectating}
                    deployScreen={deployScreen}
                />

                {team.length > 1 &&
                    <TeamInfo 
                        team={team}
                        deployScreen={deployScreen}
                    />
                }

                {!gameOverScreen &&
                    <Alert
                        alert={alertString}
                        afterInterval={() => setAlertString(null)}
                        playSound={alertPlaySound}
                        length={alertLength}
                    />
                }

                {deployScreen 
                ?
                    <DeployScreen
                        setDeployScreen={setDeployScreen}
                        team={team}
                        teamSize={teamSize}
                        teamOpen={!teamLocked}
                        isTeamLeader={localPlayer?.isTeamLeader??false}
                        teamCode={teamId??'-'}
                        teamJoinError={teamJoinError}
                        setTeamJoinError={setTeamJoinError}
                        selectedAppearance={selectedAppearance}
                        setSelectedAppearance={setSelectedAppearance}
                        selectedTeamType={selectedTeamType}
                        setSelectedTeamType={setSelectedTeamType}
                    />
                :
                    <>
                        <KillAndAliveInfo
                            kills={localPlayer !== null ? localPlayer.kill : 0}
                            alive={players !== null ? Object.values(players).filter(player => player.state === 1).length : 0}
                            spectating={spectating}
                        />

                        <SpactatorInfo
                            spectating={spectating}
                            spectatorTarget={spectatorTarget}
                        />

                        {(gameOverScreen && localPlayer !== null) &&
                            <Gameover 
                                localPlayer={localPlayer}
                                gameOverPlace={gameOverPlace}
                                gameOverIsWin={gameOverIsWin}
                                afterInterval={() => setGameOverScreen(false)}
                            />
                        }

                        {!spectating &&
                            <>
                                <AmmoAndHealthCounter
                                    playerHealth={playerHealth}
                                    playerArmor={playerArmor}
                                    playerPrimaryAmmo={playerPrimaryAmmo}
                                    playerSecondaryAmmo={playerSecondaryAmmo}
                                    playerFireLogic={playerFireLogic}
                                    playerCurrentWeapon={playerCurrentWeapon}
                                    playerIsInPlane={playerIsInPlane}
                                />

                                <InteractMessage
                                    message={interactiveMessage}
                                    keyboard={interactiveKey}
                                />

                                <KillMessage
                                    killed={killedMessageKilled}
                                    enemyName={killedMessageEnemyName}
                                    kills={killedMessageKills}
                                    resetMessage={() => SetKilledMessage(null, null, null)}
                                />

                                <MiniMap
                                    open={openMap}
                                    playerPos={playerPos}
                                    playerYaw={playerYaw}
                                    planePos={planePos}
                                    planeYaw={planeYaw}
                                    innerCircle={innerCircle}
                                    outerCircle={outerCircle}
                                    playerIsInPlane={playerIsInPlane}
                                    pingsTable={pingsTable}
                                    team={team}
                                    localPlayer={localPlayer}
                                    showMinimap={showMinimap}
                                />
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
        OnPlanePos: (p_DataJson: any) => void;
        OnPlaneYaw: (p_YawRad: number) => void;

        OnMapSizeChange: () => void;
        OnMapShow: (show: boolean) => void;
        OnUpdateCircles: (data: any) => void;
        OnGameState: (state: string) => void;
        OnUpdateTimer: (time: number) => void;

        OnPlayersInfo: (data: any) => void;
        OnLocalPlayerInfo: (data: any) => void;
        OnMinPlayersToStart: (minPlayersToStart: number) => void;

        OnPlayerHealth: (data: number) => void;
        OnPlayerArmor: (data: number) => void;
        OnPlayerPrimaryAmmo: (data: number) => void;
        OnPlayerSecondaryAmmo: (data: number) => void;
        OnPlayerFireLogic: (data: number) => void;
        OnPlayerCurrentWeapon: (data: string) => void;
        OnPlayerWeapons: (data: any) => void;
        OnPlayerIsInPlane: (isInPlane: boolean) => void;
        OnGameOverScreen: (data: any) => void; 
        OnUpdatePlacement: (placemen: number|null) => void;

        SpectatorTarget: (p_TargetName: string) => void;
        SpectatorEnabled: (p_Enabled: boolean) => void;

        OnUpdateTeamId: (p_Id: string) => void;
        OnUpdateTeamSize: (p_Size: number) => void;
        OnUpdateTeamLocked: (p_Locked: boolean) => void;
        OnUpdateTeamPlayers: (p_Team: any) => void;
        OnTeamJoinError: (p_Error: number) => void;

        ToggleDeployMenu: (p_Toggle?: boolean) => void;

        OnNotifyInflictorAboutKillOrKnock: (data: any) => void;
        OnInteractiveMessageAndKey: (data: any) => void;

        OnSetUIState: (p_Toggle: "hidden" | "loading" | "game") => void;

        OnCreateMarker: (p_Key: string, p_Color: string, p_PositionX: number, p_PositionZ: number) => void;
        OnRemoveMarker: (p_Key: string) => void;
    }
}
