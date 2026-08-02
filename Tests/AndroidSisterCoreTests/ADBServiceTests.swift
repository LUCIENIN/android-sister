import Foundation
import Testing
@testable import AndroidSisterCore

@Suite("ADB service")
struct ADBServiceTests {
    @Test("Builds a third-party launcher app list from command results")
    func loadsLauncherApps() async throws {
        let runner = StubCommandRunner(results: [
            CommandResult(
                exitCode: 0,
                standardOutput: """
                2 activities found:
                  Activity #0:
                    com.android.settings/.Settings
                  Activity #1:
                    com.example.notes/.MainActivity
                """,
                standardError: ""
            ),
            CommandResult(
                exitCode: 0,
                standardOutput: "package:com.example.notes\n",
                standardError: ""
            ),
        ])
        let service = ADBService(
            executableURL: URL(fileURLWithPath: "/test/adb"),
            runner: runner
        )

        let apps = try await service.launcherApps(
            for: "SERIAL-1",
            includeSystemApps: false
        )

        #expect(apps.map(\.packageName) == ["com.example.notes"])
        let invocations = await runner.invocations
        #expect(invocations.count == 2)
        #expect(invocations[0].arguments.prefix(3) == ["-s", "SERIAL-1", "shell"])
        #expect(invocations[1].arguments.suffix(3) == ["list", "packages", "-3"])
    }

    @Test("Surfaces an ADB command failure with stderr")
    func reportsCommandFailure() async {
        let runner = StubCommandRunner(results: [
            CommandResult(
                exitCode: 1,
                standardOutput: "",
                standardError: "device unauthorized"
            ),
        ])
        let service = ADBService(
            executableURL: URL(fileURLWithPath: "/test/adb"),
            runner: runner
        )

        await #expect(throws: BridgeError.self) {
            _ = try await service.devices()
        }
    }
}

private actor StubCommandRunner: CommandRunning {
    struct Invocation: Sendable {
        let executableURL: URL
        let arguments: [String]
        let environment: [String: String]?
    }

    private var results: [CommandResult]
    private(set) var invocations: [Invocation] = []

    init(results: [CommandResult]) {
        self.results = results
    }

    func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]?
    ) async throws -> CommandResult {
        invocations.append(
            Invocation(
                executableURL: executableURL,
                arguments: arguments,
                environment: environment
            )
        )
        return results.removeFirst()
    }
}
