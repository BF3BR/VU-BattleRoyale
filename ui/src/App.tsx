import React, { useState } from "react";

/* Redux */
import { connect, useDispatch } from "react-redux";
import { RootState } from "./store/RootReducer";
import {
    resetPlayer,
    updateCtrlDown,
    updatePlayerArmor,
    updatePlayerCurrentWeapon,
    updatePlayerData,
    updatePlayerFireLogic,
    updatePlayerHealth,
    updatePlayerHelmet,
    updatePlayerIsOnPlane,
    updatePlayerPosition,
    updatePlayerPrimaryAmmo,
    updatePlayerSecondaryAmmo,
    updatePlayerYaw
} from "./store/player/Actions";
import {
    addPing,
    lastPing,
    removePing,
    resetPing,
    updatePing
} from "./store/ping/Actions";
import {
    showMap,
    openMap,
    switchRotation,
    resetMap
} from "./store/map/Actions";
import {
    resetPlane,
    updatePlanePosition,
    updatePlaneYaw
} from "./store/plane/Actions";
import {
    resetCircle,
    updateInnerCircle,
    updateOuterCircle,
    updateSubphaseIndex
} from "./store/circle/Actions";
import {
    resetTeam,
    updateMuting,
    updateSpeaking,
    updateTeam
} from "./store/team/Actions";
import {
    resetSpectator,
    updateSpectatorCount,
    updateSpectatorEnabled,
    updateSpectatorTarget
} from "./store/spectator/Actions";
import {
    resetGame,
    switchDeployScreen,
    updateCommoRose,
    updateDeployScreen,
    updateDeployTeam,
    updateGameover,
    updateGameState,
    updateMinPlayers,
    updatePlayers,
    updateTime,
    updateUiState
} from "./store/game/Actions";
import { addAlert, resetAlert } from "./store/alert/Actions";
import { addKillmsg, resetKillmsg } from "./store/killmsg/Actions";
import { addInteractivemsg, resetInteractivemsg } from "./store/interactivemsg/Actions";
import {
    resetInventory,
    updateCloseLootPickup, 
    updateInventory, 
    updateOverlayLoot,
    updateProgress
} from "./store/inventory/Actions";

/* Helpers */
import Player from "./helpers/PlayerHelper";
import { FireLogicType } from "./helpers/FireLogicTypeHelper";
import { PlaySound, Sounds } from "./helpers/SoundHelper";

/* Components */
import MiniMap from "./components/map/MiniMap";
import AmmoAndHealthCounter from "./components/AmmoAndHealthCounter";
import MatchInfo from "./components/MatchInfo";
import KillAndAliveInfo from "./components/KillAndAliveInfo";
import SpectatorInfo from "./components/SpectatorInfo";
import Gameover from "./components/Gameover";
import DeployScreen from "./components/DeployScreen";
import TeamInfo from "./components/TeamInfo";
import LoadingScreen from "./components/LoadingScreen";
// import MapMarkers from "./components/MapMarkers";
import Inventory from "./components/Inventory";
import MenuScreen from "./components/MenuScreen";
import Chat from "./components/chat/Chat";
import InteractProgress from "./components/InteractProgress";
import Rose from "./components/rose/Rose";
import PingSoundManager from "./components/PingSoundManager";
import LoadingSoundManager from "./components/LoadingSoundManager";
import ArmorSoundManager from "./components/ArmorSoundManager";
import InventoryTimer from "./components/InventoryTimer";
import LootOverlay from "./components/LootOverlay";

/* Style */
import './App.scss';

interface StateFromReducer {
    gameState: string;
    uiState: "hidden" | "loading" | "game" | "menu";
    gameOverScreen: boolean;
    deployScreen: boolean;
    spectating: boolean;
    localName: string|null;
}

type Props = StateFromReducer;

