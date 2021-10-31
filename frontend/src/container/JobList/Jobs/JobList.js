import { Button, Col, Input, PageHeader, Row } from "antd";
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
      url: "",
    };
  }

  componentDidMount() {
    this.props.getJobList();
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.job_post_status !== this.props.job_post_status) {
      if (this.props.job_post_status === true) {
        successNotification("Success", "Url Shorthened");

        this.props.getJobList();
      } else if (this.props.job_post_status === false) {
        failNotification("Url cannot be shortened.");
      }
    }
  }

  render() {
    const selectAfter = (
      <Button
        type="text"
        key={"sa"}
        onClick={() => this.props.shorthenUrl(true)}
      >
        SHORTEN
      </Button>
    );
    return (
      <>
        <Row>
          <Col span={18} offset={3}>
            <PageHeader
              className="site-page-header"
              style={{ padding: "20px 35px" }}
              title={<h3>Url Shorthener</h3>}
              // style={{ padding: "16px 0" }}
              extra={[
                <Button
                  key={"sa"}
                  type="primary"
                  onClick={() => this.handleCreateJobClick(true)}
                >
                  New Job
                </Button>,
              ]}
            ></PageHeader>
          </Col>
          <Col span={10} offset={7}>
            <Input
              size="large"
              addonBefore="https://"
              defaultValue="mysite"
              onChange={(e) =>
                this.setState({ url: "https://" + e.target.value })
              }
              addonAfter={selectAfter}
            />
          </Col>

          <Col span={18} offset={3}>
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
