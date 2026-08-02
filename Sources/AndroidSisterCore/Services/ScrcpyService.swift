import Foundation

public enum MirrorMode: String, CaseIterable, Sendable {
    case mirror
    case fusion
}

public struct ScrcpyLaunchPlan: Equatable, Sendable {
    public let serial: String
    public let packageName: String
    public let windowTitle: String
    public let mode: MirrorMode

    public init(
        serial: String,
        packageName: String,
        windowTitle: String,
        mode: MirrorMode
    ) {
        self.serial = serial
        self.packageName = packageName
        self.windowTitle = windowTitle
        self.mode = mode
    }

    public var arguments: [String] {
        var result = [
            "--serial=\(serial)",
            "--window-title=\(windowTitle)",
        ]

        if mode == .fusion {
            result.append("--new-display")
        }

        result.append("--start-app=+\(packageName)")
        return result
    }
}

public struct ScrcpySession: Equatable, Sendable {
    public let processIdentifier: Int32
    public let plan: ScrcpyLaunchPlan

    public init(processIdentifier: Int32, plan: ScrcpyLaunchPlan) {
        self.processIdentifier = processIdentifier
        self.plan = plan
    }
}

public struct ScrcpyService: Sendable {
    private let executableURL: URL

    public init(executableURL: URL) {
        self.executableURL = executableURL
    }

    public func launch(_ plan: ScrcpyLaunchPlan) async throws -> ScrcpySession {
        let processIdentifier = try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = executableURL
            process.arguments = plan.arguments
            process.standardOutput = FileHandle.nullDevice
            process.standardError = FileHandle.nullDevice

            try process.run()
            try await Task.sleep(for: .milliseconds(350))

            guard process.isRunning else {
                throw BridgeError.commandFailed(
                    program: "scrcpy",
                    exitCode: process.terminationStatus,
                    message: "进程启动后立即退出。"
                )
            }

            return process.processIdentifier
        }.value

        return ScrcpySession(processIdentifier: processIdentifier, plan: plan)
    }
}
