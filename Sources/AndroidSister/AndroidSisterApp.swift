import SwiftUI

@main
struct AndroidSisterApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView(model: model)
                .frame(minWidth: 860, minHeight: 560)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1040, height: 700)

        Settings {
            SettingsView()
        }
    }
}
