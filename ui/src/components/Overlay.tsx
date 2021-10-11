import React from "react";

import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import LootOverlay from "./LootOverlay";

interface StateFromReducer {
    overlayLoot: any
}

type Props = StateFromReducer;

const Overlay: React.FC<Props> = ({
    overlayLoot
}) => {
    return (
        <>
            {overlayLoot !== null &&
                <LootOverlay 
                    loot={overlayLoot}
                />
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // InventoryReducer
        overlayLoot: state.InventoryReducer.overlayLoot,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Overlay);
