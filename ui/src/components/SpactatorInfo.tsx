import React from "react";

import "./SpactatorInfo.scss";

interface Props {
    spectating: boolean;
    spectatorTarget: string;
}

const SpactatorInfo: React.FC<Props> = ({ spectating, spectatorTarget }) => {

    return (
        <>
            <div id="SpactatorInfo" className={spectating ? 'show' : ''}>
                <span className="SpactatorText">
                    Spectating:
                </span>
                <span className="SpactatorTarget">
                    {spectatorTarget??''}
                </span>
            </div>
            
        </>
    );
};

export default SpactatorInfo;
