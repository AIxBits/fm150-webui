# FM150 AT bridge

FM150 适配以已在实际模组中验证的以下端点为准：

| 客户端 | PTY 设备 | 用途 |
| --- | --- | --- |
| `atcmd` | `/dev/ttyOUT2` | FM150 Web AT 控制页默认使用的通道，实际桥接到 `/dev/smd7` |
| `atcmd11` | `/dev/ttyOUT` | 备用 AT 通道，实际桥接到 `/dev/smd9` |

`atcmd` 会将一条 AT 命令写入端点，并读取到 `OK` 或 `ERROR`。Web 端一次只发送一条命令；不要通过分号拼接多条查询，否则第一个结束标志可能导致后续回包被截断。

## 使用前检查

```sh
ls -l /dev/ttyOUT2 /dev/ttyOUT
/usrdata/socat-at-bridge/atcmd 'ATI'
/usrdata/socat-at-bridge/atcmd 'AT+GTCCINFO?'
```

FM150 当前实机映射为 `/dev/smd7` → `ttyOUT2`、`/dev/smd9` → `ttyOUT`。对应 unit 已明确命名为 `socat-smd7*` 与 `socat-smd9*`；旧的 `socat-smd11*` 是上游历史名称，FM150 安装器会停止并移除它们。不同 FM150 固件的底层节点可能不同，安装器会在 `/dev/smd7`、`/dev/smd9` 不存在时停止。

完整安装与启动：

```sh
FM150_BRIDGE_SOURCE=https://raw.githubusercontent.com/AIxBits/fm150-webui/main \
  /tmp/FM150_socat_bridge_install.sh install
```

通常应通过仓库根目录的 `FM150_webui_toolkit.sh bridge-install` 或 `full-install` 下载并执行该安装器。

Web AT CGI 的默认 bridge 路径是 `/usrdata/socat-at-bridge/atcmd`。若你的脚本安装在其他位置，可在 Lighttpd 的服务环境中设置 `FM150_AT_BRIDGE`。
