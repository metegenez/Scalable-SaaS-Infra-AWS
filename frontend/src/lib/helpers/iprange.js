import ScriptTag from "react-script-tag";

const ip_cidr = (props) => (
  <ScriptTag type="text/javascript" src="/dist/ip-cidr.js" />
);

export default function calculate_ip_range() {
  console.log(window.IPCIDR);
  //   const cidr = IPCIDR("50.165.190.0/23");
  //   console.log(cidr);
}
