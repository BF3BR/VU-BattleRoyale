import React, { useEffect, useState } from "react";
import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";
import { AlertState } from "../store/alert/Types";

import { VolumeConst } from "../helpers/SoundHelper";
import { Sounds } from "../helpers/SoundsHelper";

import exclamation from "../assets/img/warning.svg";
import alarm from "../assets/sounds/alarm.mp3";
import objective from "../assets/sounds/objective.mp3";
import countdown from "../assets/sounds/countdown.mp3";
import error from "../assets/sounds/error.mp3";

import "./AlertManager.scss";

const alertAudio = new Audio(alarm);
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

const errorAudio = new Audio(error);
errorAudio.volume = VolumeConst;
errorAudio.autoplay = false;
errorAudio.loop = false;

interface StateFromReducer {
    message: string,
    duration: number,
    sound: Sounds,
    date: number|null,
}

type Props = StateFromReducer;

const AlertManager: React.FC<Props> = ({ message, duration, sound, date }) => {
    const [localAlert, setLocalAlert] = useState<AlertState|null>(null);

    useEffect(() => {
        if (message) {
            setLocalAlert({
                message: message,
                duration: duration,
                sound: sound,
                date: date,
            });
        }
    }, [date]);
    
    useEffect(() => {
        if (localAlert !== null) {
            switch (localAlert.sound) {
                case Sounds.Alert:
                    alertAudio.currentTime = 0.0;
                    alertAudio.play();
                    break;
                case Sounds.Notification:
                    objectiveAudio.currentTime = 0.0;
                    objectiveAudio.play();
                    break;
                case Sounds.CountDown:
                    countdownAudio.currentTime = 0.0;
                    countdownAudio.play();
                    break;
                case Sounds.Error:
                    errorAudio.currentTime = 0.0;
                    errorAudio.play();
                    break;
                case Sounds.None:
                default:
                    break;
            }
    
            const interval = setInterval(() => {
                alertAudio.pause();
                objectiveAudio.pause();
                countdownAudio.pause();
                errorAudio.pause();

                setLocalAlert(null);
            }, duration * 1000);

            return () => clearInterval(interval);
        }
    }, [localAlert]);

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

const mapStateToProps = (state: RootState) => {
    return {
        // AlertReducer
        duration: state.AlertReducer.duration,
        message: state.AlertReducer.message,
        sound: state.AlertReducer.sound,
        date: state.AlertReducer.date,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(AlertManager);

