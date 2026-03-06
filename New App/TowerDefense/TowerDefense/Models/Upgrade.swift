import Foundation

typealias UpgradeID = String

enum UpgradeCategory: String, CaseIterable, Identifiable {
    case damage   = "Damage"
    case fireRate = "Fire Rate"
    case range    = "Range"
    case economy  = "Economy"
    case defense  = "Defense"
    case special  = "Special"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .damage:   "⚔️"
        case .fireRate: "⚡"
        case .range:    "🎯"
        case .economy:  "💰"
        case .defense:  "🛡️"
        case .special:  "✨"
        }
    }
}

enum UpgradeEffect {
    case globalDamageBoost(multiplier: Double)
    case armorPierce
    case overcharge                                         // +20% dmg, −10% rate
    case fireRateBoost(multiplier: Double)
    case turboTesla                                         // Tesla 2× fire rate
    case sniperFocus                                        // Sniper 1.5× fire rate
    case rangeBoost(multiplier: Double)
    case goldBonus(multiplier: Double)
    case interest(rate: Double)
    case towerDiscount(factor: Double)                      // resulting cost fraction
    case extraLives(count: Int)
    case shield(count: Int)                                 // blocks per wave
    case lastStand
    case cryoBurst(factor: Double, duration: Double)        // slow speed factor, seconds
    case chainLightning(extra: Int)                         // extra chain targets beyond base 2
    case splashBoost(multiplier: Double)
    case critHit(chance: Double, multiplier: Double)
    case deathNova
    case deathGold
    case seekerMissiles
}

struct UpgradeDefinition: Identifiable {
    let id: UpgradeID
    let name: String
    let description: String
    let category: UpgradeCategory
    let cost: Int
    let effect: UpgradeEffect
    let icon: String
    var requires: UpgradeID? = nil
}

enum UpgradeCatalog {
    static let all: [UpgradeDefinition] = damage + fireRate + range + economy + defense + special

    // MARK: Damage (8)
    static let damage: [UpgradeDefinition] = [
        .init(id: "d1", name: "Iron Tips I",     description: "+8% global damage",        category: .damage, cost: 55,  effect: .globalDamageBoost(multiplier: 1.08), icon: "⚔️"),
        .init(id: "d2", name: "Iron Tips II",    description: "+12% global damage",       category: .damage, cost: 95,  effect: .globalDamageBoost(multiplier: 1.12), icon: "⚔️",  requires: "d1"),
        .init(id: "d3", name: "Steel Core III",  description: "+18% global damage",       category: .damage, cost: 160, effect: .globalDamageBoost(multiplier: 1.18), icon: "🔩",  requires: "d2"),
        .init(id: "d4", name: "Tungsten IV",     description: "+25% global damage",       category: .damage, cost: 260, effect: .globalDamageBoost(multiplier: 1.25), icon: "🔧",  requires: "d3"),
        .init(id: "d5", name: "Armor Pierce",    description: "All towers ignore armor",  category: .damage, cost: 180, effect: .armorPierce,                         icon: "🗡️", requires: "d2"),
        .init(id: "d6", name: "Crit Hit I",      description: "8% chance × 2× damage",   category: .damage, cost: 120, effect: .critHit(chance: 0.08, multiplier: 2.0), icon: "🎰"),
        .init(id: "d7", name: "Crit Hit II",     description: "15% chance × 3× damage",  category: .damage, cost: 200, effect: .critHit(chance: 0.15, multiplier: 3.0), icon: "🎰", requires: "d6"),
        .init(id: "d8", name: "Overcharge",      description: "+20% dmg, −10% rate",     category: .damage, cost: 110, effect: .overcharge,                          icon: "💥"),
    ]

    // MARK: Fire Rate (6)
    static let fireRate: [UpgradeDefinition] = [
        .init(id: "r1", name: "Quick Loader I",   description: "+10% fire rate",           category: .fireRate, cost: 65,  effect: .fireRateBoost(multiplier: 1.10), icon: "⚡"),
        .init(id: "r2", name: "Quick Loader II",  description: "+15% fire rate",           category: .fireRate, cost: 110, effect: .fireRateBoost(multiplier: 1.15), icon: "⚡", requires: "r1"),
        .init(id: "r3", name: "Rapid Reload III", description: "+20% fire rate",           category: .fireRate, cost: 175, effect: .fireRateBoost(multiplier: 1.20), icon: "⚡", requires: "r2"),
        .init(id: "r4", name: "Hair Trigger IV",  description: "+28% fire rate",           category: .fireRate, cost: 270, effect: .fireRateBoost(multiplier: 1.28), icon: "⚡", requires: "r3"),
        .init(id: "r5", name: "Turbo Tesla",      description: "Tesla fires 2× faster",    category: .fireRate, cost: 140, effect: .turboTesla,                    icon: "⚡"),
        .init(id: "r6", name: "Sniper Focus",     description: "Sniper fires 1.5× faster", category: .fireRate, cost: 150, effect: .sniperFocus,                   icon: "🎯"),
    ]

