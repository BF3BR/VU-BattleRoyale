import React, { useState } from "react";

/* Redux */
import { connect, useDispatch } from "react-redux";
import { RootState } from "./store/RootReducer";
import {
    updatePlayerArmor,
    updatePlayerCurrentWeapon,
    updatePlayerData,
    updatePlayerFireLogic,
    updatePlayerHealth,
    updatePlayerIsOnPlane,
    updatePlayerPosition,
    updatePlayerPrimaryAmmo,
    updatePlayerSecondaryAmmo,
    updatePlayerYaw
} from "./store/player/Actions";
import {
    addPing,
    removePing
} from "./store/ping/Actions";
import {
    showMap,
    openMap
} from "./store/map/Actions";
import {
    updatePlanePosition,
    updatePlaneYaw
} from "./store/plane/Actions";
import {
    updateInnerCircle,
    updateOuterCircle,
    updateSubphaseIndex
} from "./store/circle/Actions";
import {
    updateTeam
} from "./store/team/Actions";
import {
    updateSpectatorEnabled,
    updateSpectatorTarget
} from "./store/spectator/Actions";
import {
    switchDeployScreen,
    updateDeployScreen,
    updateDeployTeam,
    updateGameover,
    updateGameState,
    updateMinPlayers,
    updatePlayers,
    updateTime,
    updateUiState
} from "./store/game/Actions";
import { addAlert } from "./store/alert/Actions";
import { addKillmsg } from "./store/killmsg/Actions";
import { addInteractivemsg } from "./store/interactivemsg/Actions";

/* Helpers */
import Player from "./helpers/PlayerHelper";
import { FireLogicType } from "./helpers/FireLogicTypeHelper";
import { Sounds } from "./helpers/SoundsHelper";

