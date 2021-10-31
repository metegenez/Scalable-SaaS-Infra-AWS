import axios from "axios";
import { all, call, put, takeEvery } from "redux-saga/effects";
import actions from "../actions/index";
console.log(process.env.REACT_APP_BASE_URL);
function postNewJobHelper(payload) {
  const config = {
    headers: {},
  };
  return axios
    .post(
      process.env.REACT_APP_BASE_URL + "/url",
      {
        payload,
      },
      config
    )
    .then((response) => {
      return response;
    });
}

function* postNewUrl(action) {
  try {
    const response = yield call(postNewJobHelper, action.payload);
    console.log(response.data);
    yield put({
      type: actions.POST_NEW_URL_SUCCESS,
      url_post_status: true,
      url: response.data,
    });
    yield put({
      type: actions.POST_NEW_URL_REFRESH,
      url_post_status: undefined,
    });
  } catch {
    yield put({
      type: actions.POST_NEW_URL_FAIL,
      url_post_status: false,
    });
    yield put({
      type: actions.POST_NEW_URL_REFRESH,
      url_post_status: undefined,
    });
  }
}

// single entry point to start all Sagas at once
export default function* rootSaga() {
  yield all([takeEvery(actions.POST_NEW_URL, postNewUrl)]);
}
