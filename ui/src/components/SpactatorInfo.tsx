import React from "react";

import "./SpactatorInfo.scss";

interface Props {
    spectating: boolean;
    spectatorTarget: string;
}

const SpactatorInfo: React.FC<Props> = ({ spectating, spectatorTarget }) => {

    return (
        <>
            <div id="SpactatorInfo" className={"card " + (spectating ? 'show' : '')}>
                <div className="card-header">
                    <h1>
                        Spectating
                        <span>
                            {spectatorTarget??''}
                        </span>
                    </h1>
                </div>
            </div>
            
        </>
    );
};

export default SpactatorInfo;
