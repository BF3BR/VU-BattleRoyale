import React, { useEffect, useState } from "react";
import { CircularProgressbar, buildStyles } from 'react-circular-progressbar';

import "./InteractProgress.scss";

interface Props {
    timeout: number|null;
    clearTimeout: () => void;
}

const InteractProgress: React.FC<Props> = ({ timeout }) => {
    const [time, setTime] = useState<number|null>(timeout);

    const tick = () => {
        if (time === 0) {
            clearTimeout();
            return;
        } else {
            setTime(prevState => prevState - 1);
        }
    };

    useEffect(() => {
        const timerID = setInterval(() => tick(), 1000);
        return () => clearInterval(timerID);
    });

    useEffect(() => {
        setTime(timeout);
    }, [timeout]);

    return (
        <>
            {timeout !== null &&
                <div className="InteractProgress">
                    <CircularProgressbar
                        value={time / timeout * 100}
                        maxValue={100}
                        strokeWidth={12}
                        background={false}
                        styles={buildStyles({
                            rotation: 0,
                            strokeLinecap: 'butt',
                            pathColor: `rgb(148, 205, 243)`,
                            trailColor: 'rgba(55, 100, 130, .5)',
                            backgroundColor: 'transparent',
                            pathTransitionDuration: 0.4,
                        })}
                    />
                </div>
            }
        </>
    );
};

export default InteractProgress;
