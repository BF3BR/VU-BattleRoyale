import React, { useEffect, useState } from "react";
import { RootState } from "../RootReducer";
import { useSelector } from "react-redux";
import { AlertState } from "./Types";

import { Sounds } from "../../helpers/SoundsHelper";

import exclamation from "../../assets/img/warning.svg";
import alert from "../../assets/sounds/alarm.mp3";
import objective from "../../assets/sounds/objective.mp3";
import countdown from "../../assets/sounds/countdown.mp3";

import "./Alert.scss";
import { VolumeConst } from "../../helpers/SoundHelper";

const alertAudio = new Audio(alert);
alertAudio.volume = VolumeConst;
alertAudio.autoplay = false;
alertAudio.loop = false;

const objectiveAudio = new Audio(objective);
objectiveAudio.volume = VolumeConst;
objectiveAudio.autoplay = false;
objectiveAudio.loop = false;

const countdownAudio = new Audio(countdown);
countdownAudio.volume = VolumeConst;
countdownAudio.autoplay = false;
countdownAudio.loop = false;

const Alert: React.FC = () => {
    const alertFromReducer = useSelector(
        (state: RootState) => state.AlertReducer
    );

    const [localAlert, setLocalAlert] = useState<AlertState|null>(null);

    let interval: any = null;
    useEffect(() => {
        if (alertFromReducer.message) {
            switch (alertFromReducer.sound) {
                case Sounds.Alert:
                    alertAudio.play();
                    break;
                case Sounds.Notification:
                    objectiveAudio.play();
                    break;
                case Sounds.CountDown:
                    countdownAudio.play();
                    break;
                case Sounds.None:
                default:
                    break;
            }

            setLocalAlert({
                message: alertFromReducer.message,
                duration: alertFromReducer.duration,
                sound: alertFromReducer.sound,
            });
            
            interval = setInterval(() => {
                onEnd();
            }, alertFromReducer.duration * 1000);
        }

        return () => {
            onEnd();
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [alertFromReducer]);

    const onEnd = () => {
        alertAudio.currentTime = 0.0;
        alertAudio.pause();

        objectiveAudio.currentTime = 0.0;
        objectiveAudio.pause();

        countdownAudio.currentTime = 0.0;
        countdownAudio.pause();

        setLocalAlert(null);

        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (
        <>
            <img src={exclamation} alt="Warning" className="preload-image" />
            {localAlert !== null &&
                <div id="Alert" className={"scale-up-center"}>
                    <div className="card-content">
                        <img src={exclamation} alt="Warning" />
                        <span>{localAlert.message??''}</span>
                    </div>
                </div>
            }
        </>
    );
};

export default Alert;