const App: React.FC<Props> = ({
    gameState,
    uiState,
    gameOverScreen,
    deployScreen,
    spectating,
    localName,
}) => {
    const dispatch = useDispatch();

    /*
    * UI State
    */
    window.OnSetUIState = (p_Toggle: "hidden" | "loading" | "game" | "menu") => {
        dispatch(updateUiState(p_Toggle));
    }

    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
            if (uiState !== "game") {
                dispatch(updateUiState("game"));
            }
        }
    }


    /*
    * Gamestate
    */
    window.OnGameState = (state: string) => {
        dispatch(updateGameState(state));

        if (state === "Warmup") {
            dispatch(updateGameover(false));
            dispatch(addAlert(
                "The round is starting soon...",
                6,
                Sounds.Notification
            ));
        } else if(state === "Before Plane") {
            garbageCollection();
        } else if (state === "EndGame" && gameOverScreen === false) {
            dispatch(addAlert(
                "The round is ended, restarting soon...",
                6,
                Sounds.Notification
            ));
        }
    }

    window.OnUpdateTimer = (time: number) => {
        dispatch(updateTime(time));

        if (Math.floor(time) <= 5 && Math.floor(time) > 0 && gameState === "Warmup") {
            dispatch(addAlert(
                "The round is starting in: " + Math.floor(time),
                0.85,
                Sounds.CountDown
            ));
        }
    }

    window.OnGameOverScreen = (data: any) => {
        if (data === null) {
            return;
        }

        dispatch(updateGameover(true, data.isWin, 1, data.team));
    }

    window.OnUpdatePlacement = (placement: number | null) => {
        if (placement !== null) {
            dispatch(updateGameover(undefined, undefined, placement, undefined));
        } else {
            dispatch(updateGameover(undefined, undefined, 99, undefined));
        }
    }

    /*
    * Player
    */
    window.OnPlayersInfo = (data: any) => {
        if (data === null) {
            return;
        }

        let values = Object.values(data);
        dispatch(updatePlayers(
            data !== null ? values.filter((player: any) => player.state === 1).length : 0,
            data !== null ? values.filter((player: any) => player.state === 3).length : 0,
            data !== null ? values.length : 0
        ));
    }

    window.OnMinPlayersToStart = (minPlayersToStart: number) => {
        dispatch(updateMinPlayers(minPlayersToStart));
    }

    window.OnLocalPlayerInfo = (data: any) => {
        if (data === null) {
            return;
        }
        
        dispatch(updatePlayerData(data));
    }

    window.OnPlayerHealth = (data: number) => {
        dispatch(updatePlayerHealth(Math.ceil(data)));
    }

    window.OnPlayerArmor = (data: number) => {
        dispatch(updatePlayerArmor(Math.ceil(data)));
    }

    window.OnPlayerHelmet = (data: number) => {
        dispatch(updatePlayerHelmet(Math.ceil(data)));
    }

    window.OnPlayerPrimaryAmmo = (data: number) => {
        dispatch(updatePlayerPrimaryAmmo(data));
    }

    window.OnPlayerSecondaryAmmo = (data: number) => {
        dispatch(updatePlayerSecondaryAmmo(data));
    }

    window.OnPlayerFireLogic = (data: number) => {
        dispatch(updatePlayerFireLogic(FireLogicType[data] ?? "SINGLE"));
    }

    window.OnPlayerCurrentWeapon = (weaponName: string) => {
        dispatch(updatePlayerCurrentWeapon(weaponName));
    }

    const setInteractiveMessageAndKey = (msg: string | null, key: string | null) => {
        dispatch(addInteractivemsg(msg, key));
    }

    window.OnInteractiveMessageAndKey = (data: any) => {
        if (data !== undefined && data !== null) {
            dispatch(addInteractivemsg(data.msg, data.key));
        }
    }


    /*
    * Spectator
    */
    window.SpectatorEnabled = function (p_Enabled: boolean) {
        dispatch(updateSpectatorEnabled(p_Enabled));
    }

    window.SpectatorTarget = function (p_TargetName: string) {
        dispatch(updateSpectatorTarget(p_TargetName));
    }

    window.UpdateSpectatorCount = function (p_Count: string|null) {
        if (p_Count === null) {
            dispatch(updateSpectatorCount(null));
        } else {
            dispatch(updateSpectatorCount(parseInt(p_Count)));
        }
    }


    /*
    * Plane
    */
    window.OnPlayerIsOnPlane = (isOnPlane: boolean) => {
        dispatch(updatePlayerIsOnPlane(isOnPlane));

        if (isOnPlane) {
            setInteractiveMessageAndKey('Jump out of the plane', 'E');
        } else {
            setInteractiveMessageAndKey(null, null);
        }
    }


    /*
    * Map
    */
    window.OnPlayerPos = (p_DataJson: any) => {
        if (p_DataJson !== undefined && p_DataJson !== null) {
            dispatch(updatePlayerPosition({
                x: p_DataJson.x,
                y: p_DataJson.y,
                z: p_DataJson.z,
            }));
        }
    }

    window.OnPlayerYaw = (p_Yaw: number) => {
        dispatch(updatePlayerYaw(p_Yaw));
    }

    window.OnPlanePos = (p_DataJson: any) => {
        if (p_DataJson !== null && p_DataJson.x !== undefined && p_DataJson.y !== undefined && p_DataJson.z !== undefined) {
            dispatch(updatePlanePosition({
                x: p_DataJson.x,
                y: p_DataJson.y,
                z: p_DataJson.z,
            }));
        } else {
            dispatch(updatePlanePosition(null));
        }
    }

    window.OnPlaneYaw = (p_Yaw: number | null) => {
        if (p_Yaw !== undefined) {
            dispatch(updatePlaneYaw(p_Yaw));
        } else {
            dispatch(updatePlaneYaw(null));
        }
    }

    window.OnOpenCloseMap = (open: boolean) => {
        PlaySound(Sounds.Navigate);
        dispatch(openMap(open));
    }

    window.OnMapShow = (show: boolean) => {
        dispatch(showMap(show));
    }

    window.OnMapSwitchRotation = () => {
        dispatch(switchRotation());
    }


    window.OnUpdateCircles = (data: any) => {
        if (data === null) {
            return;
        }

        if (data.InnerCircle) {
            dispatch(updateInnerCircle({
                center: {
                    x: data.InnerCircle.Center.x,
                    y: data.InnerCircle.Center.y,
                    z: data.InnerCircle.Center.z,
                },
                radius: data.InnerCircle.Radius,
            }));
        }

        if (data.OuterCircle) {
            dispatch(updateOuterCircle({
                center: {
                    x: data.OuterCircle.Center.x,
                    y: data.OuterCircle.Center.y,
                    z: data.OuterCircle.Center.z,
                },
                radius: data.OuterCircle.Radius,
            }));
        }

        if (data.SubphaseIndex) {
            dispatch(updateSubphaseIndex(data.SubphaseIndex));

            if (data.SubphaseIndex === 3) {
                dispatch(addAlert(
                    "Heads up, the Circle is moving",
                    6,
                    Sounds.Alert
                ));
            }
        }
    }


    /*
    * Deploy screen
    */
    window.ToggleDeployMenu = (p_Toggle?: boolean) => {
        if (p_Toggle !== undefined) {
            dispatch(updateDeployScreen(p_Toggle));
        } else {
            dispatch(switchDeployScreen());
        }
    }

    window.OnUpdateTeamId = (p_Id: string) => {
        dispatch(updateDeployTeam(
            p_Id,
            undefined,
            undefined,
            undefined
        ));
    }

    window.OnUpdateTeamSize = (p_Size: number) => {
        dispatch(updateDeployTeam(
            undefined,
            p_Size,
            undefined,
            undefined
        ));
    }

    window.OnUpdateTeamLocked = (p_Locked: boolean) => {
        dispatch(updateDeployTeam(
            undefined,
            undefined,
            p_Locked,
            undefined
        ));
    }

    window.OnTeamJoinError = (p_Error: number) => {
        dispatch(updateDeployTeam(
            undefined,
            undefined,
            undefined,
            p_Error
        ));
    }

    const [downedTeammates, setDownedTeammates] = useState<string[]>([]);
    window.OnUpdateTeamPlayers = (p_Team: any) => {
        if (p_Team === null) {
            return;
        }

        let tempTeam: Player[] = [];
        let tempDowned: string[] = [];
        if (p_Team !== undefined && p_Team.length > 0) {
            p_Team.forEach((teamPlayer: any) => {
                tempTeam.push({
                    name: teamPlayer.Name,
                    state: teamPlayer.State,
                    kill: teamPlayer.Kill ?? 0,
                    isTeamLeader: teamPlayer.IsTeamLeader,
                    color: teamPlayer.Color,
                    position: {
                        x: teamPlayer.Position?.x ?? null,
                        y: teamPlayer.Position?.y ?? null,
                        z: teamPlayer.Position?.z ?? null,
                    },
                    yaw: teamPlayer.Yaw,
                    health: teamPlayer.Health ? teamPlayer.Health - 100 : null,
                    armor: teamPlayer.Armor ?? null,
                    posInSquad: teamPlayer.PosInSquad ?? 1,
                });

                if (teamPlayer.State === 2 && teamPlayer.Name !== localName) {
                    if (!downedTeammates.includes(teamPlayer.Name)) {
                        dispatch(addAlert(
                            "Your teammate " + teamPlayer.Name + " was knocked out",
                            5,
                            Sounds.Alert
                        ));
                    }
                    tempDowned.push(teamPlayer.Name);
                }
            });
        }
        dispatch(updateTeam(tempTeam));
        setDownedTeammates(tempDowned);
    }

    const CreateRandomTeam = () => {
        let tempTeam: Player[] = [];
        tempTeam.push({
            name: "Test 1",
            state: 1,
            kill: 0,
            isTeamLeader: Math.random() < 0.5,
            color: "rgba(255, 187, 86, 0.3)",
            position: {
                x: 522.175720,
                y: 158.705505,
                z: -822.253479,
            },
            yaw: 60,
            health: Math.random() * 100,
            posInSquad: 4,
            isSpeaking: Math.floor(Math.random() * 3),
            isMuted: Math.random() < 0.5,
        });
        tempTeam.push({
            name: "Test 2",
            state: 1,
            kill: 0,
            isTeamLeader: Math.random() < 0.5,
            color: "rgba(158, 197, 85, 0.3)",
            position: {
                x: 521.175720,
                y: 155.705505,
                z: -921.253479,
            },
            yaw: 110,
            health: Math.random() * 100,
            posInSquad: 3,
            isSpeaking: Math.floor(Math.random() * 3),
            isMuted: Math.random() < 0.5,
        });
        tempTeam.push({
            name: "Test",
            state: 2,
            kill: 0,
            isTeamLeader: Math.random() < 0.5,
            color: "rgba(0, 205, 243, 0.3)",
            position: {
                x: 585.175720,
                y: 159.705505,
                z: -920.253479,
            },
            yaw: 30,
            health: Math.random() * 100,
            posInSquad: 1,
            isSpeaking: Math.floor(Math.random() * 3),
            isMuted: Math.random() < 0.5,
        });
        tempTeam.push({
            name: "Test 3",
            state: 2,
            kill: 0,
            isTeamLeader: Math.random() < 0.5,
            color: "rgba(255, 159, 128, 0.3)",
            position: {
                x: 422.175720,
                y: 155.705505,
                z: -922.253479,
            },
            yaw: 10,
            health: Math.random() * 100,
            posInSquad: 2,
            isSpeaking: Math.floor(Math.random() * 3),
            isMuted: Math.random() < 0.5,
        });
        dispatch(updateTeam(tempTeam));
    }

    const SetKilledMessage = (killed: boolean, enemyName: string, kills: number) => {
        dispatch(addKillmsg(
            killed,
            kills,
            enemyName
        ));
    }

    window.OnNotifyInflictorAboutKillOrKnock = (data: any) => {
        if (data !== undefined && data !== null) {
            SetKilledMessage(data.isKill, data.name, data.kills);
        }
    }

    window.OnCreateMarker = (
        p_Key: string,
        p_Color: string,
        p_PositionX: number,
        p_PositionZ: number,
        p_WorldToScreenX: number,
        p_WorldToScreenY: number,
        p_Type?: number
    ) => {
        dispatch(removePing(p_Key));
        dispatch(lastPing(p_Key));
        dispatch(addPing({
            id: p_Key,
            color: p_Color,
            position: {
                x: p_PositionX,
                y: 0,
                z: p_PositionZ,
            },
            worldPos: {
                x: p_WorldToScreenX,
                y: p_WorldToScreenY,
                z: 0,
            },
            type: p_Type??null,
        }));
    }

    window.OnRemoveMarker = (p_Key: string) => {
        dispatch(removePing(p_Key));
    }

    window.OnUpdateMarker = (
        p_Key: string,
        p_WorldToScreenX: number,
        p_WorldToScreenY: number
    ) => {
        dispatch(updatePing(
            p_Key,
            p_WorldToScreenX,
            p_WorldToScreenY
        ));
    }

    const [interactTimeout, setInteractTimeout] = useState<number|null>(null);

    window.OnInteractStart = (p_Time: number) => {
        setInteractTimeout(p_Time);
    }

    window.OnInteractEnd = () => {
        setInteractTimeout(null);
    }

    window.OnShowCommoRose = () => {
        dispatch(updateCommoRose(true));
    }

    window.OnHideCommoRose = () => {
        dispatch(updateCommoRose(false));
    }

    const [isInventoryOpen, setIsInventoryOpen] = useState<boolean>(false);
    window.OnInventoryOpen = (p_Open: boolean) => {
        if (isInventoryOpen !== p_Open) {
            PlaySound(Sounds.Navigate);
            setIsInventoryOpen(p_Open);
        }
    }

    window.SyncInventory = (p_DataJson: any) => {
        dispatch(updateInventory(p_DataJson));
    }

    window.SyncOverlayLoot = (p_DataJson: any) => {
        dispatch(updateOverlayLoot(p_DataJson));
    }

    window.SyncCloseLootPickupData = (p_DataJson: any) => {
        if (p_DataJson === null || p_DataJson.length === undefined) {
            dispatch(updateCloseLootPickup([]));
            return;
        }
        
        let tempData: any = [];
        p_DataJson.forEach((loot: any, key: number) => {
            if (loot.Items.length > 0) {
                loot.Items.forEach((item: any, key: number) => {
                    item.lootId = loot.Id;
                    tempData.push(item);
                });
            }
        });

        dispatch(updateCloseLootPickup(tempData));
    }

    window.OnLeftCtrl = (p_Down: boolean) => {
        dispatch(updateCtrlDown(p_Down));
    }

    window.TestInventoryTimer = () => {
        dispatch(updateProgress({ Name: "Test" }, 50));
    }

    window.ItemCancelAction = () => {
        dispatch(updateProgress(null, null));
        dispatch(addAlert(
            "Item canceled",
            1.5,
            Sounds.Error
        ));
    }

    window.ResetAllValues = () => {
        console.info("RESETTING ALL VALUES!!");
        dispatch(resetAlert());
        dispatch(resetCircle());
        // dispatch(resetGame());
        dispatch(resetInteractivemsg());
        dispatch(resetInventory());
        dispatch(resetInventory());
        dispatch(resetKillmsg());
        dispatch(resetMap());
        dispatch(resetPing());
        dispatch(resetPlane());
        // dispatch(resetPlayer());
        dispatch(resetSpectator());
        // dispatch(resetTeam());
        garbageCollection();
    }

    window.OnAirdropDropped = () => {
        dispatch(addAlert(
            "Heads up, care package dropped from the plane!",
            5,
            Sounds.Airdrop
        ));
    }

    const garbageCollection = () => {
        if (window.gc) {
            window.gc();
        }
    }

    window.VoipEmitterEmitting = (playerName: string, isSpeaking: boolean, isParty: boolean) => {
        dispatch(updateSpeaking(playerName, isSpeaking, isParty));
    }

    window.VoipPlayerMuted = (playerName: string, isMuted: boolean) => {
        dispatch(updateMuting(playerName, isMuted));
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

                    #debugChat,
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
            
            {uiState === "menu" ?
                <MenuScreen />
            :
                <>
                    <div id="debug">
                        <button onClick={() => window.OnMapShow(true)}>Show Map</button>
                        <button onClick={() => window.OnOpenCloseMap(true)}>Open Map</button>
                        <button onClick={() => window.OnPlayerPos({ x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000) })}>Set Random Player Pos</button>
                        <button onClick={() => window.OnPlayerYaw(Math.random() * 100)}>Set Random Player Yaw</button>
                        <button onClick={() => window.OnPlanePos({ x: 667.28 - (Math.random() * 1000), y: 0, z: -290.44 - (Math.random() * 1000) })}>Set Random Plane Pos</button>
                        <button onClick={() => window.OnPlaneYaw(Math.random() * 100)}>Set Random Plane Yaw</button>
                        <button onClick={() => window.OnUpdateTimer(3)}>Random Timer</button>
                        <button onClick={() => dispatch(addAlert(
                            "Test alert",
                            5,
                            Sounds.Alert
                        ))}>Set alert</button>
                        <button onClick={() => {
                            dispatch(updateSpectatorEnabled(true));
                            dispatch(updateSpectatorTarget("Test"));
                        }}>
                            Set Spectator
                        </button>
                        <button onClick={() => dispatch(updateGameover(true, true, 44, [
                            {
                                Name: "KVN",
                            },
                            {
                                Name: "Bree",
                            },
                            {
                                Name: "Breaknix",
                            },
                            {
                                Name: "Kiwidog",
                            }
                        ]))}>Set Gameover Screen</button>
                        <button onClick={() =>{
                            window.OnLocalPlayerInfo({
                                name: 'KVN',
                                kill: 15,
                                state: 1,
                                isTeamLeader: true,
                                color: "rgba(255, 0, 0, 0.3)",
                            });
                            window.OnPlayerHealth(Math.random() * 100);
                            window.OnPlayerArmor(Math.random() * 100);
                            window.OnPlayerHelmet(Math.random() * 100);
                        }}>SetDummyLocalPlayer</button>
                        <button onClick={() => {
                            dispatch(updateInnerCircle({
                                center: {
                                    x: 148,
                                    y: 555,
                                    z: -864,
                                },
                                radius: 150,
                            }));
                            dispatch(updateOuterCircle({
                                center: {
                                    x: 148,
                                    y: 555,
                                    z: -864,
                                },
                                radius: 250,
                            }));
                        }}>setRandomCircle</button>
                        <button onClick={() => SetKilledMessage(true, 'TestUser', 3)}>SetKillMsg</button>
                        <button onClick={() => dispatch(switchDeployScreen())}>setDeployScreen</button>
                        <button onClick={CreateRandomTeam}>CreateRandomTeam</button>
                        <button onClick={() => window.OnPlayerIsOnPlane(true)}>OnPlayerIsOnPlane true</button>
                        <button onClick={() => window.OnPlayerIsOnPlane(false)}>OnPlayerIsOnPlane false</button>
                        <button onClick={() => window.OnCreateMarker(
                            "test",
                            "rgb(0,0,0)",
                            50,
                            50,
                            Math.random() * window.innerWidth,
                            Math.random() * window.innerHeight
                        )}>OnCreateMarker</button>
                    </div>

                    <div id="VUBattleRoyale">
                        <MatchInfo />
                        <TeamInfo />

                        {deployScreen ?
                            <DeployScreen />
                        :
                            <>
                                <KillAndAliveInfo />
                                <SpectatorInfo />
                                <AmmoAndHealthCounter isInventoryOpen={isInventoryOpen}  />
                                <Gameover />
                                <MiniMap />
                                {!spectating &&
                                    <>
                                        <InteractProgress 
                                            time={interactTimeout}
                                            onComplete={() => setInteractTimeout(null)}
                                        />
                                        <Rose />
                                        <Inventory isOpen={isInventoryOpen} />
                                        {isInventoryOpen === false &&
                                            <LootOverlay />
                                        }
                                    </>
                                }
                            </>
                        }
                    </div>
                </>
            }
            <LoadingSoundManager uiState={uiState} />
            <PingSoundManager />
            <ArmorSoundManager />
            <InventoryTimer />
            <Chat />
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // GameReducer
        gameState: state.GameReducer.gameState,
        uiState: state.GameReducer.uiState,
        gameOverScreen: state.GameReducer.gameOver.enabled,
        deployScreen: state.GameReducer.deployScreen.enabled,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
        // PlayerReducer
        localName: state.PlayerReducer.player.name,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(App);

