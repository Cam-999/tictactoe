import SwiftUI

struct ShopItemRow: View {
    let definition: UpgradeDefinition
    let isOwned: Bool
    let canPurchase: Bool
    let onBuy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(definition.icon)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(definition.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.tdTextPrimary)
                    if let req = definition.requires,
                       !isOwned {
                        Text("Requires: \(req)")
                            .font(.caption2)
                            .foregroundColor(.tdDanger)
                    }
                }
                Spacer()
                if isOwned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }

            Text(definition.description)
                .font(.caption)
                .foregroundColor(.tdTextSecondary)
                .lineLimit(2)

            HStack {
                Spacer()
                Button(action: onBuy) {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.caption)
                            .foregroundColor(.tdAccentAmber)
                        Text("\(definition.cost)g")
                            .font(.caption.bold())
                            .foregroundColor(.tdTextPrimary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(buttonColor)
                    .cornerRadius(8)
                }
                .disabled(!canPurchase || isOwned)
            }
        }
        .padding(12)
        .background(Color.tdElevated)
        .cornerRadius(12)
        .opacity(isOwned || canPurchase ? 1.0 : 0.55)
    }

    private var buttonColor: Color {
        if isOwned { return Color.green.opacity(0.25) }
        if canPurchase { return Color.tdAccentBlue }
        return Color.tdTextSecondary.opacity(0.3)
    }
}
