import React from 'react';
import { useDroppable } from '@dnd-kit/core';

export function Droppable(props: any) {
    const { setNodeRef, isOver, active } = useDroppable({
        id: props.id.toString(),
    });

    return (
        <div ref={setNodeRef} className={"item-slot " + (props?.type !== undefined ? props.type : "") + " " + (isOver ? "isOver" : "")}>
            {props.children??""}
            {active &&
                <>
                    {props.id === "item-drop" &&
                        <span className="overlay-placeholder">Item drop</span>
                    }
                    {props.id === "item-drop-split" &&
                        <span className="overlay-placeholder">Item split</span>
                    }
                </>
            }
        </div>
    );
}

export default Droppable;
