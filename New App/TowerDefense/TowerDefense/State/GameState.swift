import Foundation
import Combine

@MainActor
final class GameState: ObservableObject {
    @Published var wave: Int = 0
    @Published var gold: Int = 150
    @Published var lives: Int = 20
    @Published var score: Int = 0
    @Published var selectedTowerType: TowerType? = .cannon
    @Published var ownedUpgrades: Set<UpgradeID> = []
    @Published var shopIsOpen: Bool = false
    @Published var waveInProgress: Bool = false
    @Published var shieldsRemaining: Int = 0

    // MARK: - Computed upgrade effects

    var globalDamageMultiplier: Double {
        var mult = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .globalDamageBoost(let m) = def.effect { mult *= m }
        }
        if hasUpgrade("d8") { mult *= 1.20 }          // Overcharge: +20% dmg
        if hasUpgrade("v6") && lives <= 3 { mult *= 2.0 } // Last Stand
        return mult
    }

    var globalFireRateMultiplier: Double {
        var mult = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .fireRateBoost(let m) = def.effect { mult *= m }
        }
        if hasUpgrade("d8") { mult *= 0.90 }           // Overcharge: −10% rate
        return mult
    }

    var globalRangeMultiplier: Double {
        var mult = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .rangeBoost(let m) = def.effect { mult *= m }
        }
        return mult
    }

    var goldBonusMultiplier: Double {
        var mult = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .goldBonus(let m) = def.effect { mult *= m }
        }
        return mult
    }

    /// Resulting cost factor (0.78 = 22% off). Default 1.0.
    var towerCostDiscount: Double {
        var factor = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .towerDiscount(let f) = def.effect { factor = min(factor, f) }
        }
        return factor
    }

    var interestRate: Double {
        var rate = 0.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .interest(let r) = def.effect { rate = max(rate, r) }
        }
        return rate
    }

    var critChance: Double {
        var chance = 0.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .critHit(let c, _) = def.effect { chance = max(chance, c) }
        }
        return chance
    }

    var critMultiplier: Double {
        var mult = 2.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .critHit(_, let m) = def.effect { mult = max(mult, m) }
        }
        return mult
    }

    var splashMultiplier: Double {
        var mult = 1.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .splashBoost(let m) = def.effect { mult = max(mult, m) }
        }
        return mult
    }

    /// Speed factor applied to frozen enemies (lower = slower). Default 0.5.
    var cryoFactor: Double {
        var factor = 0.5
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .cryoBurst(let f, _) = def.effect { factor = min(factor, f) }
        }
        return factor
    }

    /// Slow duration in seconds. Default 2.0.
    var cryoDuration: Double {
        var dur = 2.0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .cryoBurst(_, let d) = def.effect { dur = max(dur, d) }
        }
        return dur
    }

    /// Extra chain targets beyond Tesla's base 2. Default 0.
    var chainExtra: Int {
        var extra = 0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .chainLightning(let e) = def.effect { extra = max(extra, e) }
        }
        return extra
    }

    /// Maximum shields per wave. Default 0.
    var shieldMax: Int {
        var maxShields = 0
        for id in ownedUpgrades {
            guard let def = UpgradeCatalog.all.first(where: { $0.id == id }) else { continue }
            if case .shield(let c) = def.effect { maxShields = max(maxShields, c) }
        }
        return maxShields
    }

    /// Missile tracking speed (pts/sec). Default 250, 350 with Seeker Missiles.
    var missileSpeed: CGFloat {
        hasUpgrade("s9") ? 350 : 250
    }

    // MARK: - Helpers

    func hasUpgrade(_ id: UpgradeID) -> Bool { ownedUpgrades.contains(id) }

    func effectiveCost(for type: TowerType) -> Int {
        Int(Double(type.cost) * towerCostDiscount)
    }

    func canAfford(_ type: TowerType) -> Bool {
        gold >= effectiveCost(for: type)
    }

    func purchase(tower type: TowerType) -> Bool {
        let cost = effectiveCost(for: type)
        guard gold >= cost else { return false }
        gold -= cost
        return true
    }

    func earnGold(_ base: Int) {
        let earned = Int(Double(base) * goldBonusMultiplier)
        gold += earned
        score += earned
    }

    func loseLife() {
        lives = max(0, lives - 1)
    }

    func applyInterest() {
        guard interestRate > 0 else { return }
        gold += Int(Double(gold) * interestRate)
    }

    func resetShields() {
        shieldsRemaining = shieldMax
    }

    func reset() {
        wave = 0
        gold = 150
        lives = 20
        score = 0
        selectedTowerType = .cannon
        ownedUpgrades = []
        shopIsOpen = false
        waveInProgress = false
        shieldsRemaining = 0
    }
}
