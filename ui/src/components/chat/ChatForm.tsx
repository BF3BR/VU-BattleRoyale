import React, { useEffect, useRef, useState } from "react";
import { sendToLua } from "../../Helpers";

import { MessageTarget, MessageTargetString } from "../../helpers/chat/MessageTarget";

import './ChatForm.scss';

interface Props {
    target: MessageTarget;
    isTypingActive: boolean;
    doneTypeing: () => void;
}

const Title: React.FC<Props> = ({ target, isTypingActive, doneTypeing }) => {
    const [inputMessage, setInputMessage] = useState<string>('');

    const onChange = (event: any) => {
        setInputMessage(event.target.value);
    }

    const onKeyDown = (event: any) => {
        switch (event.key) {
            case 'Enter':
                onSubmit(event);
                break;
            case 'Escape':
                resetInputMessage();
                resetKeyboardAndMouse();
                sendToLua('WebUI:OutgoingChatMessage', JSON.stringify({ message: null, target: null }));
                break;
            case 'ArrowUp':
                event.preventDefault();
                break;
            case 'ArrowDown':
                event.preventDefault();
                break;
        }
    }

    const onBlur = () => {
        setTimeout(() => {
            resetInputMessage();
            resetKeyboardAndMouse();
            sendToLua('WebUI:OutgoingChatMessage', JSON.stringify({ message: null, target: null }));
        }, 100);
    }

    const onSubmit = (event: any) => {
        event.preventDefault();

        if (inputMessage.length > 0) {
            sendToLua('WebUI:OutgoingChatMessage', JSON.stringify({ message: inputMessage, target: target }));
        } else {
            sendToLua('WebUI:OutgoingChatMessage', JSON.stringify({ message: null, target: null }));
        }

        resetInputMessage();
        resetKeyboardAndMouse();
    }

    const resetInputMessage = () => {
        setInputMessage('');
    }

    const resetKeyboardAndMouse = () => {
        doneTypeing();
    }

    const inputEl = useRef(null);
    useEffect(() => {
        if (isTypingActive && inputEl && inputEl.current) {
            inputEl.current.focus();
        }
    }, [isTypingActive]);

    return (
        <>
            {isTypingActive &&
                <div id="chatForm" className={MessageTargetString[target]??''}>
                    <label>
                        {MessageTargetString[target]??''}
                    </label>
                    <input 
                        type="text" 
                        maxLength={127}
                        value={inputMessage} 
                        onKeyDown={onKeyDown} 
                        onBlur={onBlur} 
                        onChange={onChange}
                        spellCheck={false}
                        ref={inputEl}
                    />
                </div>
            }
        </>
    );
};

export default Title;
