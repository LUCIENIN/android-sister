# 安卓姐姐实施计划

目标是独立实现一个本地优先的 macOS Android 真机伴侣，不复制 AndroMeld 的名称、图标、素材或未公开代码。

## 阶段 1：可用 MVP

状态：已实现；2026-07-30 在一台 HONOR Android 14 真机完成核心链路验收。

- 原生 SwiftUI/AppKit 应用壳
- USB/Wi-Fi ADB 设备发现
- USB 调试授权、离线与错误状态
- 读取 Android 版本、厂商、机型和桌面应用
- 普通投屏：目标应用在手机主屏启动
- 融合窗口：Android 14+ 使用 scrcpy 虚拟显示启动目标应用
- ADB 与 scrcpy 路径设置
- 后台单元测试、release 构建和 ad-hoc `.app` 打包

说明：本阶段真机验收只覆盖上述单台设备；多品牌兼容与正式签名仍属于阶段 4。

验收标准：

1. 无设备、未授权、离线、已连接四类状态不会崩溃或卡死。
2. 目标 HONOR Android 14 能读取应用列表。
3. 普通投屏能生成有效画面。
4. 融合模式创建临时虚拟显示并在关闭后清理。
5. 关闭外部窗口后不残留 scrcpy 进程。

## 阶段 2：连续性与 AI 控机

- Android 轻量助手，通过 ADB 按需安装
- 双向文字与图片剪贴板
- Android 通知转发到 macOS 通知中心
- Mac 文件拖入应用窗口并发送到 `Download/AndroidSister/`
- 本地 MCP：设备状态、结构化 UI、截图、点击、滑动、输入、启动应用
- MCP 默认不暴露任意 shell；敏感动作保留明确确认和回放

验收标准：

1. 断网时全部核心能力仍可工作。
2. 通知和剪贴板内容不写入远程服务或分析日志。
3. MCP 每次操作有设备、坐标或元素、时间和结果记录。
4. 登录、消息、支付、删除等外部动作不会被静默自动确认。

## 阶段 3：Finder 与系统融合

- `NSFileProviderReplicatedExtension` Finder 侧边栏
- ADB 文件枚举、下载、上传、移动、重命名和删除
- Quick Look 与传输进度
- Spotlight 应用入口
- Dock/桌面快捷方式
- Handoff/NSUserActivity
- APK、APKS、APKM、XAPK 元数据检查与安装

验收标准：

1. 传输中断不会留下被误报为完整的文件。
2. `.DS_Store` 等 macOS 文件不会写入手机。
3. Finder 写操作有确定的完成或失败回读。
4. APK 安装前显示包名、版本、签名、权限和兼容性。

## 阶段 4：分发与兼容

- HONOR、Pixel、Samsung、Xiaomi/HyperOS 真机矩阵
- USB 与无线 ADB 重连
- Developer ID 签名、公证和更新机制
- Mac App Store 沙盒、File Provider entitlement 与 StoreKit 评估
- 中英文界面、VoiceOver、键盘导航和减少动态效果
- 第三方许可证、隐私政策和诊断数据开关

发布门槛：

- 本机 ad-hoc 签名不等于可分发版本。
- 通过构建不等于多品牌真机兼容。
- App Store 上架需要真实开发者账号、签名、entitlement、审核和商店回读。
