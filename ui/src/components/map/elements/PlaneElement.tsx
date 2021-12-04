import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import * as PIXI from 'pixi.js';
import { Sprite } from '@inlet/react-pixi';

import Vec3 from '../../../helpers/Vec3Helper';
import { getMapPos } from './ElementHelpers';

import airplane from "../../../assets/img/airplane.svg";
const airPlaneTexture = PIXI.Texture.from(airplane);

interface StateFromReducer {
    planePos: Vec3|null;
    planeYaw: number|null;
    open: boolean;
}

type Props = {
    topLeftPos: { x: number, z: number },
    textureWidthHeight: number,
    worldWidthHeight: number,
} & StateFromReducer;

const PlaneElement: React.FC<Props> = ({ 
    // Props
    topLeftPos,
    textureWidthHeight,
    worldWidthHeight,
    // Reducer
    planePos, 
    planeYaw,
    open,
}) => {


    return (
        <>
            {planePos !== null &&
                <>
                    <Sprite
                        texture={airPlaneTexture}
                        anchor={0.5}
                        width={50}
                        height={50}
                        x={getMapPos(planePos.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                        y={getMapPos(planePos.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)}
                        angle={planeYaw}
                        scale={open ? .12 : 0.105}
                    />
                </>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // MapReducer
        open: state.MapReducer.open,
        // PlaneReducer
        planePos: state.PlaneReducer.position,
        planeYaw: state.PlaneReducer.yaw,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(PlaneElement);
