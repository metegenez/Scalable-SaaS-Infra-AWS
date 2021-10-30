import { SecurityScanOutlined } from "@ant-design/icons";
import { Col, Row, Statistic } from "antd";
import React from "react";
import { connect } from "react-redux";
class ScanDetail extends React.Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <>
        <Row gutter={16}>
          <Col span={24}>
            <Statistic
              title={"IP Range"}
              value={this.props.scanned_ip}
              prefix={<SecurityScanOutlined />}
            />
          </Col>
        </Row>
        <Row gutter={16}>
          <Col span={24}>
            <Statistic title="Port Range" value={this.props.scanned_port} />
          </Col>
        </Row>
      </>
    );
  }
}

function mapStateToProps(state) {
  const { current_job } = state.main;

  return {
    // Acıklama
    // Environment
    scanned_ip:
      current_job === undefined || current_job.detail === undefined
        ? ""
        : current_job.detail._source.scanned_ip,
    scanned_port:
      current_job === undefined || current_job.detail === undefined
        ? ""
        : current_job.detail._source.scanned_ports,
    current_job:
      current_job === undefined ? undefined : current_job.detail._source,
    ip_port_info:
      current_job === undefined ? [] : current_job.detail._source.ip_port_info,
    ip_addresses:
      current_job === undefined || current_job.ip_addresses === undefined
        ? []
        : current_job.ip_addresses,
  };
}
const mapDispatchToProps = (dispatch, ownProps) => {
  return {};
};

export default connect(mapStateToProps, mapDispatchToProps)(ScanDetail);
