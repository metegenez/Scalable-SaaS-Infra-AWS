import { Button, Col, PageHeader, Row } from "antd";
import React, { Component } from "react";
import { connect } from "react-redux";
import actions from "../../../actions";
import {
  failNotification,
  successNotification,
} from "../../../lib/helpers/notifications";
import CreateJob from "./CreateJob";
import JobsTable from "./JobsTable";
class JobList extends Component {
  constructor(props) {
    super(props);
    this.state = {
      create_job_visible: false,
    };
    this.handleCreateJobClick = this.handleCreateJobClick.bind(this);
  }

  componentDidMount() {
    this.props.getJobList();
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.job_post_status !== this.props.job_post_status) {
      if (this.props.job_post_status === true) {
        successNotification("Success", "Job created successfuly");

        this.setState({ create_job_visible: false });
        this.props.getJobList();
      } else if (this.props.job_post_status === false) {
        failNotification("Job cannot be deleted.");
      }
    }
  }

  handleCreateJobClick(value) {
    this.setState({ create_job_visible: value });
  }

  render() {
    return (
      <>
        <Row>
          <Col span={18} offset={3}>
            <PageHeader
              className="site-page-header"
              style={{ padding: "20px 35px" }}
              title={<h3>Port Scan Jobs</h3>}
              // style={{ padding: "16px 0" }}
              extra={[
                <Button key={"as"} onClick={() => this.props.getJobList()}>
                  Refresh
                </Button>,
                <Button
                  key={"sa"}
                  type="primary"
                  onClick={() => this.handleCreateJobClick(true)}
                >
                  New Job
                </Button>,
              ]}
            ></PageHeader>
            <CreateJob
              key={this.state.create_job_visible}
              history={this.props.history}
              visible={this.state.create_job_visible}
              visibility_handler={this.handleCreateJobClick}
            />

            <JobsTable history={this.props.history} />
          </Col>
        </Row>
      </>
    );
  }
}

function mapStateToProps(state) {
  const { job_post_status } = state.main;
  return {
    job_post_status: job_post_status,
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {
    getJobList: () => dispatch({ type: actions.GET_JOB_LIST }),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(JobList);
