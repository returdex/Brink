import SwiftUI

@main
struct BrinkApp: App {
    @State private var store = TaskStore.live()

    var body: some Scene {
        WindowGroup("Brink") {
            ContentView(store: store)
                .frame(minWidth: 920, minHeight: 620)
        }
        .handlesExternalEvents(matching: ["tasks"])

        MenuBarExtra("Brink", systemImage: "hourglass.bottomhalf.filled") {
            MenuBarContentView(store: store)
                .frame(width: 360)
        }
        .menuBarExtraStyle(.window)
    }
}
