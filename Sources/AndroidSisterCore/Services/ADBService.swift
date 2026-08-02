import Foundation

public struct ADBService: Sendable {
    private let executableURL: URL
    private let runner: any CommandRunning

    public init(executableURL: URL, runner: any CommandRunning = ProcessCommandRunner()) {
        self.executableURL = executableURL
        self.runner = runner
    }

    public func devices() async throws -> [AndroidDevice] {
        let result = try await runner.run(
            executableURL: executableURL,
            arguments: ["devices", "-l"],
            environment: nil
        )
        try validate(result, program: "ADB")
        return ADBOutputParser.parseDevices(result.standardOutput)
    }

    public func facts(for serial: String) async throws -> AndroidDeviceFacts {
        async let manufacturer = getProperty("ro.product.manufacturer", serial: serial)
        async let model = getProperty("ro.product.model", serial: serial)
        async let androidVersion = getProperty("ro.build.version.release", serial: serial)
        async let sdkLevel = getProperty("ro.build.version.sdk", serial: serial)

        let values = try await (
            manufacturer,
            model,
            androidVersion,
            sdkLevel
        )

        return AndroidDeviceFacts(
            manufacturer: nilIfEmpty(values.0),
            model: nilIfEmpty(values.1),
            androidVersion: nilIfEmpty(values.2),
            sdkLevel: Int(values.3.trimmingCharacters(in: .whitespacesAndNewlines))
        )
    }

    public func launcherApps(
        for serial: String,
        includeSystemApps: Bool
    ) async throws -> [AndroidApp] {
        let launcherResult = try await runner.run(
            executableURL: executableURL,
            arguments: [
                "-s", serial,
                "shell", "cmd", "package", "query-activities",
                "-a", "android.intent.action.MAIN",
                "-c", "android.intent.category.LAUNCHER",
                "--brief",
            ],
            environment: nil
        )
        try validate(launcherResult, program: "ADB")

        let thirdPartyOutput: String?
        if includeSystemApps {
            thirdPartyOutput = nil
        } else {
            let thirdPartyResult = try await runner.run(
                executableURL: executableURL,
                arguments: ["-s", serial, "shell", "pm", "list", "packages", "-3"],
                environment: nil
            )
            try validate(thirdPartyResult, program: "ADB")
            thirdPartyOutput = thirdPartyResult.standardOutput
        }

        return ADBOutputParser.parseLauncherApps(
            launcherOutput: launcherResult.standardOutput,
            thirdPartyPackageOutput: thirdPartyOutput,
            includeSystemApps: includeSystemApps
        )
    }

    private func getProperty(_ property: String, serial: String) async throws -> String {
        let result = try await runner.run(
            executableURL: executableURL,
            arguments: ["-s", serial, "shell", "getprop", property],
            environment: nil
        )
        try validate(result, program: "ADB")
        return result.standardOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validate(_ result: CommandResult, program: String) throws {
        guard result.exitCode == 0 else {
            throw BridgeError.commandFailed(
                program: program,
                exitCode: result.exitCode,
                message: result.standardError
            )
        }
    }

    private func nilIfEmpty(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
