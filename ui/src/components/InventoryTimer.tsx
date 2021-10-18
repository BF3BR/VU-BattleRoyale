import React, { useEffect, useState } from 'react';
import { CountdownCircleTimer } from 'react-countdown-circle-timer';
import { connect, useDispatch } from 'react-redux';
import { updateProgress } from '../store/inventory/Actions';
import { RootState } from '../store/RootReducer';

import "./InventoryTimer.scss";

interface StateFromReducer {
    progress: {
        slot: any,
        time: number|null,
    },
}

type Props = StateFromReducer;

const getWidth = () => window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;

const InventoryTimer: React.FC<Props> = ({ progress }) => {
    const dispatch = useDispatch();
    
    const [size, setSize] = useState<number>(getWidth() * 0.04);

    useEffect(() => {
        const resizeListener = () => {
            setSize(getWidth() * 0.04);
        };
        window.addEventListener('resize', resizeListener);
    
        return () => {
            window.removeEventListener('resize', resizeListener);
        }
    }, []);

    const renderTime = (elapsedTime: number) => {
        return (
            <div className="time-wrapper">
                <div className="time">{(progress.time - elapsedTime).toFixed(1)}</div>
            </div>
        );
    };

    return (
        <>
            {(progress.slot !== null && progress.time !== null) &&
                <div className="inventoryTimerWrapper">
                    <div className="inventoryTimer">
                        <CountdownCircleTimer
                            isPlaying
                            duration={progress.time}
                            colors="#FFF"
                            trailColor="#000"
                            size={size}
                            strokeWidth={size * 0.115}
                            strokeLinecap="round"
                            onComplete={() => {
                                dispatch(updateProgress(null, null));
                            }}
                        >
                            {({ elapsedTime }) =>
                                renderTime(elapsedTime)
                            }
                        </CountdownCircleTimer>
                    </div>
                    <h4 id="InventoryTimerName">
                        Using {progress.slot?.Name ?? ""}
                    </h4>
                </div>
            }
        </>
    )
};
const mapStateToProps = (state: RootState) => {
    return {
        // InventoryReducer
        progress: state.InventoryReducer.progress,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(InventoryTimer);
