import SwiftUI

struct SettingsView: View {
    @AppStorage(PreferenceKey.adbPath) private var adbPath = ""
    @AppStorage(PreferenceKey.scrcpyPath) private var scrcpyPath = ""
    @AppStorage(PreferenceKey.includeSystemApps) private var includeSystemApps = false

    var body: some View {
        TabView {
            Form {
                Toggle("显示系统应用", isOn: $includeSystemApps)

                Text("关闭时只显示用户安装、且带桌面入口的应用。修改后请回到主窗口刷新应用。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .formStyle(.grouped)
            .tabItem {
                Label("通用", systemImage: "gear")
            }

            Form {
                TextField("ADB 路径", text: $adbPath, prompt: Text("/opt/homebrew/bin/adb"))
                TextField("scrcpy 路径", text: $scrcpyPath, prompt: Text("/opt/homebrew/bin/scrcpy"))

                Text("留空时会自动搜索 PATH、Homebrew 和常见安装位置。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .formStyle(.grouped)
            .tabItem {
                Label("工具", systemImage: "wrench.and.screwdriver")
            }
        }
        .scenePadding()
        .frame(width: 520, height: 280)
    }
}
