import React from 'react';
import ReactDOM from 'react-dom';

import { applyMiddleware, createStore } from 'redux';
import { Provider } from 'react-redux';
import { composeWithDevTools } from 'redux-devtools-extension';
import ReduxThunk from 'redux-thunk';
import { RootReducer } from "./store/RootReducer";

import App from './App';
import Alert from './store/alert/Alert';

const store = createStore(
    RootReducer,
    composeWithDevTools(
        applyMiddleware(ReduxThunk)
    )
);

ReactDOM.render(
    <Provider store={store}>
        <Alert />
        <App />
    </Provider>,
    document.getElementById('root')
);
