import Foundation
import SpriteKit

enum TowerType: String, CaseIterable, Identifiable {
    case cannon, sniper, tesla, frost, missile

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cannon:  "Cannon"
        case .sniper:  "Sniper"
        case .tesla:   "Tesla"
        case .frost:   "Frost"
        case .missile: "Missile"
        }
    }

    var icon: String {
        switch self {
        case .cannon:  "🔵"
        case .sniper:  "🟢"
        case .tesla:   "🟣"
        case .frost:   "🔷"
        case .missile: "🔴"
        }
    }

    var baseDamage: CGFloat {
        switch self {
        case .cannon:  40
        case .sniper:  120
        case .tesla:   20
        case .frost:   10
        case .missile: 80
        }
    }

    var fireRate: TimeInterval {   // seconds between shots
        switch self {
        case .cannon:  1.0 / 0.8
        case .sniper:  1.0 / 0.3
        case .tesla:   1.0 / 3.0
        case .frost:   1.0 / 1.5
        case .missile: 1.0 / 0.5
        }
    }

    var range: CGFloat {
        switch self {
        case .cannon:  120
        case .sniper:  250
        case .tesla:   90
        case .frost:   100
        case .missile: 200
        }
    }

    var cost: Int {
        switch self {
        case .cannon:  100
        case .sniper:  150
        case .tesla:   120
        case .frost:   80
        case .missile: 200
        }
    }

    var color: SKColor {
        switch self {
        case .cannon:  .tdAccentBlue
        case .sniper:  SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1)
        case .tesla:   .tdAccentPurple
        case .frost:   .tdAccentTeal
        case .missile: .tdDanger
        }
    }

    /// Does this tower ignore armor?
    var ignoresArmor: Bool { self == .sniper }

    /// AoE splash radius (0 = no splash)
    var splashRadius: CGFloat {
        switch self {
        case .cannon:  40
        case .missile: 60
        default:       0
        }
    }

    /// Number of chain targets (Tesla only)
    var chainCount: Int { self == .tesla ? 2 : 0 }

    /// Slow factor applied by Frost (1.0 = no slow)
    var slowFactor: CGFloat { self == .frost ? 0.5 : 1.0 }
    var slowDuration: TimeInterval { self == .frost ? 2.0 : 0 }
}
