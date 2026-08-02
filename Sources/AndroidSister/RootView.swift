import AndroidSisterCore
import SwiftUI

struct RootView: View {
    @Bindable var model: AppModel
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            DeviceSidebar(model: model)
                .navigationSplitViewColumnWidth(min: 230, ideal: 260, max: 320)
        } detail: {
            AppBrowser(
                model: model,
                searchText: $searchText
            )
        }
        .task {
            await model.refreshAll()
        }
        .alert(item: $model.notice) { notice in
            Alert(
                title: Text(notice.title),
                message: Text(notice.message),
                dismissButton: .default(Text("好"))
            )
        }
    }
}

private struct DeviceSidebar: View {
    @Bindable var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            List(selection: deviceSelection) {
                Section("设备") {
                    ForEach(model.devices) { device in
                        DeviceRow(device: device)
                            .tag(device.id)
                    }
                }
            }
            .overlay {
                if model.devices.isEmpty {
                    SidebarEmptyState(state: model.deviceLoadState)
                }
            }

            Divider()

            HStack {
                Button {
                    Task {
                        await model.refreshAll()
                    }
                } label: {
                    Label("重新扫描", systemImage: "arrow.clockwise")
                }
                .disabled(model.deviceLoadState == .loading)

                Spacer()

                SettingsLink {
                    Image(systemName: "gearshape")
                }
                .help("设置")
            }
            .padding(12)
        }
        .navigationTitle("安卓姐姐")
    }

    private var deviceSelection: Binding<String?> {
        Binding(
            get: {
                model.selectedDeviceID
            },
            set: { newValue in
                Task {
                    await model.selectDevice(newValue)
                }
            }
        )
    }
}

private struct DeviceRow: View {
    let device: AndroidDevice

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: device.state.isUsable ? "iphone.gen3" : "exclamationmark.iphone")
                .foregroundStyle(device.state.isUsable ? .green : .orange)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.displayName)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(deviceSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: .combine)
    }

    private var deviceSubtitle: String {
        if let version = device.androidVersion {
            return "Android \(version) · \(device.serial)"
        }

        switch device.state {
        case .connected:
            return device.serial
        case .unauthorized:
            return "等待手机确认 USB 调试"
        case .offline:
            return "设备离线"
        case .noPermissions:
            return "ADB 没有访问权限"
        case .unknown:
            return "未知状态"
        }
    }
}

private struct SidebarEmptyState: View {
    let state: AppModel.LoadState

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        }
        .padding()
    }

    private var title: String {
        switch state {
        case .loading:
            return "正在扫描"
        case .failed:
            return "扫描失败"
        default:
            return "没有找到设备"
        }
    }

    private var icon: String {
        state == .loading ? "arrow.triangle.2.circlepath" : "cable.connector"
    }

    private var message: String {
        switch state {
        case .loading:
            return "正在通过 ADB 查找 Android 设备。"
        case .failed(let message):
            return message
        default:
            return "连接 USB，打开 USB 调试，并在手机上确认授权。"
        }
    }
}

private struct AppBrowser: View {
    @Bindable var model: AppModel
    @Binding var searchText: String

    private var filteredApps: [AndroidApp] {
        guard !searchText.isEmpty else { return model.apps }
        return model.apps.filter {
            $0.packageName.localizedCaseInsensitiveContains(searchText)
                || $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if let device = model.selectedDevice {
                VStack(spacing: 0) {
                    DeviceHeader(device: device, appCount: model.apps.count)
                    Divider()
                    appContent
                }
            } else {
                ContentUnavailableView(
                    "选择一台设备",
                    systemImage: "iphone.gen3.radiowaves.left.and.right",
                    description: Text("连接 Android 手机后即可查看和启动应用。")
                )
            }
        }
        .navigationTitle(model.selectedDevice?.displayName ?? "应用")
        .searchable(text: $searchText, prompt: "搜索应用或包名")
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await model.refreshApps()
                    }
                } label: {
                    Label("刷新应用", systemImage: "arrow.clockwise")
                }
                .disabled(model.selectedDevice?.state.isUsable != true || model.appLoadState == .loading)
            }
        }
    }

    @ViewBuilder
    private var appContent: some View {
        switch model.appLoadState {
        case .idle:
            ContentUnavailableView(
                "设备不可用",
                systemImage: "exclamationmark.triangle",
                description: Text("请检查手机端的 USB 调试授权。")
            )
        case .loading:
            VStack(spacing: 12) {
                ProgressView()
                Text("正在读取可启动应用…")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView(
                "读取应用失败",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        case .loaded:
            if filteredApps.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(filteredApps) { app in
                    AppRow(app: app, model: model)
                }
                .listStyle(.inset)
            }
        }
    }
}

private struct DeviceHeader: View {
    let device: AndroidDevice
    let appCount: Int

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "iphone.gen3")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.tint)
                .frame(width: 44, height: 44)
                .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(device.displayName)
                    .font(.headline)

                HStack(spacing: 8) {
                    if let manufacturer = device.manufacturer {
                        Text(manufacturer)
                    }
                    if let version = device.androidVersion {
                        Text("Android \(version)")
                    }
                    Text("\(appCount) 个应用")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Label("本地 ADB", systemImage: "lock.shield")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
    }
}

private struct AppRow: View {
    let app: AndroidApp
    @Bindable var model: AppModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "app.fill")
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 34, height: 34)
                .background(.tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 2) {
                Text(app.displayName)
                    .fontWeight(.medium)
                Text(app.packageName)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Spacer()

            Button("投屏") {
                Task {
                    await model.launch(app, mode: .mirror)
                }
            }
            .help("在手机主屏幕中启动，并打开投屏窗口")

            Button("融合") {
                Task {
                    await model.launch(app, mode: .fusion)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.fusionAvailable)
            .help("在 Android 14 虚拟显示中打开独立窗口")
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
    }
}
