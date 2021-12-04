import React from 'react';
import { useDraggable } from '@dnd-kit/core';

export function Draggable(props: any) {
    const { attributes, listeners, setNodeRef } = useDraggable({
        id: props.id,
        data: {
            currentSlot: props.currentSlot,
            item: props.item,
            lootId: props.lootId??null,
        },
    });
    
    return (
        <button ref={setNodeRef} {...listeners} {...attributes} className="draggable">
            {props.children}
        </button>
    );
}

export default Draggable;
