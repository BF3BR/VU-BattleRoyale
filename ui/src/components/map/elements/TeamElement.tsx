import React from "react";
import { connect } from "react-redux";
import { RootState } from "../../../store/RootReducer";

import { Graphics } from '@inlet/react-pixi';

import { drawPlayer, getConvertedPlayerColor, getMapPos } from './ElementHelpers';
import { Player } from "../../../helpers/PlayerHelper";

interface StateFromReducer {
    team: Player[];
    name: string|null;
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
}) => {
    return (
        <>
            {(team !== null && team.length > 0 && name !== null) &&
                team
                .filter((player: Player) => player.name !== name)
                .filter((player: Player) => player.state !== 3)
                .filter((player: Player) => (player.position.x !== null && player.position.z !== null))
                .map((player: Player, key: number) => (
                    <Graphics 
                        draw={(g: any) => drawPlayer(g, getConvertedPlayerColor(player.color))}
                        x={getMapPos(player.position.x, topLeftPos.x, textureWidthHeight, worldWidthHeight)}
                        y={getMapPos(player.position.z, topLeftPos.z, textureWidthHeight, worldWidthHeight)}
                        angle={player.yaw}
                        scale={0.5}
                        key={key}
                    />
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
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(TeamElement);
