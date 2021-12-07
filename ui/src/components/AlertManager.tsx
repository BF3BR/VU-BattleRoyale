import React, { useEffect, useState } from "react";
import { connect } from "react-redux";
import { Howl } from "howler";

import { RootState } from "../store/RootReducer";
import { AlertState } from "../store/alert/Types";
import { Sounds, StopAllSounds } from "../helpers/SoundHelper";

import exclamation from "../assets/img/warning.svg";

import "./AlertManager.scss";
import { PlaySound } from "../helpers/SoundHelper";

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
            PlaySound(localAlert.sound);

            const interval = setInterval(() => {
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
const mapDispatchToProps = () => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(AlertManager);

