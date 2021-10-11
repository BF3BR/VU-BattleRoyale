import React from "react";
import { Tooltip } from "react-lightweight-tooltip";

const InventoryTooltip: React.FC<any> = ({ children, content, right }) => {
    return (
        <Tooltip
            content={content}
            styles={{
                wrapper: {
                    position: 'relative' as 'relative',
                    display: "flex",
                    zIndex: 98,
                    width: "100%",
                    margin: "0",
                },
                tooltip: {
                    background: "#000",
                    position: 'absolute' as 'absolute',
                    zIndex: 99,
                    top: "0",
                    bottom: "auto",
                    left: right ? 'calc(100% + 0.5vw)' : '-12.5vw',
                    marginBottom: '0',
                    padding: '1vw',
                    textAlign: "left",
                    transform: "none",
                    minWidth: "10vw",
                    maxWidth: "10vw",
                    pointerEvents: "none",
                },
                content: {
                    background: "transparent",
                    color: '#fff',
                    fontSize: '.85vw',
                    textAlign: "left",
                    display: "flex",
                    flexFlow: "column",
                    padding: "0",
                },
                arrow: {
                    position: 'absolute' as 'absolute',
                    width: '0',
                    height: '0',
                    bottom: 'auto',
                    top: '1vw',
                    left: right ? '0' : 'auto',
                    right: right ? 'auto' : '-1vw',
                    marginLeft: right ? '-1vw' : '0',
                    borderLeft: right ? 'solid transparent .5vw' : '0.5vw solid rgb(0, 0, 0)',
                    borderRight: right ? '0.5vw solid rgb(0, 0, 0)' : 'solid transparent .5vw',
                    borderTop: 'solid transparent .5vw',
                    borderBottom: 'solid transparent .5vw',
                },
                gap: {
                    display: "none",
                },
            }}
        >
            {children}
        </Tooltip>
    );
}

export default InventoryTooltip;
