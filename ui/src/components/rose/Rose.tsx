import React, { useEffect, useState } from "react";
import { connect } from "react-redux";
import { PortionModel } from "../../helpers/RoseHelper";
import { RootState } from "../../store/RootReducer";
import RosePortion from "./RosePortion";
import { sendToLua } from "../../Helpers";

import medic from "../../assets/img/medic.svg";
import shield from "../../assets/img/inventory/shield.svg";
import running from "../../assets/img/inventory/running.svg";
import rifle from "../../assets/img/inventory/rifle.svg";
import bullets from "../../assets/img/inventory/bullets.svg";
import crosshair from "../../assets/img/inventory/crosshair.svg";

import "./Rose.scss";

interface StateFromReducer {
    showCommoRose: boolean;
}

type Props = StateFromReducer;

const portions: Array<PortionModel> = [
    {
        id: 4,
        name: "General",
        image: crosshair,
        typeIndex: 0,
    },
    {
        id: 3,
        name: "Enemy",
        image: running,
        typeIndex: 1,
    },
    {
        id: 5,
        name: "Loot / Weapon",
        image: rifle,
        typeIndex: 2,
    },
    {
        id: 2,
        name: "Ammo",
        image: bullets,
        typeIndex: 3,
    },
    {
        id: 6,
        name: "Armor",
        image: shield,
        typeIndex: 4,
    },
    {
        id: 1,
        name: "Health",
        image: medic,
        typeIndex: 5,
    },
];

const Rose: React.FC<Props> = ({ showCommoRose }) => {
    const [hoveredPortionIndex, setHoveredPortionIndex] = useState<number>(4);

    const getOverlayStyle = () => {
        const portionAngle = 360 / portions.length;
        const rotationAngle = portionAngle * hoveredPortionIndex; // Rotate 90 degrees so 0 degrees is the right of the horizontal line

        const portionAngleRad = portionAngle * Math.PI / 180;
        const rotationAngleRad = rotationAngle * Math.PI / 180;

        const x1 = 50 + 100 * Math.cos(rotationAngleRad);
        const y1 = 50 + 100 * Math.sin(rotationAngleRad);

        const x2 = 50 + 200 * Math.cos(rotationAngleRad + portionAngleRad / 2);
        const y2 = 50 + 200 * Math.sin(rotationAngleRad + portionAngleRad / 2);

        const x3 = 50 + 100 * Math.cos(rotationAngleRad + portionAngleRad);
        const y3 = 50 + 100 * Math.sin(rotationAngleRad + portionAngleRad);

        return 'polygon(50% 50%, ' + x1 + '% ' + y1 + '%, ' + x2 + '% ' + y2 + '%, ' + x3 + '% ' + y3 + '%)';
    }

    const handleHover = (index: number) => {
        const typeIndex = portions.find((portion: PortionModel) => portion.id === index).typeIndex ?? -1;
        sendToLua('WebUI:HoverCommoRose', typeIndex);
        setHoveredPortionIndex(index);
    }

    useEffect(() => {
        if (showCommoRose) {
            setHoveredPortionIndex(4);
        }
    }, [showCommoRose])

    return (
        <>
            {showCommoRose &&
                <div id="rose">
                    {portions.map((portion: PortionModel, index: number) =>
                        <RosePortion
                            key={index}
                            index={portion.id}
                            numOfPortions={portions.length}
                            portion={portion}
                            isSelected={Boolean(portion.id === hoveredPortionIndex)}
                            onHover={handleHover}
                            onClick={(index: number) => console.log(index)}
                        />
                    )}
                    {hoveredPortionIndex !== -1 &&
                        <div id="nameDisplay">
                            <img 
                                className="portionIcon" 
                                src={portions.find((portion: PortionModel) => portion.id === hoveredPortionIndex).image}
                                alt=""
                            />
                            <span>{portions.find((portion: PortionModel) => portion.id === hoveredPortionIndex).name??""}</span>
                        </div>
                    }
                    <div className="pointerBlocker" />
                    <div id="doughnutContainer">
                        <div id="foregroundDoughnut" />
                        <div id="backgroundDoughnut" />
                        {(hoveredPortionIndex !== -1) &&
                            <>
                                <div id="overlayDoughnut" style={{ clipPath: getOverlayStyle() }} />
                                <div id="overlayDoughnutBg" style={{ clipPath: getOverlayStyle() }} />
                            </>
                        }
                    </div>
                </div>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        showCommoRose: state.GameReducer.showCommoRose
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Rose);
