import React from "react";

import "./Inventory.scss";

interface Props {
    mapOpen: boolean;
    playerInventory: string[];
}

const Inventory: React.FC<Props> = ({ mapOpen, playerInventory }) => {

    return (
        <>
            <div id="Inventory" className={mapOpen?'open':''}>
                <img src="fb://UI/Art/Persistence/Weapons/knife" alt="knife" className="small" />
                <img src="fb://UI/Art/Persistence/Weapons/m9" alt="m9" className="active" />
                <img src="fb://UI/Art/Persistence/Weapons/A91" alt="A91" />
            </div>
            
        </>
    );
};

export default Inventory;
