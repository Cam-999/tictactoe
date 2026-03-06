import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.tdBackground.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Text("TOWER")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.tdAccentBlue)
                    Text("DEFENSE")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.tdTextPrimary)
                }

                Text("100 Waves. Survive them all.")
                    .font(.subheadline)
                    .foregroundColor(.tdTextSecondary)

                Spacer()

                Button {
                    gameState.reset()
                    appState.phase = .playing
                } label: {
                    Text("PLAY")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tdAccentBlue)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }

                Spacer().frame(height: 60)
            }
        }
    }
}
