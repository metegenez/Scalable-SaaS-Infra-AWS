import React from "react";
import { Doughnut } from "react-chartjs-2";
import { connect } from "react-redux";

class OnlineHost extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <>
        <Doughnut
          key={this.props.temp_key}
          width={"100px"}
          height={"200px"}
          options={{ maintainAspectRatio: false }}
          data={{
            labels: ["Online", "Offline"],
            datasets: [
              {
                label: "# of OS",
                data: [
                  Object.values(this.props.ip_info[0]).length,
                  this.props.ip_addresses.length -
                    Object.values(this.props.ip_info[0]).length,
                ],
                backgroundColor: [
                  "rgba(54, 162, 235, 0.2)",
                  "rgba(255, 99, 132, 0.2)",
                ],
                borderColor: ["rgba(54, 162, 235, 1)", "rgba(255, 99, 132, 1)"],
                borderWidth: 1,
              },
            ],
          }}
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
    temp_key: current_job === undefined ? "charempty" : "charfull",

    current_job:
      current_job === undefined ? undefined : current_job.detail._source,
    ip_info:
      current_job === undefined ? [{}] : current_job.detail._source.ip_info,
    ip_addresses:
      current_job === undefined || current_job.ip_addresses === undefined
        ? []
        : current_job.ip_addresses,
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {};
};

export default connect(mapStateToProps, mapDispatchToProps)(OnlineHost);
