# 参与安卓姐姐

感谢你愿意改进这个项目。请优先提交范围小、可以独立验证的改动。

## 开发环境

- macOS 15+
- Swift 6.1+
- `adb`
- `scrcpy` 4.x

```bash
brew install android-platform-tools scrcpy
swift test
swift build
```

## 提交 Issue

请包含：macOS 版本、芯片架构、Android 厂商与版本、ADB / scrcpy 版本、复现步骤和去敏后的错误文本。不要上传设备序列号、通知、聊天、截图、账号或其他手机内容。

## 提交 Pull Request

1. 先在 Issue 中说明要解决的问题；小型修复可直接提交。
2. 保持本地优先，不新增账号、遥测、云同步或网络数据流。
3. 不要把任意 shell、静默确认或敏感 Android 操作暴露为默认能力。
4. 为解析、命令参数和状态流变更补充测试。
5. 运行 `swift test` 和 `swift build -c release`，并在 PR 中写明真实结果。

真机结果必须写清设备与 Android 版本，不能把单机成功表述为普遍兼容。
