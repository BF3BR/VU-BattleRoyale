import React, { useEffect } from "react";
import { useTimer } from "react-compound-timer/build/hook/useTimer";

interface Props {
    time: number|null;
}

const Timer: React.FC<Props> = ({ time }) => {
    const { value, controls: { setTime, start, stop }} = useTimer({ initialTime: 0, direction: "backward", startImmediately: false, timeToUpdate: 100 });

    useEffect(() => {
        if (time && time !== null) {
            setTime(1000 * time);
            start();
        }

        return () => {
            setTime(0);
            stop();
        }
    }, [time, setTime, start, stop]);

    return (
        <span className="Timer">
            {(value !== null)
            ?
                <>
                    {(value.m < 10 ? `0${value.m}` : value.m)}:{(value.s < 10 ? `0${value.s}` : value.s)}
                </>
            :
                <>
                    00:00
                </>
            }
        </span>
    );
};

export default Timer;
