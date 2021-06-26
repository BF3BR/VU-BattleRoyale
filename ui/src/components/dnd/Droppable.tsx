import React from 'react';
import { useDroppable } from '@dnd-kit/core';
import Draggable from './Draggable';

import skull from "../../assets/img/skull.svg";

export function Droppable(props: any) {
    const disabled = props.item === undefined && props.id !== "item-drop";
    const {isOver, setNodeRef, active} = useDroppable({
        id: props.id,
        data: {
            accepts: props.accepts,
            item: props.item,
        },
        //disabled: disabled,
    });
        
    const style = {
        //background: active ? 'green' : 'red',
    };

    return (
        <div ref={setNodeRef} style={style} className="item-slot">
            {props.item ?
                <Draggable id={props.item.id} type={props.item.type}>
                    <img src={skull} />
                    {props.item.count &&
                        <span>{props.item.count??0}</span>
                    }
                </Draggable>
            :
                "Empty"
            }
        </div>
    );
}

export default Droppable;