declare global {
    interface Window {
        OnPlayerPos: (p_DataJson: any) => void;
        OnPlayerYaw: (p_YawRad: number) => void;
        OnPlanePos: (p_DataJson: any) => void;
        OnPlaneYaw: (p_Yaw: number | null) => void;
        OnOpenCloseMap: (open: boolean) => void;
        OnMapShow: (show: boolean) => void;
        OnMapSwitchRotation: () => void;
        OnUpdateCircles: (data: any) => void;
        OnGameState: (state: string) => void;
        OnUpdateTimer: (time: number) => void;
        OnPlayersInfo: (data: any) => void;
        OnLocalPlayerInfo: (data: any) => void;
        OnMinPlayersToStart: (minPlayersToStart: number) => void;
        OnPlayerHealth: (data: number) => void;
        OnPlayerArmor: (data: number) => void;
        OnPlayerHelmet: (data: number) => void;
        OnPlayerPrimaryAmmo: (data: number) => void;
        OnPlayerSecondaryAmmo: (data: number) => void;
        OnPlayerFireLogic: (data: number) => void;
        OnPlayerCurrentWeapon: (weaponName: string) => void;
        OnPlayerIsOnPlane: (isOnPlane: boolean) => void;
        OnGameOverScreen: (data: any) => void;
        OnUpdatePlacement: (placemen: number | null) => void;
        SpectatorTarget: (p_TargetName: string) => void;
        SpectatorEnabled: (p_Enabled: boolean) => void;
        UpdateSpectatorCount: (p_Count: string | null) => void;
        OnUpdateTeamId: (p_Id: string) => void;
        OnUpdateTeamSize: (p_Size: number) => void;
        OnUpdateTeamLocked: (p_Locked: boolean) => void;
        OnUpdateTeamPlayers: (p_Team: any) => void;
        OnTeamJoinError: (p_Error: number) => void;
        ToggleDeployMenu: (p_Toggle?: boolean) => void;
        OnNotifyInflictorAboutKillOrKnock: (data: any) => void;
        OnInteractiveMessageAndKey: (data: any) => void;
        OnSetUIState: (p_Toggle: "hidden" | "loading" | "game" | "menu") => void;
        OnCreateMarker: (p_Key: string, p_Color: string, p_PositionX: number, p_PositionZ: number, p_WorldToScreenX: number, p_WorldToScreenY: number) => void;
        OnRemoveMarker: (p_Key: string) => void;
        OnUpdateMarker: (p_Key: string, p_WorldToScreenX: number, p_WorldToScreenY: number) => void;
        OnInteractStart: (p_Time: number) => void;
        OnInteractEnd: () => void;
        OnShowCommoRose: () => void;
        OnHideCommoRose: () => void;
        OnInventoryOpen: (p_Open: boolean) => void;
        SyncInventory: (p_DataJson: any) => void;
        SyncOverlayLoot: (p_DataJson: any) => void;
        SyncCloseLootPickupData: (p_DataJson: any) => void;
        OnLeftCtrl: (p_Down: boolean) => void;
        TestInventoryTimer: (slot: any, time: number) => void;
        ItemCancelAction: () => void;
        ResetAllValues: () => void;
        OnAirdropDropped: () => void;
        gc: () => void;
        VoipEmitterEmitting: (playerName: string, isSpeaking: boolean, isParty: boolean) => void;
        VoipPlayerMuted: (playerName: string, isMuted: boolean) => void;
    }
}
