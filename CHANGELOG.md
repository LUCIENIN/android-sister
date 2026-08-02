# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) 的结构，并在稳定版本后采用语义化版本。

## [0.1.0-alpha.1] - 2026-08-02

### Added

- 原生 SwiftUI / AppKit macOS 应用壳。
- USB / Wi-Fi ADB 设备发现与授权状态。
- Android 设备信息和桌面应用列表。
- 普通投屏与 Android 14+ Fusion 虚拟显示。
- ADB、命令执行和 scrcpy 启动计划测试。
- 原创应用图标、公开 README、开源治理文档与 GitHub CI。

### Known limitations

- 预览安装包仅为 Apple Silicon、ad-hoc 签名，未做 Developer ID 签名与 Apple 公证。
- 真机验证目前只覆盖一台 HONOR Android 14 设备。
- 不含剪贴板、通知、文件传输、Finder、MCP 或自动更新。
