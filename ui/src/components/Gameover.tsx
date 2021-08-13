import React, { useEffect } from "react";
import { connect, useDispatch } from "react-redux";
import { RootState } from "../store/RootReducer";
import { updateGameover } from "../store/game/Actions";

import winner from "../assets/sounds/winner.mp3";

import "./Gameover.scss";
import { VolumeConst } from "../helpers/SoundHelper";

const alertAudio = new Audio(winner);
alertAudio.volume = VolumeConst;
alertAudio.autoplay = false;
alertAudio.loop = false;

interface StateFromReducer {
    kills: number|null;
    gameOverPlace: number;
    gameOverIsWin: boolean;
    gameOverEnabled: boolean;
}

type Props = StateFromReducer;

const Gameover: React.FC<Props> = ({ kills, gameOverIsWin, gameOverPlace, gameOverEnabled }) => {
    const dispatch = useDispatch();

    let interval: any = null;
    useEffect(() => {
        if (gameOverEnabled) {
            alertAudio.play();

            interval = setInterval(() => {
                onEnd();
            }, 10000);

            return () => {
                onEnd();
            }
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [gameOverEnabled]);

    const onEnd = () => {
        alertAudio.currentTime = 0.0;
        alertAudio.pause();

        dispatch(updateGameover(false));

        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (
        <>
            {gameOverEnabled &&
                <div id="Gameover">
                    <span className="WonOrLost">
                        {gameOverIsWin ?
                            <span className="won">You Won</span>
                        :
                            <span className="lost">You Lost</span>
                        }
                    </span>
                    {/*<span className="Name">
                        {localPlayer.name??''}
                    </span>*/}
                    <span className="Rank">
                        Your place: <span>#{gameOverPlace??99}</span>
                    </span>
                    <span className="Kills">
                        Your Kills: <span>{kills??''}</span>
                    </span>
                </div>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // PlayerReducer
        kills: state.PlayerReducer.player.kill,
        // GameReducer
        gameOverEnabled: state.GameReducer.gameOver.enabled,
        gameOverPlace: state.GameReducer.gameOver.place,
        gameOverIsWin: state.GameReducer.gameOver.win,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Gameover);
