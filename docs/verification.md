# 验证记录

## 2026-07-30：MVP 真机与工程验收

### 环境

- macOS 26.5，Apple Silicon arm64
- Xcode 26.6，Swift 6.3.3
- ADB 37.0.1
- scrcpy 4.1
- HONOR Android 14 / SDK 34

### 工程验证

- `swift test`：8/8 通过
- Debug 与 Release 构建：通过
- `plutil -lint`：通过
- `codesign --verify --deep --strict`：ad-hoc 包验证通过
- 隐藏启动烟测：进程正常存活，退出后无残留和近期崩溃报告

### 真机验证

- 发现 92 条桌面入口，其中 43 个第三方包
- 普通模式生成有效 1080 × 2384 H.264 画面
- Fusion 模式创建虚拟显示 `id=10`，退出后清理

### 证据边界

录屏和抽帧包含真实手机内容，验收后已删除，没有提交到仓库。以上结果只证明这台设备、这个工具链和这次测试；不代表其他厂商、Android 版本、音频路径、正式签名或公证已经验证。

每次公开发布仍需重新运行当前源码的测试、Release 构建、Info.plist 与签名校验，并记录新产物的 SHA-256。
