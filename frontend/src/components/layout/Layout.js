import { Breadcrumb, Layout, Menu } from "antd";

const { Header, Content, Footer } = Layout;

<Layout className="layout">
  <Header>
    <div className="logo" />
    <Menu theme="dark" mode="horizontal" defaultSelectedKeys={["0"]}>
      <Menu.Item key={"0"}>{`nav ${"0"}`}</Menu.Item>
    </Menu>
  </Header>
  <Content style={{ padding: "0 50px" }}>
    <Breadcrumb style={{ margin: "16px 0" }}>
      <Breadcrumb.Item>Home</Breadcrumb.Item>
      <Breadcrumb.Item>List</Breadcrumb.Item>
      <Breadcrumb.Item>App</Breadcrumb.Item>
    </Breadcrumb>
    <div className="site-layout-content">Content</div>
  </Content>
  <Footer style={{ textAlign: "center" }}>
    Ant Design ©2018 Created by Ant UED
  </Footer>
</Layout>;
