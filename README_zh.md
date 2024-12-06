# RGMII 工具包
用于Quectel RM5xxx系列5G调制解调器的软件部署工具包，适用于m.2转RJ45适配器（RGMII）

当前分支：**开发版**

请向此分支而不是主分支提交PR :)

Fork开发分支，并将PR提交到开发分支 :)

[English](README.md) | 简体中文

#### [跳转到使用说明](#使用说明)
**目前功能：** 允许您安装或者对已安装的组件进行更新、删除或修改：
 - Simple Admin：通过网关地址管理Quectel m.2调制解调器的简单Web界面
   - 将安装socat-at-bridge：设置ttyOUT和ttyOUT2用于AT命令。您可以通过adb、ssh或ttyd使用`atcmd`命令进行交互式AT命令会话
   - 将安装simplefirewall：一个简单的防火墙，可以阻止可定义的入站端口，并提供TTL修改选项。目前只能通过Simple Admin控制TTL。您可以通过工具包的第3个选项编辑端口阻止选项和TTL
 - Tailscale：用于远程访问Simple Admin、SSH和ttyd的魔法VPN。工具包直接在调制解调器上安装Tailscale客户端，并允许您登录和配置其他设置。访问tailscale.com注册免费账户并了解更多信息
 - 在指定时间安排每日重启
 - 修复某些不会在CFUN=1模式下启动的调制解调器的问题
 - Entware/OPKG：软件包安装/管理器/仓库
   - 运行`opkg help`查看使用方法
   - 可安装的软件包列表：https://bin.entware.net/armv7sf-k3.2/Packages.html
 - TTYd：直接从浏览器访问的shell会话
   - 目前使用443端口但不使用SSL/TLS（暂时只支持http）
   - 需要Entware/OPKG，如果未安装将自动安装
   - 这将使用entware的登录和密码二进制文件替换原有的Quectel登录和密码二进制文件

**目标** 是包含适用于此调制解调器和其他支持RGMII模式的调制解调器的任何新的有用脚本或软件。

## 截图

![工具包](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_toolkit.png?raw=true)
![主页](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_home.png?raw=true)
![网络](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_simplenetwork.png?raw=true)
![扫描](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_simplescan.png?raw=true)
![设置](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_simplesettings.png?raw=true)
![短信](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_sms.png?raw=true)
![控制台](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_console.png?raw=true)
![设备信息](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/dev_deviceinfo.png?raw=true)

# 开发分支：以下命令将下载测试版/开发中的工具包