    // MARK: Range (4)
    static let range: [UpgradeDefinition] = [
        .init(id: "g1", name: "Extended Barrel I",  description: "+10% range",  category: .range, cost: 65,  effect: .rangeBoost(multiplier: 1.10), icon: "🎯"),
        .init(id: "g2", name: "Extended Barrel II", description: "+15% range",  category: .range, cost: 110, effect: .rangeBoost(multiplier: 1.15), icon: "🎯", requires: "g1"),
        .init(id: "g3", name: "Long Barrel III",    description: "+22% range",  category: .range, cost: 180, effect: .rangeBoost(multiplier: 1.22), icon: "📡", requires: "g2"),
        .init(id: "g4", name: "Satellite Link IV",  description: "+30% range",  category: .range, cost: 280, effect: .rangeBoost(multiplier: 1.30), icon: "📡", requires: "g3"),
    ]

    // MARK: Economy (7)
    static let economy: [UpgradeDefinition] = [
        .init(id: "e1", name: "Gold Fever I",  description: "+12% gold from kills",    category: .economy, cost: 70,  effect: .goldBonus(multiplier: 1.12), icon: "💰"),
        .init(id: "e2", name: "Gold Fever II", description: "+18% gold from kills",    category: .economy, cost: 120, effect: .goldBonus(multiplier: 1.18), icon: "💰", requires: "e1"),
        .init(id: "e3", name: "Gold Rush III", description: "+25% gold from kills",    category: .economy, cost: 200, effect: .goldBonus(multiplier: 1.25), icon: "💰", requires: "e2"),
        .init(id: "e4", name: "Interest I",    description: "+4% gold each wave",      category: .economy, cost: 130, effect: .interest(rate: 0.04),        icon: "📈"),
        .init(id: "e5", name: "Interest II",   description: "+8% gold each wave",      category: .economy, cost: 210, effect: .interest(rate: 0.08),        icon: "📈", requires: "e4"),
        .init(id: "e6", name: "Bargain Bin",   description: "Towers 12% cheaper",      category: .economy, cost: 90,  effect: .towerDiscount(factor: 0.88), icon: "🏷️"),
        .init(id: "e7", name: "Deep Discount", description: "Towers 22% cheaper",      category: .economy, cost: 160, effect: .towerDiscount(factor: 0.78), icon: "🏷️", requires: "e6"),
    ]

    // MARK: Defense (6)
    static let defense: [UpgradeDefinition] = [
        .init(id: "v1", name: "Reinforced Wall I",  description: "+2 lives",               category: .defense, cost: 90,  effect: .extraLives(count: 2), icon: "❤️"),
        .init(id: "v2", name: "Reinforced Wall II", description: "+3 lives",               category: .defense, cost: 150, effect: .extraLives(count: 3), icon: "❤️", requires: "v1"),
        .init(id: "v3", name: "Fortress III",       description: "+5 lives",               category: .defense, cost: 240, effect: .extraLives(count: 5), icon: "🏰", requires: "v2"),
        .init(id: "v4", name: "Shield I",           description: "Block 1 enemy/wave",     category: .defense, cost: 180, effect: .shield(count: 1),     icon: "🛡️"),
        .init(id: "v5", name: "Shield II",          description: "Block 2 enemies/wave",   category: .defense, cost: 280, effect: .shield(count: 2),     icon: "🛡️", requires: "v4"),
        .init(id: "v6", name: "Last Stand",         description: "2× dmg when ≤3 lives",  category: .defense, cost: 280, effect: .lastStand,             icon: "💪"),
    ]

    // MARK: Special (9)
    static let special: [UpgradeDefinition] = [
        .init(id: "s1", name: "Cryo Burst I",    description: "Frost slows 65% for 2.5s", category: .special, cost: 130, effect: .cryoBurst(factor: 0.35, duration: 2.5), icon: "❄️"),
        .init(id: "s2", name: "Cryo Burst II",   description: "Frost slows 80% for 3.5s", category: .special, cost: 210, effect: .cryoBurst(factor: 0.20, duration: 3.5), icon: "❄️", requires: "s1"),
        .init(id: "s3", name: "Chain Lv.II",     description: "Tesla chains +2 extra",     category: .special, cost: 160, effect: .chainLightning(extra: 2),                icon: "⛈️"),
        .init(id: "s4", name: "Chain Lv.III",    description: "Tesla chains to 6 total",   category: .special, cost: 260, effect: .chainLightning(extra: 4),                icon: "⛈️", requires: "s3"),
        .init(id: "s5", name: "Splash Master I", description: "+30% AoE radius",           category: .special, cost: 130, effect: .splashBoost(multiplier: 1.3),            icon: "💣"),
        .init(id: "s6", name: "Splash Master II",description: "+60% AoE radius",           category: .special, cost: 210, effect: .splashBoost(multiplier: 1.6),            icon: "💣", requires: "s5"),
        .init(id: "s7", name: "Death Nova",      description: "Enemies explode on death",  category: .special, cost: 270, effect: .deathNova,                               icon: "💫"),
        .init(id: "s8", name: "Death Gold",      description: "Nova kills drop gold",      category: .special, cost: 190, effect: .deathGold,                               icon: "✨", requires: "s7"),
        .init(id: "s9", name: "Seeker Missiles", description: "Missiles 40% faster",       category: .special, cost: 160, effect: .seekerMissiles,                          icon: "🚀"),
    ]
}
