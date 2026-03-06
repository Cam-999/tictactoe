import SwiftUI

struct GameOverView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.tdBackground.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("GAME OVER")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.tdDanger)

                VStack(spacing: 16) {
                    statRow(label: "Wave Reached", value: "\(gameState.wave)")
                    statRow(label: "Score",        value: "\(gameState.score)")
                }
                .padding(24)
                .background(Color.tdSurface)
                .cornerRadius(16)
                .padding(.horizontal, 32)

                Spacer()

                Button {
                    gameState.reset()
                    appState.phase = .playing
                } label: {
                    Text("TRY AGAIN")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tdAccentBlue)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }

                Button {
                    appState.phase = .menu
                } label: {
                    Text("Main Menu")
                        .font(.subheadline)
                        .foregroundColor(.tdTextSecondary)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.tdTextSecondary)
            Spacer()
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.tdTextPrimary)
        }
    }
}
