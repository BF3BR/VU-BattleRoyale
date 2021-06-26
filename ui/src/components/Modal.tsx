import React from "react";

import "./Modal.scss";

interface Props {
    show: boolean;
    title: string;
    text: string;
    buttons: null|Array<{ text: string, handler: () => void }>;
    dismiss: () => void,
}

const Modal: React.FC<Props> = ({ show, title, text, buttons, dismiss }) => {
    return (
        <>
            {show &&
                <>
                    <div className="modal">
                        <div className="modal-header">
                            {title??""}
                        </div>
                        <div className="modal-body">
                            <p>
                                {text??""}
                            </p>

                            {buttons &&
                                <div className="buttons">
                                    {buttons.map((button: any, key: number) => (
                                        <button 
                                            key={key}
                                            onClick={button.handler}
                                            className="btn"
                                        >
                                            {button.text??""}
                                        </button>
                                    ))}
                                </div>
                            }
                        </div>
                    </div>
                    <div className="modal-backdrop" onClick={dismiss}></div>
                </>
            }
        </>
    );
};

export default Modal;
