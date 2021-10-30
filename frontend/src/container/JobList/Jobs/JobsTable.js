import { LoadingOutlined } from "@ant-design/icons";
import { Progress, Table } from "antd";
import React, { Component } from "react";
import { connect } from "react-redux";

class JobsTable extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidUpdate(prevProps, prevState) {
    // if (
    //   prevProps.automation_delete_status !== this.props.automation_delete_status
    // ) {
    //   if (this.props.automation_delete_status === true) {
    //     successNotification("Success", "Automation deleted successfuly");
    //     this.props.getAutomations();
    //   } else if (this.props.automation_delete_status === false) {
    //     failNotification("Automation cannot be deleted.");
    //   }
    // }
  }

  componentDidMount() {}

  render() {
    const columns = [
      {
        title: "Status",
        dataIndex: "status",
        key: "status",
        width: "10%",
        render: (item) =>
          item === "Finished" ? (
            <Progress
              type="circle"
              width={64}
              percent={100}
              format={() => "Done"}
            />
          ) : item === "Waiting" ? (
            <Progress
              type="circle"
              width={64}
              percent={0}
              format={() => "Wait"}
            />
          ) : (
            <Progress
              type="circle"
              width={64}
              percent={50}
              format={() => "Scan"}
            />
          ),
      },
      {
        title: "IP Range",
        dataIndex: "ip_range",
        key: "ip_range",
        width: "10%",
      },
      {
        title: "Port Range",
        dataIndex: "port_range",
        key: "port_range",
        width: "10%",
      },
      {
        title: "Start Time",
        dataIndex: "start_time",
        key: "start_time",
        width: "10%",
        render: (item, record) =>
          record.status === "Waiting"
            ? "Waiting"
            : new Date(item).toLocaleString(),
        sorter: (a, b) => new Date(a.start_time) - new Date(b.start_time),
      },
      {
        title: "Finish Time",
        dataIndex: "finish_time",
        key: "finish_time",
        width: "10%",
        render: (item, record) =>
          new Date(record.start_time).getTime() === new Date(item).getTime()
            ? "Waiting"
            : new Date(record.start_time).getTime() > new Date(item).getTime()
            ? "Scanning"
            : new Date(item).toLocaleString(),
      },
    ];

    return (
      <>
        <Table
          className="wiseTable"
          loading={{
            spinning: this.props.job_list === undefined,
            indicator: (
              <LoadingOutlined style={{ fontSize: 48, color: "#4482FF" }} />
            ),
          }}
          dataSource={this.props.job_list.map((item) => ({
            key: item.job_id,
            ip_range: item.scanned_ip,
            port_range: item.scanned_ports,
            status: item.status,
            start_time: item.start_timestamp,
            finish_time: item.finished_timestamp,
          }))}
          columns={columns}
          onRow={(record, rowIndex) => {
            return {
              onClick: (event) => {
                record.status === "Finished"
                  ? this.props.history.push("jobs/" + record.key)
                  : void 0;
              }, // click row
            };
          }}
        />
      </>
    );
  }
}
function mapStateToProps(state) {
  const { job_list } = state.main;

  return {
    // Acıklama
    // Environment
    job_list: job_list === undefined ? undefined : job_list.reverse(),
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {};
};

export default connect(mapStateToProps, mapDispatchToProps)(JobsTable);
