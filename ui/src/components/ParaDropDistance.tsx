import React, { useEffect, useRef, useState } from "react";

import './ParaDropDistance.scss';

interface Props {
    percentage: number;
    distance: number;
    warnPercentage: number;
}

const ParaDropDistance: React.FC<Props> = ({ percentage, distance, warnPercentage }) => {
    return (
        <>
            <div id="paraDropDistance">
                <div className="percentage" style={{ height: percentage + "%" }}></div>
                <div className="warnPercentage" style={{ 
                    height: (percentage > warnPercentage ? warnPercentage : percentage) + "%"
                }}></div>
                <div className="distance" style={{ bottom: percentage + "%" }}>
                    {distance??0} m
                </div>
            </div>
        </>
    );
};

export default ParaDropDistance;
