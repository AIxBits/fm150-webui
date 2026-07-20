# FM150 Web AT 部署

此覆盖层适用于已经安装了原项目 Simple Admin 与 `/usrdata/socat-at-bridge/atcmd` 的 FM150。它不会安装 Quectel 专用的 RGMII、QMAP 或 QCFG 功能，也不会替换现有 Web 配置。

先将这个适配仓库推送到自己的 GitHub 仓库；以下把该仓库称为 `<user>/<repo>`、分支称为 `<branch>`。

在 FM150 的 SSH shell 中执行：

```sh
cd /tmp
wget -O FM150_webui_toolkit.sh \
  https://raw.githubusercontent.com/<user>/<repo>/<branch>/FM150_webui_toolkit.sh
chmod +x FM150_webui_toolkit.sh
FM150_WEBUI_BASE_URL=https://raw.githubusercontent.com/<user>/<repo>/<branch>/simpleadmin/www \
  ./FM150_webui_toolkit.sh full-install
```

`full-install` 会部署并启动 `ttyOUT2 -> smd7`、`ttyOUT -> smd9` bridge，再安装 Web 页面。若 bridge 已经正常运行，只安装页面时使用 `install`；只修复 bridge 时使用 `bridge-install`。安装完成后访问 `https://<模组管理地址>/fm150.html`。更新页面时使用 `update`；检查状态使用 `check`；卸载页面使用 `uninstall`。

如果 AT bridge 不在默认位置，可为 Lighttpd 服务设置环境变量 `FM150_AT_BRIDGE=/path/to/atcmd`，然后重启 `lighttpd`。默认路径正是已在 FM150 上验证的 `/usrdata/socat-at-bridge/atcmd`。
