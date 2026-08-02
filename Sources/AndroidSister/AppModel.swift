import AndroidSisterCore
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    struct Notice: Identifiable, Equatable {
        enum Kind {
            case information
            case error
        }

        let id = UUID()
        let kind: Kind
        let title: String
        let message: String
    }

    var devices: [AndroidDevice] = []
    var selectedDeviceID: String?
    var apps: [AndroidApp] = []
    var deviceLoadState: LoadState = .idle
    var appLoadState: LoadState = .idle
    var notice: Notice?

    var selectedDevice: AndroidDevice? {
        devices.first { $0.id == selectedDeviceID }
    }

    var fusionAvailable: Bool {
        guard let device = selectedDevice, device.state.isUsable else { return false }
        guard let sdkLevel = device.sdkLevel else { return true }
        return sdkLevel >= 34
    }

    func refreshAll() async {
        deviceLoadState = .loading
        notice = nil

        do {
            let adb = try makeADBService()
            var discoveredDevices = try await adb.devices()

            let previousSelection = selectedDeviceID
            let selected = discoveredDevices.first { $0.id == previousSelection }
                ?? discoveredDevices.first { $0.state.isUsable }
                ?? discoveredDevices.first

            if let selected, selected.state.isUsable {
                let facts = try await adb.facts(for: selected.serial)
                if let index = discoveredDevices.firstIndex(where: { $0.id == selected.id }) {
                    discoveredDevices[index] = selected.applying(facts)
                }
            }

            devices = discoveredDevices
            selectedDeviceID = selected?.id
            deviceLoadState = .loaded

            if selectedDevice?.state.isUsable == true {
                await refreshApps()
            } else {
                apps = []
                appLoadState = .idle
            }
        } catch is CancellationError {
            return
        } catch {
            devices = []
            apps = []
            selectedDeviceID = nil
            deviceLoadState = .failed(error.localizedDescription)
            notice = Notice(
                kind: .error,
                title: "无法读取设备",
                message: error.localizedDescription
            )
        }
    }

    func selectDevice(_ id: String?) async {
        selectedDeviceID = id
        apps = []

        if let id,
           let index = devices.firstIndex(where: { $0.id == id }),
           devices[index].state.isUsable,
           devices[index].sdkLevel == nil,
           let adb = try? makeADBService(),
           let facts = try? await adb.facts(for: id)
        {
            devices[index] = devices[index].applying(facts)
        }

        await refreshApps()
    }

    func refreshApps() async {
        guard let device = selectedDevice, device.state.isUsable else {
            apps = []
            appLoadState = .idle
            return
        }

        appLoadState = .loading

        do {
            let adb = try makeADBService()
            apps = try await adb.launcherApps(
                for: device.serial,
                includeSystemApps: UserDefaults.standard.bool(forKey: PreferenceKey.includeSystemApps)
            )
            appLoadState = .loaded
        } catch is CancellationError {
            return
        } catch {
            apps = []
            appLoadState = .failed(error.localizedDescription)
            notice = Notice(
                kind: .error,
                title: "无法读取应用",
                message: error.localizedDescription
            )
        }
    }

    func launch(_ app: AndroidApp, mode: MirrorMode) async {
        guard let device = selectedDevice, device.state.isUsable else {
            notice = Notice(
                kind: .error,
                title: "设备不可用",
                message: "请先连接并授权一台 Android 设备。"
            )
            return
        }

        if mode == .fusion, let sdkLevel = device.sdkLevel, sdkLevel < 34 {
            notice = Notice(
                kind: .error,
                title: "无法启动融合窗口",
                message: BridgeError.fusionRequiresAndroid14.localizedDescription
            )
            return
        }

        do {
            let scrcpy = try makeScrcpyService()
            let title = "\(app.displayName) · \(device.displayName)"
            let plan = ScrcpyLaunchPlan(
                serial: device.serial,
                packageName: app.packageName,
                windowTitle: title,
                mode: mode
            )
            let session = try await scrcpy.launch(plan)
            notice = Notice(
                kind: .information,
                title: mode == .fusion ? "融合窗口已启动" : "投屏窗口已启动",
                message: "\(app.packageName)\n进程 PID：\(session.processIdentifier)"
            )
        } catch {
            notice = Notice(
                kind: .error,
                title: "启动失败",
                message: error.localizedDescription
            )
        }
    }

    private func makeADBService() throws -> ADBService {
        let overridePath = UserDefaults.standard.string(forKey: PreferenceKey.adbPath)
        guard let executableURL = ExecutableResolver.resolve(
            named: "adb",
            overridePath: overridePath
        ) else {
            throw BridgeError.executableNotFound("ADB")
        }
        return ADBService(executableURL: executableURL)
    }

    private func makeScrcpyService() throws -> ScrcpyService {
        let overridePath = UserDefaults.standard.string(forKey: PreferenceKey.scrcpyPath)
        guard let executableURL = ExecutableResolver.resolve(
            named: "scrcpy",
            overridePath: overridePath
        ) else {
            throw BridgeError.executableNotFound("scrcpy")
        }
        return ScrcpyService(executableURL: executableURL)
    }
}

enum PreferenceKey {
    static let adbPath = "adbPath"
    static let scrcpyPath = "scrcpyPath"
    static let includeSystemApps = "includeSystemApps"
}
