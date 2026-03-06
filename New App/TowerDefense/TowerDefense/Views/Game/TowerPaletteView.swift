import SwiftUI

struct TowerPaletteView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TowerType.allCases) { type in
                    TowerCell(type: type, isSelected: gameState.selectedTowerType == type)
                        .onTapGesture { gameState.selectedTowerType = type }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color.tdSurface.opacity(0.95))
    }
}

private struct TowerCell: View {
    let type: TowerType
    let isSelected: Bool
    @EnvironmentObject var gameState: GameState

    var body: some View {
        VStack(spacing: 4) {
            Text(type.icon)
                .font(.title2)
            Text(type.displayName)
                .font(.caption2.bold())
                .foregroundColor(.tdTextPrimary)
            Text("\(gameState.effectiveCost(for: type))g")
                .font(.caption2)
                .foregroundColor(gameState.canAfford(type) ? .tdAccentAmber : .tdDanger)
        }
        .frame(width: 64, height: 72)
        .background(isSelected ? Color.tdAccentBlue.opacity(0.3) : Color.tdElevated)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.tdAccentBlue : Color.clear, lineWidth: 2)
        )
        .opacity(gameState.canAfford(type) ? 1.0 : 0.5)
    }
}
