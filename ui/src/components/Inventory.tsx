import React, { useEffect, useState } from "react";

import { connect, useDispatch } from "react-redux";
import { RootState } from "../store/RootReducer";

import {
    DndContext,
    DragOverlay,
    LayoutMeasuringStrategy,
    PointerSensor,
    useSensor
} from '@dnd-kit/core';
import { Draggable } from './dnd/Draggable';
import { Droppable } from './dnd/Droppable';

import InventoryTooltip from "./tooltip/InventoryTooltip";

import { sendToLua } from "../Helpers";
import { updateProgress } from "../store/inventory/Actions";

import "./Inventory.scss";

interface StateFromReducer {
    slots: any;
    closeItems: any;
    isCtrlDown: boolean;
}

type Props = StateFromReducer & {
    isOpen: boolean;
};

const Inventory: React.FC<Props> = ({
    slots,
    closeItems,
    isOpen,
    isCtrlDown,
}) => {
    const dispatch = useDispatch();
    const sensors = [
        useSensor(PointerSensor, {
            activationConstraint: {
                distance: 2,
            },
        })
    ];

    const [clickedSlot, setClickedSlot] = useState<any>(null);
    useEffect(() => {
        const timer = setTimeout(() => {
            setClickedSlot(null);
        }, 300);

        if (clickedSlot !== null) {
            if (clickedSlot.TimeToApply !== undefined) {
                handleUseItem(clickedSlot.Id);
                dispatch(updateProgress(clickedSlot, clickedSlot.TimeToApply));
                setClickedSlot(null);
            }
        }

        return () => clearTimeout(timer);
    }, [clickedSlot]);

    useEffect(() => {
        setIsDragging(null);
    }, [isOpen]);

    const [splitModal, setSplitModal] = useState({
        id: null,
        show: false,
        maxQuantity: 60,
        value: 30,
    });
    const [isDragging, setIsDragging] = useState<any>(null);

    function handleDragStart(event: any) {
        const { active } = event;
        setIsDragging(active.data.current);
    }

    function handleDragEnd(event: any) {
        const { active, over } = event;
        setIsDragging(null);

        if (over !== null) {
            const slot = over.id;
            if (active.data.current.currentSlot === undefined && active.data.current.lootId !== null) {
                // When you pick up from a loot box
                sendToLua('WebUI:PickupItem', JSON.stringify({ 
                    item: active.id.replace('loot-',''), 
                    slot: slot,
                    lootPickup: active.data.current.lootId,
                }));
                return;
            } else if (active.data.current.currentSlot.toString() !== slot) {
                if (slot === "item-drop") {
                    if (isCtrlDown) {
                        // Split drop
                        if (slots[active.data.current.currentSlot].Quantity > 1) {
                            setSplitModal({
                                id: active.id,
                                show: true,
                                maxQuantity: slots[active.data.current.currentSlot].Quantity,
                                value: Math.floor(slots[active.data.current.currentSlot].Quantity / 2),
                            });
                        } else {
                            sendToLua('WebUI:DropItem', JSON.stringify({ item: active.id, quantity: slots[active.data.current.currentSlot].Quantity }));
                        }
                    } else {
                        // Normal drop
                        sendToLua('WebUI:DropItem', JSON.stringify({ item: active.id, quantity: slots[active.data.current.currentSlot].Quantity }));
                    }
                } else {
                    sendToLua('WebUI:MoveItem', JSON.stringify({ item: active.id, slot: slot }));
                }
            }
        }
    }

    const handleChange = (event: any) => {
        setSplitModal(prevState => ({
            id: prevState.id,
            show: prevState.show,
            maxQuantity: prevState.maxQuantity,
            value: event.target.value,
        }));
    }

    const handleRightClick = (slot: any, pickup?: boolean) => {
        if (pickup) {
            sendToLua('WebUI:PickupItem', JSON.stringify({ 
                item: slot.Id, 
                slot: "",
                lootPickup: slot.lootId,
            }));
            return;
        }

        if (isCtrlDown) {
            setSplitModal({
                id: slot.Id,
                show: true,
                maxQuantity: slot.Quantity,
                value: Math.floor(slot.Quantity / 2),
            });
        } else {
            sendToLua('WebUI:DropItem', JSON.stringify({ item: slot.Id, quantity: slot.Quantity }));
        }
    }

    const handleUseItem = (id: string) => {
        if (id !== undefined) {
            sendToLua('WebUI:UseItem', JSON.stringify({ id: id }));
        }
    }

    const getSlotItem = (slot: any, key: number) => {
        if (slot === undefined || slot === null || Object.keys(slot).length === 0) {
            return <>
                {getEmptySlot(key)}
            </>
        }

        return (
            <Draggable id={slot.Id} item={slot} currentSlot={key}>
                {getSlotDrag(slot)}
            </Draggable>
        )
    }

    const getSlotDrag = (slot: any, right?: boolean, pickup?: boolean) => {
        return (
            <div 
                className={(slot.Tier !== undefined ? "tier-" + slot.Tier : "")}
                onContextMenu={() => handleRightClick(slot, pickup)}
                onClick={() => {
                    if (!pickup) {
                        setClickedSlot(slot);
                    }
                }}
            >
                <InventoryTooltip
                    content={
                        [
                            <h5>{slot.Name ?? ""}</h5>,
                            <p>{slot.Description ?? ""}</p>,
                        ]
                    }
                    right={right}
                    key={slot.Id}
                >
                    {slot.UIIcon !== null &&
                        <>
                            {slot.UIIcon.startsWith("__") ?
                                <img draggable="false" src={"/img/" + slot.UIIcon + ".png"} alt="" />
                            :
                                <img draggable="false" src={"fb://" + slot.UIIcon} alt="" />
                            }
                        </>
                    }
                    <div className="information">
                        <span className="name">{slot.Name ?? ""}</span>
                        {slot.Quantity > 1 &&
                            <span className="count">x{slot.Quantity ?? 1}</span>
                        }
                        <span className="ammoType">{slot.AmmoName ?? "-"}</span>
                        {(slot.CurrentDurability !== undefined && slot.Durability !== undefined) &&
                            <div className="progressWrapper">
                                <div className="progressWrapperBg">
                                    <div className="progressWrapperFg" style={{ height: (slot.CurrentDurability / slot.Durability * 100) + "%" }}></div>
                                </div>
                            </div>
                        }
                    </div>
                    {slot.Tier !== undefined &&
                        <span className="tier">
                            {slot.Tier === 1 &&
                                <img draggable="false" src="fb://UI/Art/Persistence/Ranks/Rank001" alt="" />
                            }
                            {slot.Tier === 2 &&
                                <img draggable="false" src="fb://UI/Art/Persistence/Ranks/Rank002" alt="" />
                            }
                            {slot.Tier === 3 &&
                                <img draggable="false" src="fb://UI/Art/Persistence/Ranks/Rank003" alt="" />
                            }
                        </span>
                    }
                </InventoryTooltip>
            </div>
        )
    }

    const getEmptySlot = (key: number) => {
        switch (key) {
            case 0:
                return (
                    <div className="empty-slot">
                        Primary Weapon
                    </div>
                );
            case 4:
                return (
                    <div className="empty-slot">
                        Secondary Weapon
                    </div>
                );
            case 1:
            case 5:
                return (
                    <div className="empty-slot">
                        Optics
                    </div>
                );
            case 2:
            case 6:
                return (
                    <div className="empty-slot">
                        Barrel
                    </div>
                );
            case 3:
            case 7:
                return (
                    <div className="empty-slot">
                        Other
                    </div>
                );
            case 8:
                return (
                    <div className="empty-slot">
                        Armor
                    </div>
                );
            case 9:
                return (
                    <div className="empty-slot">
                        Helmet
                    </div>
                );
            case 10:
                return (
                    <div className="empty-slot">
                        Gadget
                    </div>
                );
            default:
                return (
                    <div className="empty-slot">
                        Empty
                    </div>
                );
        }
    }

    return (
        <>
            <div id="SplitBox" className={(splitModal.show ? "show" : "")}>
                <div className="card">
                    <div className="card-header">
                        <h1>Splitting</h1>
                    </div>
                    <div className="card-content">
                        <h1 className="split-val">{splitModal.value??0}</h1>
                        <div className="range-grid">
                            <button 
                                onClick={() => setSplitModal(prevState => ({
                                    id: prevState.id,
                                    show: prevState.show,
                                    maxQuantity: prevState.maxQuantity,
                                    value: 1,
                                }))}
                                className="btn btn-small"
                            >
                                MIN
                            </button>
                            <div>
                                <input 
                                    type="range" 
                                    min={1} 
                                    max={splitModal.maxQuantity} 
                                    value={splitModal.value} 
                                    className="slider" 
                                    id="myRange"
                                    step={1}
                                    onChange={handleChange}
                                />
                            </div>
                            <button 
                                onClick={() => setSplitModal(prevState => ({
                                    id: prevState.id,
                                    show: prevState.show,
                                    maxQuantity: prevState.maxQuantity,
                                    value: splitModal.maxQuantity,
                                }))}
                                className="btn btn-small"
                            >
                                MAX
                            </button>
                        </div>
                        <div className="button-grid">
                            <button 
                                onClick={() => setSplitModal(prevState => ({
                                    id: null,
                                    show: false,
                                    maxQuantity: prevState.maxQuantity,
                                    value: prevState.value,
                                }))}
                                className="btn"
                            >
                                Cancel
                            </button>
                            <button 
                                onClick={() => {
                                    setSplitModal(prevState => ({
                                        id: null,
                                        show: false,
                                        maxQuantity: prevState.maxQuantity,
                                        value: prevState.value,
                                    }));
                                    sendToLua('WebUI:DropItem', JSON.stringify({ item: splitModal.id, quantity: splitModal.value }));
                                }}
                                className="btn btn-primary"
                            >
                                Drop
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            <DndContext
                layoutMeasuring={{ strategy: LayoutMeasuringStrategy.Always }}
                onDragEnd={handleDragEnd}
                onDragStart={handleDragStart}
                sensors={sensors}
            >
                <div id="Inventory" className={isOpen ? "open" : ""}>
                    <div className="inventory-details">
                        <div className="detail">
                            <span className="keyboard">RIGHT CLICK</span>
                            DROP ITEM
                        </div>
                        <div className="detail">
                            <span className="keyboard">LEFT CLICK</span>
                            USE ITEM
                        </div>
                        <div className="detail">
                            <span className="keyboard">CTRL</span>
                            SPLIT ITEMS
                        </div>
                        <div className="detail">
                            <span className="keyboard">MOUSE</span>
                            MOVE ITEM
                        </div>
                    </div>
                    <div className="InventoryWrapper">
                        <div className="card PrimaryWeaponBox">
                            <div className="card-header">
                                <h1>
                                    Primary Weapon
                                </h1>
                            </div>
                            <div className="card-content weapon-grid">
                                <Droppable id={0} type="weapon-slot">
                                    {getSlotItem(slots[0], 0)}
                                </Droppable>
                                <Droppable id={1}>
                                    {getSlotItem(slots[1], 1)}
                                </Droppable>
                                <Droppable id={2}>
                                    {getSlotItem(slots[2], 2)}
                                </Droppable>
                                <Droppable id={3}>
                                    {getSlotItem(slots[3], 3)}
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
                                <Droppable id={4} type="weapon-slot">
                                    {getSlotItem(slots[4], 4)}
                                </Droppable>
                                <Droppable id={5}>
                                    {getSlotItem(slots[5], 5)}
                                </Droppable>
                                <Droppable id={6}>
                                    {getSlotItem(slots[6], 6)}
                                </Droppable>
                                <Droppable id={7}>
                                    {getSlotItem(slots[7], 7)}
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
                                    <Droppable id={9}>
                                        {getSlotItem(slots[9], 9)}
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
                                    <Droppable id={8}>
                                        {getSlotItem(slots[8], 8)}
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
                                    <Droppable id={10}>
                                        {getSlotItem(slots[10], 10)}
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
                                {slots.map((slot: any, key: number) => (
                                    <React.Fragment key={key}>
                                        {key >= 11 &&
                                            <Droppable key={key} id={key}>
                                                {getSlotItem(slots[key], key)}
                                            </Droppable>
                                        }
                                    </React.Fragment>
                                ))}
                            </div>
                        </div>
                    </div>
                    <div className={"itemDrop " + (closeItems.length === 0 ? "noCloseItem" : "")}>
                        {(isDragging !== null && isDragging.currentSlot !== undefined) &&
                            <Droppable id="item-drop" isCtrlDown={isCtrlDown} />
                        }
                    </div>
                    {closeItems.length > 0 &&
                        <div className="ProximityWrapper">
                            <div className="card proximity-card">
                                <div className="card-header">
                                    <h1>
                                        Near you
                                    </h1>
                                </div>
                                <div className="card-content">
                                    {closeItems.map((item: any, key: number) => (
                                        <div className="item-slot" key={key}>
                                            <Draggable id={"loot-" + item.Id} item={item} lootId={item.lootId}>
                                                {getSlotDrag(item, true, true)}
                                            </Draggable>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        </div>
                    }
                </div>
                <DragOverlay 
                    dropAnimation={null}
                    adjustScale={false}
                    style={{
                        background: "red",
                    }}
                >
                    {isDragging !== null && 
                        <div className="dragoverlay-object">
                            {getSlotDrag(isDragging.item)}
                        </div>
                    }
                </DragOverlay>
            </DndContext>
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // InventoryReducer
        slots: state.InventoryReducer.slots,
        closeItems: state.InventoryReducer.closeItems,
        // PlayerReducer
        isCtrlDown: state.PlayerReducer.isCtrlDown,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Inventory);
