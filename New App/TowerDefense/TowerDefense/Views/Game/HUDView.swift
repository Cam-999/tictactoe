import SwiftUI

struct HUDView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject private var sound = SoundSystem.shared

    var body: some View {
        HStack(spacing: 0) {
            // Lives
            hudPill(icon: "heart.fill", value: "\(gameState.lives)", color: .tdDanger)

            Spacer()

            // Wave
            VStack(spacing: 2) {
                Text("WAVE")
                    .font(.caption2.bold())
                    .foregroundColor(.tdTextSecondary)
                Text("\(gameState.wave) / 100")
                    .font(.headline.bold())
                    .foregroundColor(.tdTextPrimary)
            }

            Spacer()

            // Gold
            hudPill(icon: "circle.fill", value: "\(gameState.gold)", color: .tdAccentAmber)

            // Mute button
            Button {
                sound.isMuted.toggle()
            } label: {
                Image(systemName: sound.isMuted ? "speaker.slash.fill" : "speaker.2.fill")
                    .foregroundColor(.tdTextSecondary)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.tdElevated)
                    .cornerRadius(10)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.tdSurface.opacity(0.95))
    }

    private func hudPill(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.subheadline)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.tdTextPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.tdElevated)
        .cornerRadius(10)
    }
}
