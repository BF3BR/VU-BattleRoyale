import React, { useEffect } from "react";

import { Sounds } from "../helpers/SoundsHelper";

import exclamation from "../assets/img/warning.svg";
import alert from "../assets/sounds/alarm.mp3";
import objective from "../assets/sounds/objective.mp3";
import countdown from "../assets/sounds/countdown.mp3";

import "./Alert.scss";

interface Props {
    alert: string|null;
    playSound: Sounds;
    afterInterval: () => void;
    length: number;
};

const alertAudio = new Audio(alert);
alertAudio.volume = 0.3;
alertAudio.autoplay = false;
alertAudio.loop = false;

const objectiveAudio = new Audio(objective);
objectiveAudio.volume = 0.3;
objectiveAudio.autoplay = false;
objectiveAudio.loop = false;

const countdownAudio = new Audio(countdown);
countdownAudio.volume = 0.3;
countdownAudio.autoplay = false;
countdownAudio.loop = false;

const Alert: React.FC<Props> = ({ alert, afterInterval, playSound, length }) => {
    useEffect(() => {
        let intLength = length;
        if (intLength === undefined || intLength === null) {
            intLength = 4000;
        }

        if (alert !== null) {
            switch (playSound) {
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
            
            const interval = setInterval(() => {
                afterInterval();
            }, intLength * 1000);

            return () => {
                alertAudio.currentTime = 0.0;
                alertAudio.pause();

                objectiveAudio.currentTime = 0.0;
                objectiveAudio.pause();

                countdownAudio.currentTime = 0.0;
                countdownAudio.pause();

                clearInterval(interval);
            }
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [alert, length]);

    return (
        <>
            <img src={exclamation} alt="Warning" className="preload-image" />
            {alert !== null &&
                <div id="Alert" className={"scale-up-center"}>
                    <div className="card-content">
                        <img src={exclamation} alt="Warning" />
                        <span>{alert??''}</span>
                    </div>
                </div>
            }
        </>
    );
};

Alert.defaultProps = {
    alert: null,
};

export default Alert;
