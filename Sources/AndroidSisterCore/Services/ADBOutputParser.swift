import Foundation

public enum ADBOutputParser {
    public static func parseDevices(_ output: String) -> [AndroidDevice] {
        output
            .split(whereSeparator: \.isNewline)
            .drop(while: { $0.contains("List of devices attached") })
            .compactMap(parseDeviceLine)
    }

    public static func parseLauncherApps(
        launcherOutput: String,
        thirdPartyPackageOutput: String?,
        includeSystemApps: Bool
    ) -> [AndroidApp] {
        let thirdPartyPackages: Set<String>? = thirdPartyPackageOutput.map {
            Set(
                $0.split(whereSeparator: \.isNewline)
                    .compactMap { line in
                        let value = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard value.hasPrefix("package:") else { return nil }
                        return String(value.dropFirst("package:".count))
                    }
            )
        }

        var activityByPackage: [String: String] = [:]

        for rawLine in launcherOutput.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.hasPrefix("Error:"),
                  !line.hasPrefix("No activities"),
                  let separator = line.firstIndex(of: "/")
            else {
                continue
            }

            let packageName = String(line[..<separator])
            guard packageName.contains("."),
                  packageName.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" })
            else {
                continue
            }

            if !includeSystemApps,
               let thirdPartyPackages,
               !thirdPartyPackages.contains(packageName)
            {
                continue
            }

            activityByPackage[packageName] = line
        }

        return activityByPackage
            .map { AndroidApp(packageName: $0.key, activityName: $0.value) }
            .sorted {
                $0.packageName.localizedStandardCompare($1.packageName) == .orderedAscending
            }
    }

    private static func parseDeviceLine(_ rawLine: Substring) -> AndroidDevice? {
        let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty, !line.hasPrefix("*") else { return nil }

        let fields = line.split(whereSeparator: \.isWhitespace).map(String.init)
        guard fields.count >= 2 else { return nil }

        let serial = fields[0]
        let state = parseState(fields[1])
        var attributes: [String: String] = [:]

        for field in fields.dropFirst(2) {
            guard let colon = field.firstIndex(of: ":") else { continue }
            attributes[String(field[..<colon])] = String(field[field.index(after: colon)...])
        }

        return AndroidDevice(
            serial: serial,
            state: state,
            model: attributes["model"],
            product: attributes["product"],
            transportID: attributes["transport_id"]
        )
    }

    private static func parseState(_ rawValue: String) -> AndroidDevice.State {
        if let state = AndroidDevice.State(rawValue: rawValue) {
            return state
        }
        if rawValue == "no" {
            return .noPermissions
        }
        return .unknown
    }
}
