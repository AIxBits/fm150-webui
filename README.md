# FM150 Web AT

面向 **Fibocom FM150-AE/NA-01** 5G 模组内部 Linux 环境的 Web AT 控制服务。

本仓库是 [cachenow/quectel-webui](https://github.com/cachenow/quectel-webui) 的完整 Fork：保留原项目的 Simple Admin、`socat-at-bridge`、静态 `socat` 二进制及 systemd 单元；在此基础上增加 FM150 的 AT 页面、执行接口与部署脚本。

> 目标是已经能够进入 FM150 内部 Shell、并能使用 AT bridge 的设备。它不是 OpenWrt/QWRT 路由器端 LuCI 插件。

## FM150 功能

- Web 页面：`/fm150.html`
- FM150 专用状态：`AT+GTCCINFO?`、`AT+GTCAINFO?`、`AT+PSRAT?`、`AT+GTUSBMODE?`、`AT+MTSM`
- 常用查询：`ATI`、`CPIN?`、`CSQ`、`CESQ`、`COPS?`、`CGDCONT?`、`CGPADDR`、`CGSN`、`CBC`
- 控制：SIM 切换、4G/5G/自动搜网、ECM 拨号、USB 网络模式、模块重启
- 自定义单行 AT 命令

执行接口会串行化 AT 请求，并限制单次运行时间。Web 页面一次只发送一条命令；不要用分号将多个查询串联，否则 AT bridge 可能在第一个 `OK` 后截断后续回包。

## 已验证的 AT bridge

本项目以 FM150 实机验证的以下路径为默认值：

```text
/usrdata/socat-at-bridge/atcmd    -> /dev/ttyOUT2
/usrdata/socat-at-bridge/atcmd11  -> /dev/ttyOUT
```

安装前先确认：

```sh
ls -l /dev/ttyOUT2 /dev/ttyOUT
/usrdata/socat-at-bridge/atcmd 'ATI'
/usrdata/socat-at-bridge/atcmd 'AT+GTCCINFO?'
```

完整 bridge 内容保留在 [`socat-at-bridge/`](socat-at-bridge/)。当前 FM150 实机映射为 `/dev/smd7` → `ttyOUT2`、`/dev/smd9` → `ttyOUT`；对应服务明确命名为 `socat-smd7*` 与 `socat-smd9*`。`FM150_socat_bridge_install.sh` 会迁移旧的 `socat-smd11*` 服务。不同 FM150 固件可能不同，安装器会先检查节点。详细说明见 [FM150 bridge 文档](socat-at-bridge/FM150_README.md)。

## 完整部署（AT bridge + Web 服务）

前提：设备已经有可用的 Simple Admin/Lighttpd。完整部署会检查 `/dev/smd7`、`/dev/smd9`，安装并启动 AT bridge，再部署 FM150 Web 服务；不需要预先存在 `atcmd`。

```sh
cd /tmp
wget -O FM150_webui_toolkit.sh \
  https://raw.githubusercontent.com/AIxBits/fm150-webui/main/FM150_webui_toolkit.sh
chmod +x FM150_webui_toolkit.sh
FM150_WEBUI_BASE_URL=https://raw.githubusercontent.com/AIxBits/fm150-webui/main/simpleadmin/www \
  ./FM150_webui_toolkit.sh full-install
```

安装后访问：

```text
https://<FM150 管理地址>/fm150.html
```

部署完成后可检查服务状态：

```sh
./FM150_webui_toolkit.sh check
```

## 风险提示

下列命令会造成断网、USB 重新枚举或当前 Web 会话中断：

- `AT+GTUSBMODE=...`
- `AT+GTACT=...`
- `AT+GTDUALSIM=...`
- `AT+CFUN=...`

IMEI 写入不提供一键功能。只应在合法维修场景下，通过自定义 AT 命令并自行确认后操作。

## 目录

```text
FM150_webui_toolkit.sh       FM150 完整部署与状态检查
FM150_DEPLOY.md              详细部署说明
simpleadmin/www/fm150.html   FM150 Web 页面
simpleadmin/www/cgi-bin/fm150_at  安全的 AT CGI 接口
socat-at-bridge/             原始 bridge、AT 客户端、静态 socat 与 systemd 单元
```

## 参考与致谢

- [cachenow/quectel-webui](https://github.com/cachenow/quectel-webui)：完整上游项目、Simple Admin 和 bridge 基础。
- [iamromulan/quectel-rgmii-toolkit](https://github.com/iamromulan/quectel-rgmii-toolkit)：RGMII 工具链参考。
- [FUjr/QModem](https://github.com/FUjr/QModem)：QWRT 中 Fibocom AT 预设的上游来源。
- [obsy/packages 的 FM150 状态解析](https://github.com/obsy/packages/blob/d190c4af80f8a973ff2220c3aa1c0bbe63b3909e/easyconfig/files/usr/share/easyconfig/modem/addon/2cb70104)：`GTCCINFO` / `GTCAINFO` 的 OpenWrt 实际解析参考。

原项目及其第三方组件的许可、署名与使用限制仍然适用。
