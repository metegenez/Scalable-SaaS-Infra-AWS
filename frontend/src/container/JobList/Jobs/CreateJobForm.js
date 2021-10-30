import { Button, Form, Input } from "antd";
import React from "react";
import { connect } from "react-redux";
import actions from "../../../actions";
class JobForm extends React.Component {
  constructor(props) {
    super(props);
  }

  onFinish = (values) => {
    this.props.postNewJob(values);
  };

  onFinishFailed = (errorInfo) => {
    console.log("Failed:", errorInfo);
  };

  render() {
    return (
      <>
        <Form
          name="basic"
          labelCol={{ span: 8 }}
          wrapperCol={{ span: 16 }}
          initialValues={{ remember: true }}
          onFinish={this.onFinish}
          onFinishFailed={this.onFinishFailed}
          autoComplete="off"
        >
          <Form.Item
            label="IP Range or CIDR"
            name="ip_range"
            rules={[{ required: true, message: "Please input ip range!" }]}
          >
            <Input />
          </Form.Item>

          <Form.Item
            label="Port Range"
            name="port_range"
            rules={[{ required: true, message: "Please input port range!" }]}
          >
            <Input />
          </Form.Item>

          <Form.Item wrapperCol={{ offset: 8, span: 16 }}>
            <Button type="primary" htmlType="submit">
              Submit
            </Button>
          </Form.Item>
        </Form>
      </>
    );
  }
}
function mapStateToProps(state) {
  return {};
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {
    postNewJob: (payload) =>
      dispatch({ type: actions.POST_NEW_JOB, payload: payload }),
  };
};

export default connect(mapStateToProps, mapDispatchToProps)(JobForm);
