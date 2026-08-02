import Foundation

public struct CommandResult: Equatable, Sendable {
    public let exitCode: Int32
    public let standardOutput: String
    public let standardError: String

    public init(exitCode: Int32, standardOutput: String, standardError: String) {
        self.exitCode = exitCode
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}

public protocol CommandRunning: Sendable {
    func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]?
    ) async throws -> CommandResult
}

public struct ProcessCommandRunner: CommandRunning {
    public init() {}

    public func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String]? = nil
    ) async throws -> CommandResult {
        try await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let temporaryDirectory = fileManager.temporaryDirectory
                .appendingPathComponent("AndroidSister-\(UUID().uuidString)", isDirectory: true)
            let standardOutputURL = temporaryDirectory.appendingPathComponent("stdout")
            let standardErrorURL = temporaryDirectory.appendingPathComponent("stderr")

            try fileManager.createDirectory(
                at: temporaryDirectory,
                withIntermediateDirectories: true
            )
            fileManager.createFile(atPath: standardOutputURL.path, contents: nil)
            fileManager.createFile(atPath: standardErrorURL.path, contents: nil)

            defer {
                try? fileManager.removeItem(at: temporaryDirectory)
            }

            let process = Process()
            let standardOutput = try FileHandle(forWritingTo: standardOutputURL)
            let standardError = try FileHandle(forWritingTo: standardErrorURL)

            process.executableURL = executableURL
            process.arguments = arguments
            process.standardOutput = standardOutput
            process.standardError = standardError

            if let environment {
                process.environment = environment
            }

            try process.run()
            process.waitUntilExit()

            try standardOutput.close()
            try standardError.close()

            let outputData = try Data(contentsOf: standardOutputURL)
            let errorData = try Data(contentsOf: standardErrorURL)

            return CommandResult(
                exitCode: process.terminationStatus,
                standardOutput: String(decoding: outputData, as: UTF8.self),
                standardError: String(decoding: errorData, as: UTF8.self)
            )
        }.value
    }
}
