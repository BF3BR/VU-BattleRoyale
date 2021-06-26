import React, { useState } from "react";


import { connect } from "react-redux";
import { RootState } from "../store/RootReducer";

import { DndContext } from '@dnd-kit/core';
import { Draggable } from './dnd/Draggable';
import { Droppable } from './dnd/Droppable';

import InventorySlot, { InventoryItem } from "../helpers/InventoryHelper";
import Player from "../helpers/PlayerHelper";

import skull from "../assets/img/skull.svg";
import dummyweapon from "../assets/img/dummyweapon.png";

import "./Inventory.scss";

interface StateFromReducer {
    primaryWeapon: {
        weaponSlot: InventorySlot,
        attachmentSlot1: InventorySlot,
        attachmentSlot2: InventorySlot,
        attachmentSlot3: InventorySlot,
    },
    secondaryWeapon: {
        weaponSlot: InventorySlot,
        attachmentSlot1: InventorySlot,
        attachmentSlot2: InventorySlot,
        attachmentSlot3: InventorySlot,
    },
    backpack: Array<InventorySlot>,
    ammo: Array<InventorySlot>,
}

type Props = StateFromReducer;

const Inventory: React.FC<Props> = ({
    ammo,
    backpack,
    primaryWeapon,
    secondaryWeapon
}) => {
    //const [parent, setParent] = useState(null);

    function handleDragEnd(event: any) {
        const { active, over } = event;

        console.log(over);
        
        if (over && 
            (over.data.current.accepts !== undefined && over.data.current.accepts.includes(active.data.current.type)) && 
            (over.data.current.item === undefined || over.data.current.item?.id !== active.id)
        ) {
            alert("ok");
        }
    }

    return (
        <>
            <DndContext onDragEnd={handleDragEnd}>
                <div id="Inventory" className="open">
                    <div className="InventoryWrapper">
                        <div className="card PrimaryWeaponBox">
                            <div className="card-header">
                                <h1>
                                    Primary Weapon
                                </h1>
                            </div>
                            <div className="card-content weapon-grid">
                                <div className="weapon-holder tier3">
                                    <img src={dummyweapon} />
                                    <span className="name">Scar-H</span>
                                    <span className="ammoType ammo556mm">5.56mm</span>
                                </div>
                                <Droppable id={"primary-attachment-slot-1"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                                <Droppable id={"primary-attachment-slot-2"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                                <Droppable id={"primary-attachment-slot-3"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                            </div>
                        </div>

                        <div className="card SecondaryWeaponBox">
                            <div className="card-header">
                                <h1>
                                    Secondary Weapon
                                </h1>
                            </div>
                            <div className="card-content weapon-grid">
                                <div className="weapon-holder tier2">
                                    <img src={dummyweapon} />
                                    <span className="name">Scar-H</span>
                                    <span className="ammoType ammo9mm">9mm</span>
                                </div>
                                <Droppable id={"secondary-attachment-slot-1"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                                <Droppable id={"secondary-attachment-slot-2"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                                <Droppable id={"secondary-attachment-slot-3"} accepts={["attachment"]}>
                                    {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                </Droppable>
                            </div>
                        </div>

                        <div className="gear-grid">
                            <div className="card">
                                <div className="card-header">
                                    <h1>
                                        Helmet
                                    </h1>
                                </div>
                                <div className="card-content">
                                    <Droppable id={"helmet-holder"}>
                                        {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                    </Droppable>
                                </div>
                            </div>
                            <div className="card">
                                <div className="card-header">
                                    <h1>
                                        Armor
                                    </h1>
                                </div>
                                <div className="card-content">
                                    <Droppable id={"armor-holder"}>
                                        {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                    </Droppable>
                                </div>
                            </div>
                            <div className="card">
                                <div className="card-header">
                                    <h1>
                                        Gadget
                                    </h1>
                                </div>
                                <div className="card-content">
                                    <Droppable id={"gadget-holder"}>
                                        {/*parent === "attachment-holder" ? draggableMarkup : 'Empty'*/}
                                    </Droppable>
                                </div>
                            </div>
                        </div>

                        <div className="card BackpackBox">
                            <div className="card-header">
                                <h1>
                                    Backpack
                                </h1>
                            </div>
                            <div className="card-content backpack-grid">
                                {/*<div className="item-holder">
                                    <img src={skull} />
                                    <span className="count">60</span>
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                    <span className="count">120</span>
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>
                                <div className="item-holder">
                                    <img src={skull} />
                                </div>*/}
                                {/*parent === null ? draggableMarkup : null*/}

                                {backpack.map((inventorySlot: InventorySlot) => (
                                    <Droppable 
                                        key={inventorySlot.id} 
                                        id={inventorySlot.id}
                                        accepts={inventorySlot.accepts}
                                        item={inventorySlot.item}
                                    >
                                        {/*inventorySlot.item ? draggableItem(inventorySlot.item) : 'Empty'*/}
                                    </Droppable>
                                ))}
                            </div>
                        </div>

                        <div className="card AmmoBox">
                            <div className="card-header">
                                <h1>
                                    Ammo
                                </h1>
                            </div>
                            <div className="card-content ammo-grid">
                                {ammo.map((inventorySlot: InventorySlot) => (
                                    <Droppable 
                                        key={inventorySlot.id} 
                                        id={inventorySlot.id}
                                        accepts={inventorySlot.accepts}
                                        item={inventorySlot.item}
                                    >
                                        
                                    </Droppable>
                                ))}
                            </div>
                        </div>
                    </div>
                    <div className="itemDrop">
                        <Droppable id="item-drop" accepts={["weapon", "attachment", "backpack"]}></Droppable>
                    </div>
                </div>
            </DndContext>
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // InventoryReducer
        backpack: state.InventoryReducer.backpack,
        primaryWeapon: state.InventoryReducer.primaryWeapon,
        secondaryWeapon: state.InventoryReducer.secondaryWeapon,
        ammo: state.InventoryReducer.ammo,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Inventory);
