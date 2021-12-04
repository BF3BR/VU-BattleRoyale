import React, { useEffect } from "react";
import { connect, useDispatch } from "react-redux";
import { RootState } from "../store/RootReducer";
import { updateGameover } from "../store/game/Actions";

import { PlaySound, Sounds } from "../helpers/SoundHelper";

import ending from "../assets/vid/ending.webm";
import flare from "../assets/img/flare.png"
import flare2 from "../assets/img/flare2.png"

import "./Gameover.scss";

interface StateFromReducer {
    kills: number|null;
    gameOverPlace: number;
    gameOverIsWin: boolean;
    gameOverEnabled: boolean;
    gameOverTeam: any;
}

type Props = StateFromReducer;

const Gameover: React.FC<Props> = ({ kills, gameOverIsWin, gameOverPlace, gameOverEnabled, gameOverTeam }) => {
    const dispatch = useDispatch();

    let interval: any = null;
    useEffect(() => {
        if (gameOverEnabled) {
            if (gameOverIsWin) {
                PlaySound(Sounds.GameoverWinner);
            } else {
                PlaySound(Sounds.GameoverLoser);
            }

            interval = setInterval(() => {
                onEnd();
            }, 18000);

            return () => {
                onEnd();
            }
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [gameOverEnabled]);

    const onEnd = () => {
        dispatch(updateGameover(false));

        if (interval !== null) {
            clearInterval(interval);
        }
    }

    return (
        <>
            {gameOverEnabled &&
                <div id="Gameover" className={gameOverIsWin ? "Winner" : ""}>
                    {gameOverIsWin ? 
                        <>
                            <video id="VictoryVideo" autoPlay muted>
                                <source src={ending} type="video/mp4" />
                            </video>
                            <span className="Victory">
                                <span>Victory</span>
                                <img className="flare" src={flare} alt="" />
                                <img className="flare2" src={flare2} alt="" />
                            </span>
                        </>
                    :
                        <span className="WonOrLost">
                            {gameOverIsWin ?
                                <span className="won">You Won</span>
                            :
                                <span className="lost">You Lost</span>
                            }
                        </span>
                    }
                    <div className="inner">
                        <span className="Rank">
                            Your place: <span>#{gameOverPlace??99}</span>
                        </span>
                        <span className="Kills">
                            Your Kills: <span>{kills??''}</span>
                        </span>
                    </div>
                    <span className="Team">
                        {(gameOverTeam !== undefined && gameOverTeam.length > 0) &&
                            <>
                                Winner{gameOverTeam.length > 1 ? "s" : ""}:<br/>
                                {gameOverTeam.map((player: any, index: number) => (
                                    <b key={index}>
                                        {player.Name??""}
                                    </b>
                                ))}
                            </>
                        }
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
        gameOverTeam: state.GameReducer.gameOver.team,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Gameover);
