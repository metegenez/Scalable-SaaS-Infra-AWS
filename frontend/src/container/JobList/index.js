import React from "react";
import { Route, Switch, useRouteMatch } from "react-router-dom";
import JobList from "./Jobs/JobList";
export default function JobsPage() {
  const match = useRouteMatch();
  return (
    <>
      <Switch>
        <Route exact path={`${match.path}/`} component={JobList} />
      </Switch>
    </>
  );
}