## 使用说明
**运行工具包：**
 - 打开ADB & Fastboot++（参见[使用ADB](https://github.com/cachenow/quectel-rgmii-configuration-notes?tab=readme-ov-file#unlocking-and-using-adb)）或直接使用adb
 - 确保您的调制解调器通过USB连接到计算机
 - 运行`adb devices`确保adb检测到您的调制解调器
 - 运行`adb shell ping 8.8.8.8`确保shell可以访问互联网。如果出现错误，请确保调制解调器已连接到蜂窝网络，并确保已设置`AT+QMAPWAC=1`（参见故障排除部分：[无法从以太网端口获取互联网访问（常见）](https://github.com/cachenow/quectel-rgmii-configuration-notes/tree/main?tab=readme-ov-file#i-cant-get-internet-access-from-the-ethernet-port-common)）
 - 如果没有错误，您应该会看到持续的回复，按`CTRL-C`停止
 - 只需将以下命令复制/粘贴到命令提示符/Shell中
```bash
adb shell "cd /tmp && wget -O RMxxx_rgmii_toolkit.sh https://raw.githubusercontent.com/cachenow/quectel-webui/main/RMxxx_rgmii_toolkit.sh && chmod +x RMxxx_rgmii_toolkit.sh && ./RMxxx_rgmii_toolkit.sh" && cd /
```

**或者，如果您想在完成后保持在调制解调器的shell中**

```
adb shell
```
然后运行
```
cd /tmp && wget -O RMxxx_rgmii_toolkit.sh https://raw.githubusercontent.com/cachenow/quectel-webui/main/RMxxx_rgmii_toolkit.sh && chmod +x RMxxx_rgmii_toolkit.sh && ./RMxxx_rgmii_toolkit.sh && cd /
```
**您应该看到：**
![工具包](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/iamromulantoolkit.png?raw=true)

## Tailscale安装和配置

> :warning: 您的调制解调器必须已经连接到互联网才能安装
### 安装：
打开工具包主菜单并**按4**进入Tailscale菜单

![工具包](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/tailscalemenu.png?raw=true)

**按1，等待安装完成。这对系统来说是一个很大的文件，所以需要一些时间。**

**完成后，当显示Tailscale安装成功时，按2/回车进行配置。**

![工具包](https://github.com/cachenow/quectel-rgmii-configuration-notes/blob/main/images/tailscaleconfig.png?raw=true)

如果需要，可以通过**按1/回车**在端口8088上启用Tailscale Web UI，以便稍后从浏览器进行配置。

在工具包中进行配置：
首次连接时，您将获得一个登录链接
 - 按3仅连接
 - 按4连接并启用通过tailscale的SSH访问（远程命令行）
 - 按5在启用SSH的情况下重新连接
 - 按6断开连接
 - 按7注销

就是这样！从运行tailscale的另一个设备，您应该能够通过tailnet分配给它的IP访问您的调制解调器。要从tailnet上的另一个设备访问SSH，打开终端/命令提示符并输入

    tailscale ssh root@(IP或主机名)
IP或主机名是tailnet中分配给它的IP或主机名

 - 注意，您的SSH客户端必须能够在连接时提供登录链接。这就是会话授权的方式。在Windows CMD中运行正常，在Android上使用JuiceSSH。

## 高级/测试版

### Entware/OPKG安装

它还不够完善，所以暂时放在高级/测试版下。
以下是您需要了解的内容：

 - 安装后，`opkg`命令将可用
 - 您可以运行`opkg list`查看可安装的软件包列表，或访问https://bin.entware.net/armv7sf-k3.2/Packages.html
 - opkg的所有操作都安装在/opt中
 - `/opt`实际位于`/usrdata/opt`以节省空间，但挂载在`/opt`
 - 默认情况下，`opkg`安装的任何内容都不会出现在系统路径中，但您可以通过以下方式解决：

#### 临时方案：
在每次adb shell或SSH shell会话开始时运行

    export PATH=/opt/bin:/opt/sbin:$PATH

#### 永久方案：
将每个由软件包安装的二进制文件从`/opt/bin`和`/opt/sbin`符号链接到`/bin`和`/sbin`
例如，如果要安装zerotier：

    opkg install zerotier
    ln -sf /opt/bin/zerotier-one /bin
    ln -sf /opt/bin/zerotier-cli /bin
    ln -sf /opt/bin/zerotier-idtool /bin

现在您可以随时从shell运行这3个二进制文件，因为它们已链接到系统路径中的位置。

我计划稍后为/opt/bin和/opt/sbin创建一个看门狗服务，自动将新软件包链接到/bin或/sbin，以解决这个问题。

### TTYd安装

它还不够完善，所以暂时放在高级/测试版下。
以下是您需要了解的内容：

 - 在443端口监听http请求（暂时没有SSL/TLS）
 - 这将自动安装entware并用entware的登录和密码二进制文件修补原有的二进制文件
 - 它会要求您为`root`用户账户设置密码
 - TTYd目前似乎对移动设备不太友好，但我已尽可能优化，所以至少可以通过智能手机浏览器使用。希望以后能进一步改进启动脚本。

## 致谢
### GitHub用户/个人：
感谢：

[Nate Carlson](https://github.com/natecarlson) - 原始Telnet守护进程/socat桥接使用和原始RGMII说明

[aesthernr](https://github.com/aesthernr) - 创建原始Simple Admin

[rbflurry](https://github.com/rbflurry/) - 初始Simple Admin修复

[dr-dolomite](https://github.com/dr-dolomite) - 一些重要的状态页面改进和本仓库第一个获批的外部PR！

[tarunVreddy](https://github.com/tarunVreddy) - 帮助处理SA频段聚合解析

### 现有项目：
Simpleadmin大量使用了Dairyman's Rooter Source的AT命令解析脚本（基本上是带有新更改和调整的副本）https://github.com/ofmodemsandmen/ROOterSource2203

Tailscale通过Tailscale的静态构建页面获得。由于这些调制解调器有一个32位ARM处理器，我使用了arm包。https://pkgs.tailscale.com/stable/#static

Entware/opkg通过[Entware的wiki](https://github.com/Entware/Entware/wiki/Alternative-install-vs-standard)获得，安装程序由[iamromulan](https://github.com/iamromulan)大幅修改以用于Quectel调制解调器

TTYd从[TTYd项目](https://github.com/tsl0922/ttyd)获得

本代码基于[quectel-rgmii-toolkit](https://github.com/iamromulan/quectel-rgmii-toolkit)修改，仅供个人使用。
