import { InventoryState } from "./Types";
import InventorySlot from "../../helpers/InventoryHelper";
import { 
    InventoryActionTypes,
    UPDATE_INVENTORY
} from "./ActionTypes";

const initialState: InventoryState = {
    primaryWeapon: {
        weaponSlot: {
            id: "primary-weapon-slot",
            item: null,
            accepts: ["weapon"],
        },
        attachmentSlot1: {
            id: "primary-attachment-slot-1",
            item: null,
            accepts: ["attachment"],
        },
        attachmentSlot2: {
            id: "primary-attachment-slot-2",
            item: null,
            accepts: ["attachment"],
        },
        attachmentSlot3: {
            id: "primary-attachment-slot-3",
            item: null,
            accepts: ["attachment"],
        },
    },
    secondaryWeapon: {
        weaponSlot: {
            id: "secondary-weapon-slot",
            item: null,
            accepts: ["weapon"],
        },
        attachmentSlot1: {
            id: "secondary-attachment-slot-1",
            item: null,
            accepts: ["attachment"],
        },
        attachmentSlot2: {
            id: "secondary-attachment-slot-2",
            item: null,
            accepts: ["attachment"],
        },
        attachmentSlot3: {
            id: "secondary-attachment-slot-3",
            item: null,
            accepts: ["attachment"],
        },
    },
    backpack: [
        {
            id: "backpack-slot-1",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "backpack-slot-2",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "backpack-slot-3",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "backpack-slot-4",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "backpack-slot-5",
            item: null,
            /*{
                id: "dummy-attachment",
                name: "Attachment test",
                count: 1,
                type: "attachment",
            },*/
            accepts: ["attachment", "backpack"],
        },
    ],
    ammo: [
        {
            id: "ammo-slot-1",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "ammo-slot-2",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "ammo-slot-3",
            item: null,
            accepts: ["attachment", "backpack"],
        },
        {
            id: "ammo-slot-4",
            item: null,
            accepts: ["attachment", "backpack"],
        },
    ],
};

const InventoryReducer = (
    state = initialState,
    action: InventoryActionTypes
): InventoryState => {
    switch (action.type) {
        case UPDATE_INVENTORY:
            return {
                ...state,
                //players: action.payload.players,
            };
        default:
            return state;
    }
};

export default InventoryReducer;
