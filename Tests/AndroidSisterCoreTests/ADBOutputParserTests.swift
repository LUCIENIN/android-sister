import Testing
@testable import AndroidSisterCore

@Suite("ADB output parser")
struct ADBOutputParserTests {
    @Test("Parses connected, unauthorized, and offline devices")
    func parsesDevices() {
        let output = """
        List of devices attached
        DEVICE123 device usb:123456 product:example model:Example_Phone device:example transport_id:5
        emulator-5554 unauthorized transport_id:7
        192.168.1.12:5555 offline transport_id:9
        """

        let devices = ADBOutputParser.parseDevices(output)

        #expect(devices.count == 3)
        #expect(devices[0].serial == "DEVICE123")
        #expect(devices[0].model == "Example_Phone")
        #expect(devices[0].state == .connected)
        #expect(devices[1].state == .unauthorized)
        #expect(devices[2].state == .offline)
    }

    @Test("Filters launcher activities to third-party packages")
    func filtersLauncherApps() {
        let launcherOutput = """
        3 activities found:
          Activity #0:
            com.android.settings/.Settings
          Activity #1:
            com.example.notes/.MainActivity
          Activity #2:
            com.example.notes/.ShortcutActivity
        """
        let thirdPartyOutput = """
        package:com.example.notes
        package:com.example.background
        """

        let apps = ADBOutputParser.parseLauncherApps(
            launcherOutput: launcherOutput,
            thirdPartyPackageOutput: thirdPartyOutput,
            includeSystemApps: false
        )

        #expect(apps.map(\.packageName) == ["com.example.notes"])
        #expect(apps[0].activityName == "com.example.notes/.ShortcutActivity")
    }

    @Test("Includes system launchers when requested")
    func includesSystemApps() {
        let launcherOutput = """
        2 activities found:
          Activity #0:
            com.android.settings/.Settings
          Activity #1:
            com.example.notes/.MainActivity
        """

        let apps = ADBOutputParser.parseLauncherApps(
            launcherOutput: launcherOutput,
            thirdPartyPackageOutput: nil,
            includeSystemApps: true
        )

        #expect(apps.map(\.packageName) == [
            "com.android.settings",
            "com.example.notes",
        ])
    }
}
