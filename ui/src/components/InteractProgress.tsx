import React, { useEffect, useState } from "react";
import { CountdownCircleTimer } from "react-countdown-circle-timer";

import health from "../assets/img/medic.svg";

import "./InventoryTimer.scss";

interface Props {
    onComplete: () => void;
    time: number | null;
}
const getWidth = () => window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;

const InteractProgress: React.FC<Props> = ({ onComplete, time }) => {
    const [size, setSize] = useState<number>(getWidth() * 0.05);

    useEffect(() => {
        const resizeListener = () => {
            setSize(getWidth() * 0.05);
        };
        window.addEventListener('resize', resizeListener);
    
        return () => {
            window.removeEventListener('resize', resizeListener);
        }
    }, []);

    const renderTime = (elapsedTime: number) => {
        return (
            <div className="time-wrapper">
                <img src={health} alt="" />
            </div>
        );
    };

    return (
        <>
            {time !== null &&
                <div className="inventoryTimerWrapper">
                    <div className="inventoryTimer">
                        <CountdownCircleTimer
                            isPlaying
                            duration={time}
                            colors="#fff"
                            trailColor="rgba(0,0,0,.35)"
                            size={size}
                            strokeWidth={size * 0.065}
                            strokeLinecap="square"
                            onComplete={() => onComplete()}
                        >
                            {({ elapsedTime }: any) =>
                                renderTime(elapsedTime)
                            }
                        </CountdownCircleTimer>
                    </div>
                    <h4 id="InventoryTimerName">
                        Reviving
                    </h4>
                </div>
            }
        </>
    )
};

export default InteractProgress;
