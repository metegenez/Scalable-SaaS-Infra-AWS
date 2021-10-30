import axios from "axios";
import { all, call, put, takeEvery } from "redux-saga/effects";
import actions from "../actions/index";

function postNewJobHelper(payload) {
  const { ip_range, port_range } = payload;
  console.log(payload);
  const config = {
    headers: {},
  };
  return axios
    .post(
      "http://127.0.0.1:5000" + "/jobs",
      {
        ip_range,
        port_range,
      },
      config
    )
    .then((response) => {
      return response;
    });
}

function* postNewJob(action) {
  try {
    const response = yield call(postNewJobHelper, action.payload);
    yield put({
      type: actions.POST_NEW_JOB_SUCCESS,
      job_post_status: true,
    });
    yield put({
      type: actions.POST_NEW_JOB_REFRESH,
      job_post_status: undefined,
    });
  } catch {
    yield put({
      type: actions.POST_NEW_JOB_FAIL,
      job_post_status: false,
    });
    yield put({
      type: actions.POST_NEW_JOB_REFRESH,
      job_post_status: undefined,
    });
  }
}

//////////////////////

function getAllJobsHelper(payload) {
  const config = {
    headers: {},
  };
  return axios
    .get("http://127.0.0.1:5000" + "/jobs", config)
    .then((response) => {
      return response;
    });
}

function* getAllJobs(action) {
  try {
    const response = yield call(getAllJobsHelper, action.payload);
    console.log("get geliyor");
    console.log(response.data);
    if (response.status === 200) {
      console.log(response.data);
      yield put({
        type: actions.PUT_JOB_LIST,
        payload: response.data.all_scans,
      });
    }
  } catch {
    console.log("sa");
  }
}

////////////////////////////////////////

function getJobHelper(payload) {
  const config = {
    headers: {},
  };
  console.log("payload: " + payload);
  return axios
    .get("http://127.0.0.1:5000" + "/jobs/" + payload.job_id, config)
    .then((response) => {
      return response;
    });
}

function* getJob(action) {
  try {
    const response = yield call(getJobHelper, action.payload);
    console.log(response.data);
    if (response.status === 200) {
      console.log(response.data);
      yield put({
        type: actions.PUT_JOB,
        payload: response.data,
      });
    }
  } catch {
    console.log("neler oluyor");
  }
}

// single entry point to start all Sagas at once
export default function* rootSaga() {
  yield all([
    takeEvery(actions.POST_NEW_JOB, postNewJob),
    takeEvery(actions.GET_JOB_LIST, getAllJobs),
    takeEvery(actions.GET_JOB, getJob),
  ]);
}
