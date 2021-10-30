import React from "react";
import { Route, Switch, useRouteMatch } from "react-router-dom";
import Job from "./Job/Job";
import JobList from "./Jobs/JobList";
export default function JobsPage() {
  const match = useRouteMatch();
  return (
    <>
      <Switch>
        <Route exact path={`${match.path}/:id`} component={Job} />
        <Route exact path={`${match.path}/`} component={JobList} />
      </Switch>
    </>
  );
}
