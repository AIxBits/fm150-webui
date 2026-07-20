# FM150 完整部署

此方案适用于已安装 Simple Admin/Lighttpd 的 FM150。它会配置并启动 FM150 的 `smd7/smd9` AT bridge，再安装 Web AT 服务；不包含 Quectel 专用的 RGMII、QMAP 或 QCFG 功能。

在 FM150 的 SSH shell 中执行：

```sh
cd /tmp
wget -O FM150_webui_toolkit.sh \
  https://raw.githubusercontent.com/AIxBits/fm150-webui/main/FM150_webui_toolkit.sh
chmod +x FM150_webui_toolkit.sh
FM150_WEBUI_BASE_URL=https://raw.githubusercontent.com/AIxBits/fm150-webui/main/simpleadmin/www \
  ./FM150_webui_toolkit.sh full-install
```

`full-install` 会部署并启动 `ttyOUT2 -> smd7`、`ttyOUT -> smd9` bridge，再安装 Web 服务。安装完成后访问 `https://<模组管理地址>/fm150.html`；状态检查使用 `./FM150_webui_toolkit.sh check`。

如果 AT bridge 不在默认位置，可为 Lighttpd 服务设置环境变量 `FM150_AT_BRIDGE=/path/to/atcmd`，然后重启 `lighttpd`。默认路径正是已在 FM150 上验证的 `/usrdata/socat-at-bridge/atcmd`。
