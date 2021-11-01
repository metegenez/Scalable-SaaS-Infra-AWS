import { Layout } from "antd";
import { Provider } from "react-redux";
import Routes from "./router";
import configureStore from "./store";

const { Header, Content, Footer } = Layout;
const store = configureStore();
const styles = {
  layout: { flexDirection: "row", overflowX: "hidden" },
  content: {
    padding: "0 0 0",
    flexShrink: "0",
    background: "#f4f4f4",
    position: "relative",
  },
  footer: {
    background: "#ffffff",
    textAlign: "center",
    borderTop: "1px solid #ededed",
  },
};
const App = () => (
  <Provider store={store}>
    <>
      <Layout
        className="layout"
        style={{
          height: "calc(100vh)",
        }}
      >
        <Header>
          <div className="logo" />
          {/* <Menu theme="dark" mode="horizontal" defaultSelectedKeys={["0"]}>
            <Menu.Item
              key={"0"}
              onClick={() => {
                window.history.pushState("", "", "http://localhost:3000/jobs");
                window.history.go(0);
              }}
            >
              Scanner
            </Menu.Item>
          </Menu> */}
        </Header>
        <Content style={styles.content}>
          <Routes />
        </Content>
        <Footer style={{ textAlign: "center" }}>
          Url Shorthener ©2021 Created by Mete
        </Footer>
      </Layout>
    </>
  </Provider>
);

export default App;
