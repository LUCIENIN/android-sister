# 安全政策

## 支持范围

安全修复优先覆盖最新的 GitHub 预览版。Alpha 阶段不承诺长期版本维护。

## 私下报告

请使用 GitHub 的 [Private vulnerability reporting](https://github.com/LUCIENIN/android-sister/security/advisories/new)。不要在公开 Issue 中提交设备序列号、手机内容、账号信息、私钥、访问令牌或可复现的未修复漏洞细节。

报告中请包含受影响版本、影响、复现步骤和建议缓解方法。项目会先确认收到，再评估修复与披露时间。

## 安全边界

安卓姐姐通过本机 ADB 与 scrcpy 工作，不提供项目云服务。ADB 本身拥有较高设备权限；只连接你信任的电脑和手机，并及时撤销不再使用的 USB 调试授权。
