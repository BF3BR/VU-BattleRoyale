import React, { useEffect } from "react";

import "./Alert.scss";

import exclamation from "../assets/img/warning.svg";

interface Props {
    alert: string|null;
    afterInterval: () => void;
};

const Alert: React.FC<Props> = ({ alert, afterInterval }) => {
    useEffect(() => {
        const interval = setInterval(() => {
            afterInterval();
        }, 8000);
        return () => {
            clearInterval(interval);
        }
    }, [alert]);

    return (
        <>
            <div id="Alert" className={alert !== null ? 'show' : ''}>
                <img src={exclamation} alt="Warning" />
                <span>{alert??''}</span>
            </div>
        </>
    );
};

Alert.defaultProps = {
    alert: null,
};

export default Alert;
