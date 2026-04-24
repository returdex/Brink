import SwiftUI

enum BrinkTheme {
    static let detailSurface = Color(nsColor: .windowBackgroundColor)
    static let panelSurface = Color(nsColor: .controlBackgroundColor)
    static let elevatedSurface = Color(nsColor: .textBackgroundColor)
    static let secondarySurface = Color(nsColor: .underPageBackgroundColor)
    static let separator = Color(nsColor: .separatorColor)
    static let shadow = Color.black.opacity(0.12)

    static func detailGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    secondarySurface.opacity(0.92),
                    detailSurface,
                ]
                : [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    detailSurface,
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardBackground(isSelected: Bool) -> Color {
        isSelected ? .accentColor.opacity(0.16) : elevatedSurface.opacity(0.9)
    }

    static func cardBorder(isSelected: Bool) -> Color {
        isSelected ? .accentColor.opacity(0.4) : separator.opacity(0.65)
    }

    static func progressTrack(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white.opacity(0.12) : .black.opacity(0.06)
    }
}

@main
struct BrinkApp: App {
    @State private var store = TaskStore.live()

    var body: some Scene {
        WindowGroup("Brink") {
            ContentView(store: store)
                .frame(minWidth: 920, minHeight: 620)
        }

        MenuBarExtra("Brink", systemImage: "hourglass.bottomhalf.filled") {
            MenuBarContentView(store: store)
                .frame(width: 360)
        }
        .menuBarExtraStyle(.window)
    }
}
