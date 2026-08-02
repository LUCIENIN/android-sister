import Foundation
import Testing
@testable import AndroidSisterCore

@Suite("Process command runner")
struct CommandRunnerTests {
    @Test("Captures standard output without a shell")
    func capturesOutput() async throws {
        let runner = ProcessCommandRunner()

        let result = try await runner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/printf"),
            arguments: ["hello AndroidSister"],
            environment: nil
        )

        #expect(result.exitCode == 0)
        #expect(result.standardOutput == "hello AndroidSister")
        #expect(result.standardError.isEmpty)
    }
}
