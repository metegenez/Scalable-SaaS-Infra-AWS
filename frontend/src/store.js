import { applyMiddleware, createStore } from "redux";
import logger from "redux-logger";
import createSagaMiddleware from "redux-saga";
import history from "./lib/helpers/history";
import httpService from "./lib/helpers/interceptors";
import rootReducer from "./reducers";
import rootSaga from "./sagas";

export default function configureStore(initialState) {
  const sagaMiddleware = createSagaMiddleware();
  const middlewares = [sagaMiddleware, logger];

  const bindMiddleware = (middleware) => {
    const { composeWithDevTools } = require("redux-devtools-extension");
    return composeWithDevTools(applyMiddleware(...middleware));
  };

  const store = createStore(rootReducer, bindMiddleware(middlewares));
  httpService.setupInterceptors(store, history);

  sagaMiddleware.run(rootSaga);
  return store;
}
