import React from "react";
import { connect } from "react-redux";
import { Oval } from "svg-loaders-react";
import { Fade } from "react-slideshow-image";

import { RootState } from "../store/RootReducer";

import "./LoadingScreen.scss";

interface StateFromReducer {
    levelName: string;
}

type Props = StateFromReducer;

const host = "https://cdn.jsdelivr.net/gh/BF3BR/VU-BattleRoyale-Loading-Images@main/";
const list = ["01", "02", "03", "04"];

const LoadingScreen: React.FC<Props> = ({ levelName }) => {
    const getName = () => {
        switch (levelName) {
            case "Levels/XP5_003/XP5_003":
            default:
                return "Kiasar Railroad";
        }
    }

    const getShortName = () => {
        if (levelName === "") {
            return "XP5_003";
        }

        const words = levelName.split("/");
        return words[words.length - 1];
    }

    return (
        <div id="LoadingScreen">
            <div className="bgWrapper">
                <Fade 
                    arrows={false}
                    pauseOnHover={false}
                    canSwipe={false}
                    autoplay={true}
                    defaultIndex={(Math.floor(Math.random() * 3))}
                >
                    {list.sort(() => Math.random() - 0.5).map((pic: string, index: number) => (
                        <div className="slideItem" key={index}>
                            <img 
                                src={host + getShortName() + "/" + pic + ".jpg"} 
                                alt="" 
                                onError={(e: any) => {e.target.onerror = null; e.target.src = "img/default.jpg"}} 
                                onLoad={(e: any) => {e.target.style = {opacity: 1}}} 
                                style={{opacity: 0}} 
                            />
                        </div>
                    ))}
                </Fade>
            </div>
            <div className="loader">
                <Oval />
            </div>
            <div className="bgOverlay" />
            <div className="LoadingBox">
                <h1 className="PageTitle">
                    Battle Royale
                </h1>
                <br/>
                <h3 className="ModeType">
                    {getName()}
                </h3>

                <div className="card ObjectiveBox">
                    <div className="card-header">
                        <h1>Objective</h1>
                    </div>
                    <div className="card-content">
                        <ul>
                            <li>Find the best gear available</li>
                            <li>Always move inside the circle</li>
                            <li>Be the last survivor</li>
                        </ul>
                    </div>
                </div>
                <div className="card TipsBox">
                    <div className="card-header">
                        <h1>Tips / Tricks</h1>
                    </div>
                    <div className="card-content">
                        <ul>
                            <li>Press <b>TAB</b> to open/close your inventory</li>
                            <li>Press <b>M</b> to open/close and <b>N</b> to zoom the map</li>
                            <li>Press or Hold <b>Q</b> to ping for your teammates</li>
                            <li>You can find more loot near buildings</li>
                            <li>Watch out for airdrops</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // GameReducer
        levelName: state.GameReducer.levelName,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(LoadingScreen);
