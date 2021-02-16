import React, { useEffect } from "react";

import "./Alert.scss";

import exclamation from "../assets/img/warning.svg";
import alert from "../assets/sounds/alarm.mp3";
import objective from "../assets/sounds/objective.mp3";

interface Props {
    alert: string|null;
    playSound: boolean;
    afterInterval: () => void;
};

const alertAudio = new Audio(alert);
alertAudio.volume = 0.3;
alertAudio.autoplay = false;
alertAudio.loop = false;

const objectiveAudio = new Audio(objective);
objectiveAudio.volume = 0.3;
objectiveAudio.autoplay = false;
objectiveAudio.loop = false;


const Alert: React.FC<Props> = ({ alert, afterInterval, playSound }) => {
    useEffect(() => {
        if (alert !== null) {
            if (playSound) {
                alertAudio.play();
            } else {
                objectiveAudio.play();
            }
            const interval = setInterval(() => {
                afterInterval();
            }, 888000);

            return () => {
                alertAudio.currentTime = 0.0;
                alertAudio.pause();

                objectiveAudio.currentTime = 0.0;
                objectiveAudio.pause();

                clearInterval(interval);
            }
        }
    }, [alert, alertAudio]);

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
