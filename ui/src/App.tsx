import React, { useState } from "react";

/* Helpers */
import Vec3 from "./helpers/Vec3";
import Circle from "./helpers/Circle";
import Player, { Color } from "./helpers/Player";

/* Components */
// import ParaDropDistance from "./components/ParaDropDistance";
import MiniMap from "./components/MiniMap";
import AmmoAndHealthCounter from "./components/AmmoAndHealthCounter";
import MatchInfo from "./components/MatchInfo";
import InteractMessage from "./components/InteractMessage";
import KillAndAliveInfo from "./components/KillAndAliveInfo";
import Alert from "./components/Alert";
import SpactatorInfo from "./components/SpactatorInfo";
import Gameover from "./components/Gameover";
import DeployScreen from "./components/DeployScreen";
// import Inventory from "./components/Inventory";

/* Style */
import './App.scss';
import KillMessage from "./components/KillMessage";
import { FireLogicType } from "./helpers/FireLogicType";
import { Sounds } from "./helpers/Sounds";
import TeamInfo from "./components/TeamInfo";

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
    // const [paradropPercentage, setParadropPercentage] = useState<number>(100);
    // const [paradropDistance, setParadropDistance] = useState<number>(100);


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
            color: Color.White,
            isTeamLeader: true,
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
    // const [playerInventory, setPlayerInventory] = useState<string[]>([]);

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
        console.log(data);
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
                    color: Color.White,
                    isTeamLeader: teamPlayer.IsTeamLeader,
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
    
    window.ResetVars = () => {
        // window.location.reload();
    }

    const [showUI, setShowUI] = useState<boolean>(true);
    window.OnHideWebUI = (p_Toggle: boolean) => {
        setShowUI(p_Toggle);
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

            {showUI === false &&
                <style dangerouslySetInnerHTML={{
                    __html: `
                    body {
                        opacity: 0 !important;
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
                        radius: 450,
                    });
                }}>setRandomCircle</button>
                <button onClick={() => SetKilledMessage(false, 'TestUser', 3)}>SetKillMsg</button>
                <button onClick={() => setDeployScreen(true)}>setDeployScreen</button>
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

                                {/*<Inventory
                                    mapOpen={openMap}
                                    playerInventory={playerInventory}
                                />*/}
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

        ResetVars: () => void;
        OnHideWebUI: (p_Toggle: boolean) => void;
    }
}
