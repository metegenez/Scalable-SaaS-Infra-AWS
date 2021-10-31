import { Table } from "antd";
import React, { Component } from "react";
import { connect } from "react-redux";
import { v4 as uuidv4 } from "uuid";
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
        title: "Url",
        dataIndex: "url",
        key: "url",
        width: "50%",
      },
      {
        title: "Shortened",
        dataIndex: "shortened",
        key: "shortened",
        width: "50%",
        render: (item) => (
          <a href={item} target="_blank">
            {item}
          </a>
        ),
      },
    ];

    return (
      <>
        <Table
          className="wiseTable"
          dataSource={this.props.url_list.map((item) => ({
            key: uuidv4(),
            url: item.url,
            shortened: item.shortened,
          }))}
          columns={columns}
        />
      </>
    );
  }
}
function mapStateToProps(state) {
  const { url_list } = state.main;

  return {
    // Acıklama
    // Environment
    url_list: url_list === undefined ? undefined : url_list.reverse(),
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {};
};

export default connect(mapStateToProps, mapDispatchToProps)(JobsTable);
