import axios from "axios";

export default {
  setupInterceptors: (store, history) => {
    axios.interceptors.response.use(
      (response) => {
        return response;
      },
      (error) => {
        if (error.response.status === 404) {
          history.replace("/404");
          history.go(0);
        }

        return Promise.reject(error);
      }
    );
  },
};
