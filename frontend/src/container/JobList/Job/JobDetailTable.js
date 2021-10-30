import { LoadingOutlined } from "@ant-design/icons";
import { Progress, Table, Tooltip } from "antd";
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

  componentDidUpdate() {
    console.log(this.props.ip_port_info);
  }

  render() {
    const columns = [
      {
        title: "Status",
        dataIndex: "status",
        key: "status",
        width: "10%",
        render: (item) =>
          item !== "Offline" ? (
            <Progress type="circle" percent={100} width={32} />
          ) : (
            <Progress
              type="circle"
              percent={100}
              width={32}
              status="exception"
            />
          ),
        sorter: (a, b) => b.status.length - a.status.length, //workaround as hell
      },
      {
        title: "IP Range",
        dataIndex: "ip",
        key: "ip",
        width: "40%",
      },
      {
        title: "OS",
        dataIndex: "os",
        key: "os",
        width: "20%",
      },
      {
        title: "Open Ports",
        dataIndex: "ports",
        key: "ports",
        width: "30%",
        render: (item) => (
          <ul>
            {item.length > 0
              ? item.map((i) => (
                  <li>
                    <Tooltip placement="right" title={i.desc}>
                      Port: {i.port}, Service: {i.service}
                    </Tooltip>
                  </li>
                ))
              : "No port detected."}
          </ul>
        ),
      },
    ];

    return (
      <>
        <Table
          className="wiseTable"
          loading={{
            spinning: this.props.current_job === undefined,
            indicator: (
              <LoadingOutlined style={{ fontSize: 48, color: "#4482FF" }} />
            ),
          }}
          dataSource={this.props.ip_addresses.map((item) => ({
            key: item,
            ip: item,
            status: this.props.ip_info.hasOwnProperty(item)
              ? this.props.ip_info[item].status
              : "Offline",
            os: this.props.ip_info.hasOwnProperty(item)
              ? this.props.ip_info[item].OS
              : "Null",
            ports: this.props.ip_port_info.hasOwnProperty(item)
              ? this.props.ip_port_info[item]
              : [],
          }))}
          columns={columns}
          scroll={{ y: "calc(70vh)" }}
          pagination={{ pageSize: 100 }}
        />
      </>
    );
  }
}
function mapStateToProps(state) {
  const { current_job } = state.main;

  return {
    // Acıklama
    // Environment
    current_job:
      current_job === undefined ? undefined : current_job.detail._source,
    ip_info:
      current_job === undefined
        ? {}
        : Object.fromEntries(
            current_job.detail._source.ip_info.flatMap(Object.entries)
          ),
    ip_port_info:
      current_job === undefined
        ? {}
        : Object.fromEntries(
            current_job.detail._source.ip_port_info.flatMap(Object.entries)
          ),
    ip_addresses:
      current_job === undefined || current_job.ip_addresses === undefined
        ? []
        : current_job.ip_addresses,
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {};
};

export default connect(mapStateToProps, mapDispatchToProps)(JobsTable);
