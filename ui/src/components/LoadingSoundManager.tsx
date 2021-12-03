import React, { useEffect } from "react";
import { FadeInLoading, FadeOutLoading } from "../helpers/SoundHelper";

type Props = {
    uiState: string;
};

const LoadingSoundManager: React.FC<Props> = ({ uiState }) => {
    useEffect(() => {
        if (uiState === "loading") {
            FadeInLoading();
        } else {
            FadeOutLoading();
        }
    }, [uiState]);

    return (<></>);
};

export default LoadingSoundManager;

