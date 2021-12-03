import { Howl, Howler } from "howler";

import alarm from "../assets/sounds/alarm.mp3";
import objective from "../assets/sounds/objective.mp3";
import countdown from "../assets/sounds/countdown.mp3";
import error from "../assets/sounds/error.mp3";
import airdrop from "../assets/sounds/airdrop.mp3";
import gameover_loser from "../assets/sounds/gameover_loser.mp3";
import gameover_winner from "../assets/sounds/gameover_winner.mp3";
import shield_break from "../assets/sounds/shield_break.mp3";
import ping from "../assets/sounds/ping.mp3";
import ping_enemy from "../assets/sounds/ping_enemy.mp3";
import kill from "../assets/sounds/kill.mp3";
import downed from "../assets/sounds/downed.mp3";
import loading from "../assets/sounds/loading.mp3";
import navigate from "../assets/sounds/navigate.mp3";
import click from "../assets/sounds/click.mp3";

Howler.volume(0.85);

const defaultAlertAudio = new Howl({
    src: [alarm]
});

const objectiveAlertAudio = new Howl({
    src: [objective]
});

const countdownAlertAudio = new Howl({
    src: [countdown]
});

const errorAlertAudio = new Howl({
    src: [error]
});

const airdropAlertAudio = new Howl({
    src: [airdrop]
});

const gameoverWinnerAudio = new Howl({
    src: [gameover_winner],
    volume: .6,
});

const gameoverLoserAudio = new Howl({
    src: [gameover_loser],
    volume: .6,
});

const shieldBreakAudio = new Howl({
    src: [shield_break],
    volume: .75,
});

const pingAudio = new Howl({
    src: [ping],
    volume: .65,
});

const pingEnemyAudio = new Howl({
    src: [ping_enemy],
    volume: .65,
});

const killAudio = new Howl({
    src: [kill],
    volume: .65,
});

const downedAudio = new Howl({
    src: [downed],
    volume: .65,
});

const loadingAudio = new Howl({
    src: [loading],
    volume: 0.2,
    loop: true,
});

const navigateAudio = new Howl({
    src: [navigate],
    volume: 0.06,
});

const clickAudio = new Howl({
    src: [click],
    volume: 0.1,
});

export enum Sounds {
    None,
    Alert,
    Notification,
    CountDown,
    Error,
    Airdrop,
    GameoverLoser,
    GameoverWinner,
    ShieldBreak,
    Ping,
    PingEnemy,
    Kill,
    Downed,
    Loading,
    Navigate,
    Click,
}

export const PlaySound = (sound: Sounds) => {
    // Howler.stop();
    switch (sound) {
        case Sounds.Alert:
            defaultAlertAudio.play();
            break;
        case Sounds.Notification:
            objectiveAlertAudio.play();
            break;
        case Sounds.CountDown:
            countdownAlertAudio.play();
            break;
        case Sounds.Error:
            errorAlertAudio.play();
            break;
        case Sounds.Airdrop:
            airdropAlertAudio.play();
            break;
        case Sounds.GameoverLoser:
            gameoverLoserAudio.play();
            break;
        case Sounds.GameoverWinner:
            gameoverWinnerAudio.play();
            break;
        case Sounds.ShieldBreak:
            shieldBreakAudio.play();
            break;
        case Sounds.Ping:
            pingAudio.play();
            break;
        case Sounds.PingEnemy:
            pingEnemyAudio.play();
            break;
        case Sounds.Kill:
            killAudio.play();
            break;
        case Sounds.Downed:
            downedAudio.play();
            break;
        case Sounds.Navigate:
            navigateAudio.play();
            break;
        case Sounds.Click:
            clickAudio.play();
            break;
        case Sounds.None:
        default:
            break;
    }
}

export const StopAllSounds = () => {
    Howler.stop();
}

export const FadeOutLoading = () => {
    loadingAudio.fade(.2, 0, 2500);
    loadingAudio.once("fade", () => {
        loadingAudio.stop();
    });
}

export const FadeInLoading = () => {
    loadingAudio.play();
    loadingAudio.fade(0, .2, 1000);
}
