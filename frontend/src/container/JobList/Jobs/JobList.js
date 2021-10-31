import {
  Button,
  Col,
  Form,
  Input,
  message,
  PageHeader,
  Row,
  Space,
} from "antd";
import React, { Component } from "react";
import { connect } from "react-redux";
import actions from "../../../actions";
import {
  failNotification,
  successNotification,
} from "../../../lib/helpers/notifications";
import JobsTable from "./JobsTable";
class JobList extends Component {
  constructor(props) {
    super(props);
    this.state = {};
    this.formRef = React.createRef();
  }

  componentDidMount() {}

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.job_post_status !== this.props.job_post_status) {
      if (this.props.job_post_status === true) {
        successNotification("Success", "Url Shorthened");
      } else if (this.props.job_post_status === false) {
        failNotification("Url cannot be shortened.");
      }
    }
  }
  onFinish = (e) => {
    this.props.sendUrl(e);
    message.success("Submit success!");
  };

  onFinishFailed = () => {
    message.error("Submit failed!");
  };

  render() {
    return (
      <>
        <Row>
          <Col span={18} offset={3}>
            <PageHeader
              className="site-page-header"
              style={{ padding: "20px 35px" }}
              title={<h3>Url Shorthener</h3>}
              // style={{ padding: "16px 0" }}
            ></PageHeader>
          </Col>
          <Col span={12} offset={6}>
            <Form
              ref={this.formRef}
              layout="horizontal"
              onFinish={this.onFinish}
              onFinishFailed={this.onFinishFailed}
              autoComplete="off"
            >
              <Form.Item
                name="url"
                rules={[{ required: true }, { type: "string", min: 2 }]}
              >
                <Input addonBefore="https://" placeholder="Url" />
              </Form.Item>
              <Form.Item>
                <Space>
                  <Button type="primary" htmlType="submit">
                    Submit
                  </Button>
                </Space>
              </Form.Item>
            </Form>
          </Col>

          <Col span={18} offset={3}>
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
    sendUrl: (v) => dispatch({ type: actions.POST_NEW_URL, payload: v }),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(JobList);
