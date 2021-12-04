import React from "react";

interface Props {
    fill: string;
}

const ArmorIcon: React.FC<Props> = ({ fill }) => {
    return (
        <div className="armor-icon">
            <svg fill={fill} viewBox="0 0 347.966 347.966">
                <path d="M317.306,54.369C257.93,54.369,212.443,37.405,173.977,0C135.516,37.405,90.031,54.369,30.66,54.369
                    c0,97.401-20.155,236.936,143.317,293.597C337.46,291.304,317.306,151.77,317.306,54.369z"/>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
                <g>
                </g>
            </svg>
        </div>
    )
};

export default ArmorIcon;
