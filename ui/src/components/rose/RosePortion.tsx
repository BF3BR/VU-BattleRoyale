import React from "react";
import { PortionModel } from "../../helpers/RoseHelper";

import "./RosePortion.scss";

type Props = {
    index: number;
    numOfPortions: number;
    portion: PortionModel;
    isSelected: boolean;
    onHover: (index: number) => void;
    onClick: (index: number) => void;
}

const RosePortion: React.FC<Props> = ({ 
    index,
    numOfPortions,
    portion,
    isSelected,
    onHover,
}) => {
    const getBackTransform = () => {
        const portionAngle = 360 / numOfPortions;
        const rotationAngle = portionAngle * index + 90;
        const skew = 90 - portionAngle;
        return 'rotate(' + rotationAngle + 'deg) skewY(-' + skew + 'deg)';
    }

    const getFrontTransform = () => {
        const portionAngle = 360 / numOfPortions;
        const imageCenter = portionAngle * index + portionAngle / 2;
        const imageCenterRad = imageCenter * Math.PI / 180;
        return 'translateX(' + (Math.cos(imageCenterRad) * 21) + 'vmin) translateY(' + (Math.sin(imageCenterRad) * 21) + 'vmin)';
    }

    return (
        <div id="rosePortion" className={isSelected ? "selected" : ""}>
            <div id="roseBackPortion" 
                style={{ transform: getBackTransform() }}
                onMouseEnter={() => onHover(index)}
            />
            <div id="roseFrontPortion" style={{ transform: getFrontTransform() }}>
                {portion.image &&
                    <img 
                        className="portionIcon" 
                        src={portion.image}
                        alt=""
                    />
                }
            </div>
        </div>
    );
};

export default RosePortion;
