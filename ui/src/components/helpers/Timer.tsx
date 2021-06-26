import React from "react";

interface Props {
    time: number|null;
}

const Timer: React.FC<Props> = ({ time }) => {

    const fancyTimeFormat = () => {  
        var mins = ~~((time % 3600) / 60);
        var secs = ~~time % 60;

        var ret = "";

        ret += "" + mins + ":" + (secs < 10 ? "0" : "");
        ret += "" + secs;
        return ret;
    }

    return (
        <span className="Timer">
            {(time !== null) &&
                fancyTimeFormat()
            }
        </span>
    );
};

export default Timer;
