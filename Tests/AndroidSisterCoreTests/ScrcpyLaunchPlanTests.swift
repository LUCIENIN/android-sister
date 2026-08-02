import Testing
@testable import AndroidSisterCore

@Suite("scrcpy launch plans")
struct ScrcpyLaunchPlanTests {
    @Test("Regular mirror starts the selected app on the main display")
    func mirrorArguments() {
        let plan = ScrcpyLaunchPlan(
            serial: "SERIAL-1",
            packageName: "com.example.notes",
            windowTitle: "Notes · Phone",
            mode: .mirror
        )

        #expect(plan.arguments == [
            "--serial=SERIAL-1",
            "--window-title=Notes · Phone",
            "--start-app=+com.example.notes",
        ])
    }

    @Test("Fusion mode creates a new display before starting the app")
    func fusionArguments() {
        let plan = ScrcpyLaunchPlan(
            serial: "SERIAL-1",
            packageName: "com.example.notes",
            windowTitle: "Notes · Phone",
            mode: .fusion
        )

        #expect(plan.arguments == [
            "--serial=SERIAL-1",
            "--window-title=Notes · Phone",
            "--new-display",
            "--start-app=+com.example.notes",
        ])
    }
}
