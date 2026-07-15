# PickView

[中文](#中文) | [English](#english)

## 中文

### 项目简介

PickView 是一个基于 [Lookin](https://github.com/QMUI/LookinServer) 的 Apple 平台 UI 检查工具。项目沿用了 Lookin 的层级、预览和属性面板设计，并在此基础上增加了：

- **macOS App 检查**：读取 `NSWindow`、`NSView` 和 `CALayer` 层级；多个 `NSWindow` 会作为多棵根树展示。
- **无线连接**：PickView Mac 客户端可通过局域网发现并连接运行在 iOS 真机上的 PickView Server。
- **Flutter 调试**：在原生 UIKit 层级中识别 Flutter 页面，通过 Dart VM Service 和 Flutter Inspector extensions 获取 Widget、Element、RenderObject、属性、布局和节点截图。
- **多引擎支持**：按照 `FlutterViewController` 与 `FlutterEngine` 建立并复用 Inspector session。

PickView 的 Flutter 能力用于开发调试。Release Flutter Engine 通常不提供 VM Service，因此 Release 环境只能保证读取原生 UIKit/AppKit 层级。

### 目录结构

```text
PickViewCore          共享模型、协议和序列化
PickViewServer        嵌入被检查 App 的服务端
PickViewClientKit     设备发现、连接与请求管理
PickViewMac           macOS 检查客户端
KKFlutterInspectorKit Flutter VM Service 与 Inspector 封装
```

### 接入被检查的 App

项目当前主要通过本地 CocoaPods 路径接入，建议只在 Debug 配置中启用。

原生 iOS 或 macOS App 只需要接入 Core：

```ruby
pod 'PickViewServer/Core', :path => '../PickView', :configurations => ['Debug']
```

包含 Flutter 页面的 iOS App 使用 Flutter subspec：

```ruby
pod 'KKFlutterInspectorKit', :path => '../KKFlutterInspectorKit', :configurations => ['Debug']
pod 'PickViewServer/Flutter', :path => '../PickView', :configurations => ['Debug']
```

`PickViewServer/Flutter` 已经通过 podspec 依赖 `PickViewServer/Core` 和 `KKFlutterInspectorKit`。业务代码不需要再次 import、创建或启动 `KKFlutterInspectorKit`。上面的 `KKFlutterInspectorKit :path` 仅用于告诉 CocoaPods 去哪里找到当前尚未发布到 Specs 仓库的本地依赖；当 `PickViewServer` 与 `KKFlutterInspectorKit` 发布到同一个 CocoaPods Specs 源后，只需声明 `PickViewServer/Flutter`。

然后执行：

```bash
pod install
```

打开生成的 `.xcworkspace`。`PickViewServer` 使用 Objective-C `+load` 完成自动初始化，但建议在 App 启动完成时显式启动，以便控制配置：

```objc
#import <PickViewServer/PickViewServerKit.h>

#if DEBUG
PickViewServerConfiguration *configuration =
    [PickViewServerConfiguration defaultConfiguration];
configuration.enableLANTransport = YES;
configuration.lanServiceName = @"My App";
[PickViewServer.sharedServer startWithConfiguration:configuration];
#endif
```

真机默认开启 LAN，Simulator 默认关闭 LAN。macOS App 检查目前使用本机 loopback 连接。

### 无线连接配置

无线连接使用 Network.framework 和 Bonjour，服务类型固定为：

```text
_pickview._tcp
```

#### 1. 配置 iOS `Info.plist`

```xml
<key>NSBonjourServices</key>
<array>
    <string>_pickview._tcp</string>
</array>
<key>NSLocalNetworkUsageDescription</key>
<string>Allow PickView on this Mac to discover and inspect this app.</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

PickView 的 Flutter 集成直接从当前 `FlutterEngine` 读取 `vmServiceUrl` 和 `isolateId`，不从系统日志解析 URI，也不通过 Bonjour 扫描 VM Service。

#### 2. 确认运行条件

- Mac 和 iPhone 位于同一个局域网。
- iOS App 保持前台运行；后台挂起后无法保证监听继续工作。
- 首次运行时，在 iOS 系统弹窗中允许“本地网络”。
- PickView 发起连接后，在被检查 App 中点击“允许”。
- VPN、访客 Wi-Fi、AP Isolation 或防火墙不能阻断设备间访问。

#### 3. 从 PickView Mac 连接

1. 打开 `PickView.xcworkspace`。
2. 运行 `PickViewMac` scheme。
3. 在启动页切换到 **LAN Devices**。
4. 选择发现的设备并连接。
5. 在 iOS App 中确认连接请求。

LAN listener 使用系统分配的动态端口，并通过 Bonjour 发布地址和端口，不需要手动填写 IP 或开放固定端口。`47175-47179` 是 loopback/USB 使用的端口范围，不是无线连接的固定端口。

#### 4. 排查无线发现

在 Mac 终端检查 Bonjour 服务：

```bash
dns-sd -B _pickview._tcp local.
```

如果设备没有出现：

- 检查 iOS“设置 > 隐私与安全性 > 本地网络”是否允许目标 App。
- 完全退出并重新启动被检查 App，让 LAN listener 重新注册。
- 确认当前运行的是真机 Debug 包；Simulator 不启动 LAN listener。
- 暂时关闭 VPN，确认路由器没有开启客户端隔离。
- 查看日志中是否出现 `PVLANListener listening` 和 `browser ready for _pickview._tcp`。

### Flutter 调试说明

- Flutter 页面必须使用 `PickViewServer/Flutter`；默认的 `PickViewServer/Core` 只提供原生 UIKit/AppKit 检查能力。
- `PickViewServer/Flutter` 会自动带入并使用 `KKFlutterInspectorKit`，不需要业务侧单独初始化 InspectorKit。
- Flutter Engine 必须处于 Debug；部分 Profile 构建可能可用，Release 构建不可用。
- 不需要手动配置 VM Service URI，不需要 MethodChannel，也不需要从日志解析 Dart Service 地址。
- InspectorKit 从对应的 `FlutterEngine` 获取 `vmServiceUrl` 和 `isolateId`，然后通过 WebSocket JSON-RPC 调用 `ext.flutter.inspector.*`。
- `_pickview._tcp` 仅用于 PickView Mac 发现 PickView Server；Flutter Inspector 连接不通过 Bonjour。
- 当 VM Service 不可用时，原生 `FlutterViewController`/`FlutterView` 层级仍然可以显示，但无法展开 Flutter Widget 子树。

### 致谢与许可

PickView 的检查交互和部分实现基于 Lookin。请同时遵守本仓库以及对应上游项目的许可要求。本仓库中的相关许可文件位于 `Source/PickViewCore/InspectionModels/` 和 `ThirdParty/PickViewDetailReference/`。

---

## English

### Overview

PickView is an Apple-platform UI inspection tool based on [Lookin](https://github.com/QMUI/LookinServer) and [LookInside](https://github.com/LookInsideApp/LookInside). It keeps the familiar hierarchy, preview, and attributes workflow while adding:

- **macOS app inspection** for `NSWindow`, `NSView`, and `CALayer`. Multiple `NSWindow` instances are displayed as separate hierarchy roots.
- **Wireless connections** from the PickView Mac client to an iOS device on the same local network.
- **Flutter inspection** through Dart VM Service and Flutter Inspector service extensions, including Widget, Element, RenderObject, properties, geometry, and per-node screenshots.
- **Multiple Flutter engines**, with reusable Inspector sessions associated with each `FlutterViewController` and `FlutterEngine`.

Flutter inspection is intended for development builds. A Release Flutter Engine normally does not expose VM Service, so only the native UIKit/AppKit hierarchy is guaranteed in Release builds.

### Repository Layout

```text
PickViewCore          Shared models, protocol, and serialization
PickViewServer        Server embedded in the inspected app
PickViewClientKit     Discovery, connections, and request coordination
PickViewMac           macOS inspector client
KKFlutterInspectorKit Flutter VM Service and Inspector integration
```

### Integrating the Inspected App

The current setup uses local CocoaPods paths. Restrict the inspector to Debug builds whenever possible.

For a native iOS or macOS app, integrate only the Core subspec:

```ruby
pod 'PickViewServer/Core', :path => '../PickView', :configurations => ['Debug']
```

For an iOS app that embeds Flutter, use the Flutter subspec:

```ruby
pod 'KKFlutterInspectorKit', :path => '../KKFlutterInspectorKit', :configurations => ['Debug']
pod 'PickViewServer/Flutter', :path => '../PickView', :configurations => ['Debug']
```

`PickViewServer/Flutter` already depends on `PickViewServer/Core` and `KKFlutterInspectorKit` through its podspec. Application code does not need to import, create, or start `KKFlutterInspectorKit` separately. The explicit `KKFlutterInspectorKit :path` line only tells CocoaPods where to find this local dependency while it is not published to a Specs repository. Once both pods are available from the same Specs source, declare only `PickViewServer/Flutter`.

Run:

```bash
pod install
```

Open the generated `.xcworkspace`. `PickViewServer` initializes through an Objective-C `+load`, but an explicit start during app launch is recommended when configuration needs to be controlled:

```objc
#import <PickViewServer/PickViewServerKit.h>

#if DEBUG
PickViewServerConfiguration *configuration =
    [PickViewServerConfiguration defaultConfiguration];
configuration.enableLANTransport = YES;
configuration.lanServiceName = @"My App";
[PickViewServer.sharedServer startWithConfiguration:configuration];
#endif
```

LAN is enabled by default on a physical iOS device and disabled in the Simulator. macOS app inspection currently uses the local loopback transport.

### Wireless Configuration

Wireless discovery uses Network.framework and Bonjour with this service type:

```text
_pickview._tcp
```

#### 1. Configure the iOS `Info.plist`

```xml
<key>NSBonjourServices</key>
<array>
    <string>_pickview._tcp</string>
</array>
<key>NSLocalNetworkUsageDescription</key>
<string>Allow PickView on this Mac to discover and inspect this app.</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

PickView reads `vmServiceUrl` and `isolateId` directly from the current `FlutterEngine`; it does not parse system logs or use Bonjour to discover VM Service.

#### 2. Verify the Runtime Conditions

- The Mac and iPhone are connected to the same local network.
- Keep the inspected iOS app in the foreground.
- Allow Local Network access when iOS displays the permission prompt.
- Accept the connection request shown by the inspected app.
- Make sure VPN, guest Wi-Fi, AP isolation, and firewalls do not block device-to-device traffic.

#### 3. Connect from PickView Mac

1. Open `PickView.xcworkspace`.
2. Run the `PickViewMac` scheme.
3. Select **LAN Devices** on the launch screen.
4. Select the discovered device and connect.
5. Accept the request in the inspected iOS app.

The LAN listener uses a system-assigned dynamic port and publishes it through Bonjour. No manual IP address or fixed wireless port is required. Ports `47175-47179` are reserved for loopback/USB discovery, not wireless LAN.

#### 4. Troubleshooting Discovery

Browse the Bonjour service from Terminal:

```bash
dns-sd -B _pickview._tcp local.
```

If the device does not appear:

- Check Local Network permission under iOS Settings > Privacy & Security.
- Fully relaunch the inspected app so the LAN listener registers again.
- Confirm that a Debug build is running on a physical device; Simulator does not start the LAN listener.
- Temporarily disable VPN and verify that client isolation is disabled on the router.
- Look for `PVLANListener listening` and `browser ready for _pickview._tcp` in the logs.

### Flutter Inspection Notes

- Flutter pages require `PickViewServer/Flutter`; the default `PickViewServer/Core` only provides native UIKit/AppKit inspection.
- `PickViewServer/Flutter` brings in and uses `KKFlutterInspectorKit` automatically. The application does not initialize InspectorKit separately.
- The Flutter Engine must run in Debug. Some Profile configurations may work; Release does not.
- No manual VM Service URI, MethodChannel, or log parsing is required.
- InspectorKit obtains `vmServiceUrl` and `isolateId` from the matching `FlutterEngine`, then calls `ext.flutter.inspector.*` over WebSocket JSON-RPC.
- `_pickview._tcp` is used only for PickView Mac to discover PickView Server; Flutter Inspector does not connect through Bonjour.
- When VM Service is unavailable, the native `FlutterViewController`/`FlutterView` hierarchy remains visible, but the Flutter Widget subtree cannot be expanded.

### Credits and License

PickView's inspection workflow and parts of its implementation are based on Lookin/LookInside. Follow the licenses of this repository and the respective upstream projects. Related license files are stored under `Source/PickViewCore/InspectionModels/` and `ThirdParty/PickViewDetailReference/`.
