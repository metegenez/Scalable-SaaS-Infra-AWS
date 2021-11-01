import { notification } from "antd";

export const failNotification = (error) => {
  notification.error({
    message: "Error",
    description: error,
  });
};
export const successNotification = (success_short, success_description) => {
  notification.success({
    message: success_short,
    description: success_description,
  });
};

export const infoNotification = (info_short, info_description) => {
  notification.info({
    message: info_short,
    description: info_description,
  });
};
