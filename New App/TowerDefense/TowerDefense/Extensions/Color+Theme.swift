import SwiftUI
import SpriteKit

extension Color {
    static let tdBackground    = Color(hex: 0x070B14)
    static let tdSurface       = Color(hex: 0x0D1526)
    static let tdElevated      = Color(hex: 0x111E35)
    static let tdPath          = Color(hex: 0x0F2240)
    static let tdAccentBlue    = Color(hex: 0x1A7AFF)
    static let tdAccentTeal    = Color(hex: 0x00CED1)
    static let tdAccentPurple  = Color(hex: 0x7B2FBE)
    static let tdAccentAmber   = Color(hex: 0xE08C00)
    static let tdDanger        = Color(hex: 0xC0392B)
    static let tdTextPrimary   = Color(hex: 0xE8EBF0)
    static let tdTextSecondary = Color(hex: 0x6B7FA3)

    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8)  & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension SKColor {
    static let tdBackground    = SKColor(hex: 0x070B14)
    static let tdSurface       = SKColor(hex: 0x0D1526)
    static let tdElevated      = SKColor(hex: 0x111E35)
    static let tdPath          = SKColor(hex: 0x0F2240)
    static let tdAccentBlue    = SKColor(hex: 0x1A7AFF)
    static let tdAccentTeal    = SKColor(hex: 0x00CED1)
    static let tdAccentPurple  = SKColor(hex: 0x7B2FBE)
    static let tdAccentAmber   = SKColor(hex: 0xE08C00)
    static let tdDanger        = SKColor(hex: 0xC0392B)
    static let tdTextPrimary   = SKColor(hex: 0xE8EBF0)
    static let tdTextSecondary = SKColor(hex: 0x6B7FA3)

    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8)  & 0xFF) / 255
        let b = CGFloat( hex        & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
