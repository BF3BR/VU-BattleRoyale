import React from "react";
import { Oval } from 'svg-loaders-react';

import XP5_003 from "../assets/img/loading/XP5_003.jpg";

import "./LoadingScreen.scss";

const LoadingScreen: React.FC = () => {
    return (
        <div id="LoadingScreen">
            <div className="LoadingBox">
                <h1 className="PageTitle">Kiasar Railroad</h1>
                <br/>
                <h3 className="ModeType">Battle Royale</h3>

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
                            <li>Press <b>M</b> to open/close and <b>N</b> to zoom the map</li>
                            <li>Press <b>TAB</b> to enable mouse on the map</li>
                            <li>Press <b>Q</b> to ping for your teammates</li>
                            <li>You can find more loot near buildings</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div className="bgOverlay" />
            <div className="bgWrapper">
                <img src={XP5_003} />
            </div>
            <div className="loader">
                <Oval />
            </div>
        </div>
    );
};

export default LoadingScreen;
