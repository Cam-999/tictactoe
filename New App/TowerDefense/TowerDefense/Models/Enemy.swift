import Foundation
import SpriteKit

enum EnemyType: String, CaseIterable {
    case grunt, armored, swift, healer, splitter, titan

    var displayName: String { rawValue.capitalized }

    var baseHP: CGFloat {
        switch self {
        case .grunt:    80
        case .armored:  300
        case .swift:    60
        case .healer:   120
        case .splitter: 200
        case .titan:    2000
        }
    }

    var baseSpeed: CGFloat {
        switch self {
        case .grunt:    80
        case .armored:  50
        case .swift:    180
        case .healer:   70
        case .splitter: 65
        case .titan:    40
        }
    }

    var goldReward: Int {
        switch self {
        case .grunt:    10
        case .armored:  25
        case .swift:    15
        case .healer:   30
        case .splitter: 20
        case .titan:    200
        }
    }

    /// Fraction of damage actually received (1.0 = full; armored = 0.5 except vs sniper)
    var damageReduction: CGFloat {
        self == .armored ? 0.5 : 1.0
    }

    /// HP regen per second (healer only)
    var regenPerSecond: CGFloat { self == .healer ? 5 : 0 }

    /// Splitter spawns 2 grunts on death
    var splitCount: Int { self == .splitter ? 2 : 0 }

    /// Titan is immune to slow
    var slowImmune: Bool { self == .titan }

    var size: CGSize {
        switch self {
        case .titan: CGSize(width: 36, height: 36)
        case .armored: CGSize(width: 28, height: 28)
        default: CGSize(width: 22, height: 22)
        }
    }

    var color: SKColor {
        switch self {
        case .grunt:    SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        case .armored:  SKColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1)
        case .swift:    SKColor(red: 0.9, green: 0.8, blue: 0.1, alpha: 1)
        case .healer:   SKColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        case .splitter: SKColor(red: 0.9, green: 0.4, blue: 0.1, alpha: 1)
        case .titan:    SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        }
    }
}
