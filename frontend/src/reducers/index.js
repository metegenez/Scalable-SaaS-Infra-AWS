import cloneDeep from "lodash/cloneDeep";
import { combineReducers } from "redux";

const initialState = { job_list: [] };

function main(state = initialState, action) {
  switch (action.type) {
    case "PUT_JOB_LIST":
      return { ...state, job_list: action.payload };
    case "PUT_JOB":
      return cloneDeep({ ...state, current_job: action.payload });
    case "POST_NEW_JOB_SUCCESS":
      return { ...state, job_post_status: true };
    case "POST_NEW_JOB_FAIL":
      return { ...state, job_post_status: false };
    case "POST_NEW_JOB_REFRESH":
      return { ...state, job_post_status: undefined };

    case "DECREMENT":
      return state - 1;
    default:
      return state;
  }
}

const rootReducer = combineReducers({
  main,
});

export default rootReducer;
