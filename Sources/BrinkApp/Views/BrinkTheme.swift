import AppKit
import SwiftUI

enum BrinkTheme {
    static let canvasTop = Color(
        light: NSColor(calibratedRed: 0.95, green: 0.97, blue: 0.99, alpha: 1),
        dark: NSColor(calibratedRed: 0.10, green: 0.11, blue: 0.14, alpha: 1)
    )
    static let canvasBottom = Color(
        light: NSColor(calibratedRed: 1.00, green: 1.00, blue: 1.00, alpha: 1),
        dark: NSColor(calibratedRed: 0.06, green: 0.07, blue: 0.09, alpha: 1)
    )
    static let panelFill = Color(
        light: NSColor.white.withAlphaComponent(0.84),
        dark: NSColor(calibratedWhite: 0.16, alpha: 0.88)
    )
    static let elevatedPanelFill = Color(
        light: NSColor.white.withAlphaComponent(0.94),
        dark: NSColor(calibratedWhite: 0.19, alpha: 0.94)
    )
    static let subtleFill = Color(
        light: NSColor.black.withAlphaComponent(0.06),
        dark: NSColor.white.withAlphaComponent(0.08)
    )
    static let stroke = Color(
        light: NSColor.black.withAlphaComponent(0.07),
        dark: NSColor.white.withAlphaComponent(0.10)
    )
    static let strongStroke = Color(
        light: NSColor.black.withAlphaComponent(0.10),
        dark: NSColor.white.withAlphaComponent(0.16)
    )
    static let shadow = Color(
        light: NSColor.black.withAlphaComponent(0.05),
        dark: NSColor.black.withAlphaComponent(0.28)
    )
}

extension Color {
    init(light: NSColor, dark: NSColor) {
        self.init(nsColor: NSColor(name: nil) { appearance in
            switch appearance.bestMatch(from: [.darkAqua, .aqua]) {
            case .darkAqua:
                dark
            default:
                light
            }
        })
    }
}

struct BrinkPanel: ViewModifier {
    let cornerRadius: CGFloat
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated ? BrinkTheme.elevatedPanelFill : BrinkTheme.panelFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(elevated ? BrinkTheme.strongStroke : BrinkTheme.stroke, lineWidth: 1)
            )
            .shadow(color: BrinkTheme.shadow, radius: elevated ? 22 : 16, y: elevated ? 10 : 8)
    }
}

extension View {
    func brinkPanel(cornerRadius: CGFloat = 24, elevated: Bool = false) -> some View {
        modifier(BrinkPanel(cornerRadius: cornerRadius, elevated: elevated))
    }
}
