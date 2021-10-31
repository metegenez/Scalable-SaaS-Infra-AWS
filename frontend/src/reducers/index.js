import { combineReducers } from "redux";

const initialState = { url_list: [] };

function main(state = initialState, action) {
  switch (action.type) {
    case "POST_NEW_URL_SUCCESS":
      return {
        ...state,
        url_post_status: true,
        url_list: [...state.url_list, action.url],
      };
    case "POST_NEW_URL_FAIL":
      return { ...state, url_post_status: false };
    case "POST_NEW_URL_REFRESH":
      return { ...state, url_post_status: undefined };
    default:
      return state;
  }
}

const rootReducer = combineReducers({
  main,
});

export default rootReducer;