/* Components */
import MiniMap from "./components/map/MiniMap";
import AmmoAndHealthCounter from "./components/AmmoAndHealthCounter";
import MatchInfo from "./components/MatchInfo";
import KillAndAliveInfo from "./components/KillAndAliveInfo";
import SpactatorInfo from "./components/SpactatorInfo";
import Gameover from "./components/Gameover";
import DeployScreen from "./components/DeployScreen";
import TeamInfo from "./components/TeamInfo";
import LoadingScreen from "./components/LoadingScreen";
import MapMarkers from "./components/MapMarkers";
import Inventory from "./components/Inventory";
import MenuScreen from "./components/MenuScreen";
import Chat from "./components/chat/Chat";
import InteractProgress from "./components/InteractProgress";

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

        if (state === "None") {
            dispatch(updateGameover(false));
        } else if (state === "Warmup") {
            dispatch(updateGameover(false));
            dispatch(addAlert(
                "The round is starting soon...",
                6,
                Sounds.Notification
            ));
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
        dispatch(updateGameover(true, data.isWin));
    }

    window.OnUpdatePlacement = (placement: number | null) => {
        if (placement !== null) {
            dispatch(updateGameover(undefined, undefined, placement));
        } else {
            dispatch(updateGameover(undefined, undefined, 99));
        }
    }

    /*
    * Player
    */
    window.OnPlayersInfo = (data: any) => {
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
        dispatch(updatePlayerData(data));
    }

    window.OnPlayerHealth = (data: number) => {
        dispatch(updatePlayerHealth(Math.ceil(data)));
    }

    window.OnPlayerArmor = (data: number) => {
        dispatch(updatePlayerArmor(Math.ceil(data)));
    }

    window.OnPlayerPrimaryAmmo = (data: number) => {
        dispatch(updatePlayerPrimaryAmmo(data));
    }

    window.OnPlayerSecondaryAmmo = (data: number) => {
        dispatch(updatePlayerSecondaryAmmo(data));
    }

    window.OnPlayerFireLogic = (data: number) => {
        dispatch(updatePlayerFireLogic(FireLogicType[data] ?? "AUTO"));
    }

    window.OnPlayerCurrentWeapon = (weaponName: string) => {
        dispatch(updatePlayerCurrentWeapon(weaponName));
    }

    window.OnPlayerWeapons = (data: any) => {
        // console.log(data);
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
        dispatch(updatePlayerPosition({
            x: p_DataJson.x,
            y: p_DataJson.y,
            z: p_DataJson.z,
        }));
    }

    window.OnPlayerYaw = (p_Yaw: number) => {
        dispatch(updatePlayerYaw(p_Yaw));
    }

    window.OnPlanePos = (p_DataJson: any) => {
        if (p_DataJson !== undefined && p_DataJson !== null && p_DataJson.x !== undefined && p_DataJson.y !== undefined && p_DataJson.z !== undefined) {
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
        dispatch(openMap(open));
    }

    window.OnMapShow = (show: boolean) => {
        dispatch(showMap(show));
    }

    window.OnUpdateCircles = (data: any) => {
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
        let tempTeam: Player[] = [];
        let tempDowned: string[] = [];
        if (p_Team !== undefined && p_Team.length > 0) {
            p_Team.forEach((teamPlayer: any) => {
                tempTeam.push({
                    name: teamPlayer.Name,
                    state: teamPlayer.State,
                    kill: 0,
                    isTeamLeader: teamPlayer.IsTeamLeader,
                    color: teamPlayer.Color,
                    position: {
                        x: teamPlayer.Position?.x ?? null,
                        y: teamPlayer.Position?.y ?? null,
                        z: teamPlayer.Position?.z ?? null,
                    },
                    yaw: teamPlayer.Yaw,
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
            isTeamLeader: false,
            color: "rgba(255, 187, 86, 0.3)",
            position: {
                x: 522.175720,
                y: 158.705505,
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
                x: 521.175720,
                y: 155.705505,
                z: -921.253479,
            },
            yaw: 110,
        });
        tempTeam.push({
            name: "Test",
            state: 2,
            kill: 0,
            isTeamLeader: false,
            color: "rgba(0, 205, 243, 0.3)",
            position: {
                x: 585.175720,
                y: 159.705505,
                z: -920.253479,
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
                x: 422.175720,
                y: 155.705505,
                z: -922.253479,
            },
            yaw: 10,
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
        p_WorldToScreenY: number
    ) => {
        dispatch(removePing(p_Key));
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
        }));
    }

    window.OnRemoveMarker = (p_Key: string) => {
        dispatch(removePing(p_Key));
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
                        <button onClick={() => dispatch(updateSpectatorEnabled(true))}>Set Spectator</button>
                        <button onClick={() => dispatch(updateGameover(true))}>Set Gameover Screen</button>
                        <button onClick={() => window.OnLocalPlayerInfo({
                            name: 'KVN',
                            kill: 15,
                            state: 1,
                            isTeamLeader: true,
                            color: "rgba(255, 0, 0, 0.3)",
                        })}>SetDummyLocalPlayer</button>
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
                        <button onClick={() => SetKilledMessage(false, 'TestUser', 3)}>SetKillMsg</button>
                        <button onClick={() => dispatch(switchDeployScreen())}>setDeployScreen</button>
                        <button onClick={CreateRandomTeam}>CreateRandomTeam</button>
                        <button onClick={() => window.OnPlayerIsOnPlane(true)}>OnPlayerIsOnPlane true</button>
                        <button onClick={() => window.OnPlayerIsOnPlane(false)}>OnPlayerIsOnPlane false</button>
                    </div>

                    <div id="VUBattleRoyale">
                        <MatchInfo />
                        <TeamInfo />
                        {/*<MapMarkers />*/}

                        {deployScreen ?
                            <DeployScreen />
                        :
                            <>
                                <KillAndAliveInfo />
                                <SpactatorInfo />
                                <AmmoAndHealthCounter />
                                <Gameover />

                                {!spectating &&
                                    <>
                                        <MiniMap />
                                        {/*<InteractProgress 
                                            timeout={10}
                                            clearTimeout={() => alert('clear')}
                                        />*/}
                                        {/*<Inventory />*/}
                                    </>
                                }
                            </>
                        }
                    </div>
                </>
            }
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
        OnPlayerCurrentWeapon: (weaponName: string) => void;
        OnPlayerWeapons: (data: any) => void;
        OnPlayerIsOnPlane: (isOnPlane: boolean) => void;
        OnGameOverScreen: (data: any) => void;
        OnUpdatePlacement: (placemen: number | null) => void;

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

        OnSetUIState: (p_Toggle: "hidden" | "loading" | "game" | "menu") => void;

        OnCreateMarker: (p_Key: string, p_Color: string, p_PositionX: number, p_PositionZ: number, p_WorldToScreenX: number, p_WorldToScreenY: number) => void;
        OnRemoveMarker: (p_Key: string) => void;
        OnUpdateMarker: (p_Key: string, p_WorldToScreenX: number, p_WorldToScreenY: number) => void;
    }
}
