import { Card, Col, PageHeader, Row } from "antd";
import React, { Component } from "react";
import { connect } from "react-redux";
import actions from "../../../actions";
import JobDetailTable from "./JobDetailTable";
import OnlineHost from "./OnlineHost";
import OSChart from "./OSChart";
import ScanDetail from "./ScanDetail";
class Job extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    this.props.getJob({ job_id: this.props.match.params.id });
  }

  render() {
    return (
      <>
        <PageHeader
          className="site-page-header"
          style={{ padding: "20px 35px" }}
          onBack={() => window.history.back()}
          title={"Job: " + this.props.match.params.id}
        ></PageHeader>
        <Row>
          <Col span={18} offset={3}>
            <Row>
              <Col span={8}>
                <Card
                  title="Scan"
                  style={{ height: "350px", margin: "30px 0px" }}
                >
                  <ScanDetail history={this.props.history} />
                </Card>
              </Col>
              <Col span={8}>
                <Card
                  title="OS Info"
                  style={{ height: "350px", margin: "30px 0px" }}
                >
                  <OSChart history={this.props.history} />
                </Card>
              </Col>
              <Col span={8}>
                <Card
                  title="Host Info"
                  style={{ height: "350px", margin: "30px 0px" }}
                >
                  <OnlineHost history={this.props.history} />
                </Card>
              </Col>
            </Row>
          </Col>
        </Row>
        <Row>
          <Col span={18} offset={3}>
            <JobDetailTable history={this.props.history} />
          </Col>
        </Row>
      </>
    );
  }
}

function mapStateToProps(state) {
  const { current_job } = state.main;

  return {
    // Acıklama
    // Environment
    current_job: current_job === undefined ? undefined : current_job,
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {
    getJob: (v) => dispatch({ type: actions.GET_JOB, payload: v }),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(Job);
