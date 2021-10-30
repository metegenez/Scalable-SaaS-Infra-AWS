import React, { lazy, Suspense } from "react";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import Loader from "./lib/utility/loader";
const PUBLIC_ROUTE = {
  LANDING: "/",
  JOBS: "/jobs",
};

const publicRoutes = [
  {
    path: PUBLIC_ROUTE.LANDING,
    exact: true,
    component: lazy(() => import("./container/JobList")),
  },
  {
    path: PUBLIC_ROUTE.JOBS,
    component: lazy(() => import("./container/JobList")),
  },
];

export default function Routes() {
  return (
    <Suspense fallback={<Loader />}>
      <Router>
        <Switch>
          {publicRoutes.map((route, index) => (
            <Route key={index} path={route.path} exact={route.exact}>
              <route.component />
            </Route>
          ))}
        </Switch>
      </Router>
    </Suspense>
  );
}
