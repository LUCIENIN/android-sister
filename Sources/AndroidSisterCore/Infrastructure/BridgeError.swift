import Foundation

public enum BridgeError: LocalizedError, Equatable, Sendable {
    case executableNotFound(String)
    case commandFailed(program: String, exitCode: Int32, message: String)
    case deviceUnavailable(String)
    case fusionRequiresAndroid14

    public var errorDescription: String? {
        switch self {
        case .executableNotFound(let name):
            return "未找到 \(name)。请在设置中指定可执行文件路径。"
        case .commandFailed(let program, let exitCode, let message):
            let detail = message.trimmingCharacters(in: .whitespacesAndNewlines)
            if detail.isEmpty {
                return "\(program) 执行失败（退出码 \(exitCode)）。"
            }
            return "\(program) 执行失败（退出码 \(exitCode)）：\(detail)"
        case .deviceUnavailable(let serial):
            return "设备 \(serial) 当前不可用，请检查 USB 调试授权。"
        case .fusionRequiresAndroid14:
            return "融合窗口需要 Android 14 或更高版本。"
        }
    }
}
