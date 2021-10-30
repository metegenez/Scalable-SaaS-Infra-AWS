import { Button, Drawer, Space } from "antd";
import React from "react";
import JobForm from "./CreateJobForm";

export default class DrawerForm extends React.Component {
  constructor(props) {
    super(props);
  }

  onClose = () => {
    this.props.visibility_handler(false);
  };

  render() {
    return (
      <>
        <Drawer
          title="Create a port scan job."
          width={720}
          onClose={this.onClose}
          visible={this.props.visible}
          bodyStyle={{ paddingBottom: 80 }}
          extra={
            <Space>
              <Button onClick={this.onClose}>Cancel</Button>
              <Button onClick={this.onClose} type="primary">
                Submit
              </Button>
            </Space>
          }
        >
          <JobForm />
        </Drawer>
      </>
    );
  }
}
