import React, { useEffect, useState } from 'react';
import { CountdownCircleTimer } from 'react-countdown-circle-timer';

interface Props {
    slot: any;
    onComplete: (slot: any) => void;
    time: number | null;
}
const getWidth = () => window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;

const InventoryTimer: React.FC<Props> = ({ slot, onComplete, time }) => {
    const [size, setSize] = useState<number>(getWidth() * 0.04);

    useEffect(() => {
        const resizeListener = () => {
            setSize(getWidth() * 0.1);
        };
        window.addEventListener('resize', resizeListener);
    
        return () => {
            window.removeEventListener('resize', resizeListener);
        }
    }, []);

    const renderTime = (elapsedTime: number) => {
        return (
            <div className="time-wrapper">
                <div className="time">{(time - elapsedTime).toFixed(1)}</div>
            </div>
        );
    };

    return (
        <>
            {time !== null &&
                <div className="inventoryTimer">
                    <CountdownCircleTimer
                        isPlaying
                        duration={time}
                        colors="#FFF"
                        trailColor="#000"
                        size={size}
                        strokeWidth={size * 0.115}
                        strokeLinecap="round"
                        onComplete={() => onComplete(slot)}
                    >
                        {({ elapsedTime }) =>
                            renderTime(elapsedTime)
                        }
                    </CountdownCircleTimer>
                </div>
            }
        </>
    )
};

export default InventoryTimer;
