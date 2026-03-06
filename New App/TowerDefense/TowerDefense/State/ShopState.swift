import Foundation

@MainActor
final class ShopState: ObservableObject {
    @Published var selectedCategory: UpgradeCategory = .damage

    func canPurchase(_ def: UpgradeDefinition, gameState: GameState) -> Bool {
        guard !gameState.hasUpgrade(def.id) else { return false }
        if let req = def.requires, !gameState.hasUpgrade(req) { return false }
        return gameState.gold >= def.cost
    }

    func purchase(_ def: UpgradeDefinition, gameState: GameState) {
        guard canPurchase(def, gameState: gameState) else { return }
        gameState.gold -= def.cost

        // Apply immediate effects
        if case .extraLives(let count) = def.effect {
            gameState.lives += count
        }

        gameState.ownedUpgrades.insert(def.id)
    }
}
