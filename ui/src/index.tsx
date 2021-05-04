import React from 'react';
import ReactDOM from 'react-dom';

import { applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import { composeWithDevTools } from 'redux-devtools-extension';
import ReduxThunk from 'redux-thunk';
import { RootReducer } from "./store/RootReducer";

import Alert from './store/alert/Alert';
import KillMessage from './store/killmsg/KillMessage';
import InteractMessage from './store/interactivemsg/InteractMessage';

import App from './App';


const store = createStore(
    RootReducer,
    composeWithDevTools(
        applyMiddleware(ReduxThunk)
    )
);

ReactDOM.render(
    <Provider store={store}>
        <KillMessage />
        <Alert />
        <InteractMessage />
        <App />
    </Provider>,
    document.getElementById('root')
);
