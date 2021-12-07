import React from "react";
import { PlaySound, Sounds } from "../helpers/SoundHelper";

import "./Modal.scss";

interface Props {
    show: boolean;
    title: string;
    text: any;
    buttons: null|Array<{ text: string, handler: () => void }>;
    dismiss: () => void;
    highlightedButtonIndex: number;
}

const Modal: React.FC<Props> = ({ show, title, text, buttons, dismiss, highlightedButtonIndex }) => {
    return (
        <>
            {show &&
                <>
                    <div className="modal">
                        <div className="modal-header">
                            {title??""}
                        </div>
                        <div className="modal-body">
                            {text??""}

                            {buttons &&
                                <div className="buttons">
                                    {buttons.map((button: any, key: number) => (
                                        <button 
                                            key={key}
                                            onClick={() => {
                                                PlaySound(Sounds.Click);
                                                button.handler();
                                            }}
                                            className={"btn" + (highlightedButtonIndex === key ? " active" : "")}
                                            onMouseEnter={() => {
                                                PlaySound(Sounds.Navigate);
                                            }}
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
