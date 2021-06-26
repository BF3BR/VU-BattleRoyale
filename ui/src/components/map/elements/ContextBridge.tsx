import React from "react";

const ContextBridge = ({render, Context, children}: any) => {
    return (
        <Context.Consumer>
            {(value: any) =>
                render(<Context.Provider value={value}>{children}</Context.Provider>)
            }
        </Context.Consumer>
    );
};

export default ContextBridge;
