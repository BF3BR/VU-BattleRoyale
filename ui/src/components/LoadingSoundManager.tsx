import React, { useEffect, useState } from "react";

import loading from "../assets/sounds/DELETE_THIS_WHEN_WE_RELEASE.mp3";

const loadingAudio = new Audio(loading);
loadingAudio.volume = 0.2;
loadingAudio.autoplay = false;
loadingAudio.loop = false;

type Props = {
    uiState: string;
};

const LoadingSoundManager: React.FC<Props> = ({ uiState }) => {
    const [currentVolume, setCurrentVolume] = useState(0.2);
    
    var fadeInterval: any = null;
    useEffect(() => {
        if (uiState === "loading") {
            setCurrentVolume(0.2);
            loadingAudio.volume = 0.2;
            loadingAudio.play();
        } else {
            if (fadeInterval !== null) {
                loadingAudio.currentTime = 0.0;
                loadingAudio.pause();
                clearInterval(fadeInterval);
                fadeInterval = null;
            } else {
                onEnd();
            }
        }
    }, [uiState]);

    useEffect(() => {
        if (currentVolume >= 0) {
            loadingAudio.volume = currentVolume;
        }
    }, [currentVolume]);

    const onEnd = () => {
        var _vol = currentVolume;
        fadeInterval = setInterval(function() {
            if (_vol > 0) {
                _vol = _vol - 0.0002;
                setCurrentVolume(_vol);
            } else {
                loadingAudio.currentTime = 0.0;
                loadingAudio.pause();
                clearInterval(fadeInterval);
                fadeInterval = null;
                return;
            }
        }, 15);
    }

    return (<></>);
};

export default LoadingSoundManager;

