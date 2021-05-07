import React, { useEffect, useRef, useState } from "react";

import ChatForm from "./ChatForm";
import ChatStatePopup from "./ChatStatePopup";

import { MessageTarget, MessageTargetString } from "../../helpers/chat/MessageTarget";
import Message from "../../helpers/chat/Message";
import ChatState from "../../helpers/chat/ChatState";

import './Chat.scss';
import { sendToLua } from "../../Helpers";
import { RootState } from "../../store/RootReducer";
import { connect } from "react-redux";

interface StateFromReducer {
    uiState: "hidden" | "loading" | "game" | "menu";
    deployScreen: boolean;
}

type Props = StateFromReducer;

const Chat: React.FC<Props> = ({ uiState, deployScreen }) => {
    /*
    * Debug
    */
    let debugMode: boolean = false;
    if (!navigator.userAgent.includes('VeniceUnleashed')) {
        if (window.location.ancestorOrigins === undefined || window.location.ancestorOrigins[0] !== 'webui://main') {
            debugMode = true;
        }
    }

    const [hasMouse, setHasMouse] = useState<boolean>(false);

    const [messages, setMessage] = useState<Message[]>([]);
    const [showChat, setShowChat] = useState<boolean>(false);
    const [chatState, setChatState] = useState<ChatState>(ChatState.Popup);
    const [isTypingActive, setIsTypingActive] = useState<boolean>(false);
    const [chatTarget, setChatTarget] = useState<MessageTarget>(MessageTarget.CctSayAll);

    const setRandomMessages = () => {
        addMessage({
            message: "asdasd dasdasd asd asadsdadsa sdsasaadas  dsa a aad",
            senderName: "asdasddsa",
            messageTarget: MessageTarget.CctSayAll,
            playerRelation: "none",
            targetName: null,
        });
    }

    const addMessage = (message: Message) => {
        if (messages.length >= 50) {
            var prevArr = messages.slice(1, 50);
            prevArr.push(message);
            setMessage(prevArr);
        } else {
            setMessage((prevState: any) => [
                ...prevState,
                message,
            ]);
        }
    }

    const getChatItemClasses = (message: Message) => {
        var classes = "chatItem";

        classes += " chatType" + MessageTargetString[message.messageTarget];

        switch (message.playerRelation) {
            case "localPlayer":
                classes += " chatLocalPlayer";
                break;
            case "squadMate":
                classes += " chatSquadmate";
                break;
            case "spectator":
                classes += " chatSpectator";
                break;
        }

        return classes;
    }

    const getChatItemTarget = (message: Message) => {
        return MessageTargetString[message.messageTarget];
    }

    const messageEl = useRef(null);
    useEffect(() => {
        if (messageEl && messageEl.current && !isTypingActive) {
            scrollToBottom(messageEl.current);
        }
    }, [messages]);

    window.addEventListener('resize', () => {
        if (messageEl && messageEl.current) {
            scrollToBottom(messageEl.current);
        }
    });

    const scrollToBottom = (current: any) => {
        current.scroll({ top: messageEl.current.scrollHeight, behavior: 'auto' });
    };
    
    var interval: any = null;
    useEffect(() => {
        if (!isTypingActive) {
            if (chatState === ChatState.Popup) {
                if (interval !== null) {
                    clearTimeout(interval);
                }
        
                setShowChat(true);
                
                interval = setTimeout(() => {
                    setShowChat(false);
                }, 5000);

                return () => {
                    clearTimeout(interval);
                }
            } else if(chatState === ChatState.Always) {
                setShowChat(true);
            } else {
                setShowChat(false);
            }
        } else {
            clearTimeout(interval);
        }
    }, [messages, chatState, isTypingActive]);

    /* Window */
    window.OnFocus = (p_Target: MessageTarget) => {
        if (navigator.userAgent.includes('VeniceUnleashed')) {
            WebUI.Call('BringToFront');
            WebUI.Call('EnableKeyboard');
            WebUI.Call('EnableMouse');
        }

        setShowChat(true);
        setChatTarget(p_Target);
        setIsTypingActive(true);
        setHasMouse(true);
    }

    window.OnMessage = (p_DataJson: any) => {
        addMessage({
            message: p_DataJson.content.toString(),
            senderName: p_DataJson.author.toString(),
            messageTarget: p_DataJson.target,
            playerRelation: p_DataJson.playerRelation,
            targetName: p_DataJson.targetName,
        });
    }

    window.OnChangeType = () => {
        if (chatState === ChatState.Popup) {
            setChatState(ChatState.Always);
        } else if(chatState === ChatState.Always) {
            setChatState(ChatState.Hidden);
        } else if(chatState === ChatState.Hidden) {
            setChatState(ChatState.Popup);
        }
    }

    window.OnClearChat = () => {
        setMessage([]);
    }

    window.OnCloseChat = () => {
        setCloseChat();
    }

    const setCloseChat = () => {
        sendToLua('WebUI:SetCursor');
        setHasMouse(false);
        setIsTypingActive(false);
    }


    return (
        <>
            {(uiState === "menu" || uiState === "game") &&
                <>
                    <div id="debugChat">
                        <button onClick={() => setRandomMessages()}>Random messages</button>
                        <button onClick={() =>  window.OnFocus(MessageTarget.CctSayAll)}>isTypingActive</button>
                        <button onClick={() =>  window.OnChangeType()}>OnChangeType</button>
                        <button onClick={() =>  window.OnClearChat()}>OnClearChat</button>
                        <button onClick={() =>  window.OnCloseChat()}>OnCloseChat</button>
                    </div>

                    <div id="VuChat" className={(showChat ? "showChat" : "hideChat") + ((isTypingActive || chatState === ChatState.Always) ? " isTypingActive": "") + (hasMouse ? " hasMouse":"") + ((deployScreen || uiState === "menu") ? " isDeploy":"")}>
                        <div className="chatWindow" ref={messageEl}>
                            <div className="chatWindowInner">
                                {messages.map((message: Message, index: number) => (
                                    <div className={getChatItemClasses(message)} key={index}>
                                        <span className="chatMessageTarget">
                                            [{getChatItemTarget(message)}]
                                        </span>
                                        <span className="chatSender">
                                            {message.senderName}:
                                        </span>
                                        <span className="chatMessage">
                                            {message.message}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        </div>
                        <ChatForm target={chatTarget} isTypingActive={isTypingActive} doneTypeing={() => setCloseChat()} />
                    </div>
                    <ChatStatePopup chatState={chatState} deployScreen={(deployScreen || uiState === "menu")} />
                </>
            }
        </>
    );
};

const mapStateToProps = (state: RootState) => {
    return {
        // GameReducer
        uiState: state.GameReducer.uiState,
        deployScreen: state.GameReducer.deployScreen.enabled,
    };
}
const mapDispatchToProps = (dispatch: any) => {
    return {};
}
export default connect(mapStateToProps, mapDispatchToProps)(Chat);

declare global {
    interface Window {
        OnFocus: (p_Target: MessageTarget) => void;
        OnMessage: (p_DataJson: any) => void;
        OnChangeType: () => void;
        OnClearChat: () => void;
        OnCloseChat: () => void;
    }
}
