import Foundation

public struct AndroidApp: Identifiable, Hashable, Sendable {
    public let packageName: String
    public let activityName: String?

    public var id: String { packageName }

    public init(packageName: String, activityName: String? = nil) {
        self.packageName = packageName
        self.activityName = activityName
    }

    public var displayName: String {
        let candidate = packageName
            .split(separator: ".")
            .last
            .map(String.init) ?? packageName

        return candidate
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}
