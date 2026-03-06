import SwiftUI

struct ShopView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var shopState: ShopState
    @EnvironmentObject var appState: AppState

    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.tdBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Gold display
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.tdAccentAmber)
                        Text("\(gameState.gold) gold")
                            .font(.headline.bold())
                            .foregroundColor(.tdTextPrimary)
                        Spacer()
                        Text("Wave \(gameState.wave) Complete")
                            .font(.subheadline)
                            .foregroundColor(.tdTextSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.tdSurface)

                    // Category tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(UpgradeCategory.allCases) { cat in
                                categoryTab(cat)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .background(Color.tdSurface)

                    // Upgrade grid
                    let upgrades = UpgradeCatalog.all.filter { $0.category == shopState.selectedCategory }
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(upgrades) { def in
                                ShopItemRow(
                                    definition: def,
                                    isOwned: gameState.hasUpgrade(def.id),
                                    canPurchase: shopState.canPurchase(def, gameState: gameState)
                                ) {
                                    shopState.purchase(def, gameState: gameState)
                                }
                            }
                        }
                        .padding(16)
                    }

                    // Continue button
                    Button {
                        gameState.shopIsOpen = false
                        onContinue()
                    } label: {
                        Text("CONTINUE")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.tdAccentBlue)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Upgrade Shop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.tdSurface, for: .navigationBar)
        }
    }

    private func categoryTab(_ category: UpgradeCategory) -> some View {
        let isSelected = shopState.selectedCategory == category
        return Button {
            shopState.selectedCategory = category
        } label: {
            HStack(spacing: 4) {
                Text(category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(isSelected ? .white : .tdTextSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.tdAccentBlue : Color.tdElevated)
            .cornerRadius(8)
        }
    }
}
