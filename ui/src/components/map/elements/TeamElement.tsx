import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import * as PIXI from 'pixi.js';
import { Graphics, Sprite } from '@inlet/react-pixi';

import { drawPlayer, drawPlayerVision, getConvertedPlayerColor, getMapPos } from './ElementHelpers';
import { Player } from "../../../helpers/PlayerHelper";

import medic from "../../../assets/img/medic.svg";
const medicTexture = PIXI.Texture.from(medic);

interface StateFromReducer {
    team: Player[];
    name: string|null;
    spectating: boolean;
    spectatorTarget: string;
}

type Props = {
    topLeftPos: { x: number, z: number },
    textureWidthHeight: number,
    worldWidthHeight: number,
} & StateFromReducer;

const TeamElement: React.FC<Props> = ({ 
    // Props
    topLeftPos,
    textureWidthHeight,
    worldWidthHeight,
    // Reducer
    team,
    name,
    spectating,
    spectatorTarget,
}) => {
    return (
        <>
            {(team !== null && team.length > 0 && name !== null) &&
                team
                .filter((player: Player) => {
                    if (player.name !== name) {
                        return true;
                    }

                    if (spectating && player.name !== spectatorTarget) {
                        return true;
                    }

                    if (player.state !== 3) {
                        return true;
                    }

                    if (player.position.x !== null && player.position.z !== null) {
                        return true;
                    }

                    return false;
                })
                .map((player: Player, key: number) => (
                    (player.state === 1 ?
                        <React.Fragment key={key}>
                            <Graphics 
                                draw={(g: any) => drawPlayerVision(g)}
                                x={getMapPos(player.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                                y={getMapPos(player.position.z, topLeftPos.z,  textureWidthHeight, worldWidthHeight)}
                                angle={player.yaw}
                                scale={0.5}
                            />
                            <Graphics 
                                draw={(g: any) => drawPlayer(g, getConvertedPlayerColor(player.color))}
                                x={getMapPos(player.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                                y={getMapPos(player.position.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)}
                                angle={player.yaw}
                                scale={0.5}
                            />
                        </React.Fragment>
                    :
                        <Sprite
                            texture={medicTexture}
                            anchor={0.5}
                            width={50}
                            height={50}
                            x={getMapPos(player.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                            y={getMapPos(player.position.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)}
                            angle={0}
                            scale={.05}
                            tint={getConvertedPlayerColor(player.color)}
                            key={key}
                        />
                    )
                ))
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // TeamReducer
        team: state.TeamReducer.players,
        // PlayerReducer
        name: state.PlayerReducer.player.name,
        // SpectatorReducer
        spectating: state.SpectatorReducer.enabled,
        spectatorTarget: state.SpectatorReducer.target,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(TeamElement);
