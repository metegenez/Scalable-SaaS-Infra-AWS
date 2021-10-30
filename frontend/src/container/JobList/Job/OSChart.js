import React from "react";
import { Doughnut } from "react-chartjs-2";
import { connect } from "react-redux";

class OsChart extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <>
        <Doughnut
          width={"100px"}
          height={"200px"}
          options={{ maintainAspectRatio: false }}
          data={{
            labels: ["Windows", "Linux", "Unknown"],
            datasets: [
              {
                label: "# of OS",
                data: [
                  Object.values(this.props.ip_info[0]).filter(
                    (item) => item.OS === "Windows"
                  ).length,
                  Object.values(this.props.ip_info[0]).filter(
                    (item) => item.OS === "Linux"
                  ).length,
                  Object.values(this.props.ip_info[0]).filter(
                    (item) => item.OS === "Unknown"
                  ).length,
                ],
                backgroundColor: [
                  "rgba(255, 99, 132, 0.2)",
                  "rgba(54, 162, 235, 0.2)",
                  "rgba(255, 206, 86, 0.2)",
                ],
                borderColor: [
                  "rgba(255, 99, 132, 1)",
                  "rgba(54, 162, 235, 1)",
                  "rgba(255, 206, 86, 1)",
                ],
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

export default connect(mapStateToProps, mapDispatchToProps)(OsChart);
