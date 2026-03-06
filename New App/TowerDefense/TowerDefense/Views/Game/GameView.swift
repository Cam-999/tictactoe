import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var shopState: ShopState

    // SceneHolder is created once; we pass state objects at init time.
    @State private var sceneHolder: SceneHolder?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let holder = sceneHolder {
                SpriteView(scene: holder.scene)
                    .ignoresSafeArea()
            }

            VStack(spacing: 0) {
                HUDView()
                Spacer()

                if !gameState.waveInProgress && !gameState.shopIsOpen {
                    Button {
                        let nextWave = gameState.wave + 1
                        guard nextWave <= 100 else { return }
                        sceneHolder?.scene.startWave(nextWave)
                    } label: {
                        Text(gameState.wave == 0 ? "START GAME" : "START WAVE \(gameState.wave + 1)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.tdAccentBlue)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 8)
                }

                TowerPaletteView()
            }
        }
        .sheet(isPresented: $gameState.shopIsOpen) {
            ShopView { }
                .environmentObject(gameState)
                .environmentObject(shopState)
                .environmentObject(appState)
        }
        .onAppear {
            if sceneHolder == nil {
                sceneHolder = SceneHolder(gameState: gameState, appState: appState)
            }
        }
    }
}

final class SceneHolder: ObservableObject {
    let scene: GameScene

    init(gameState: GameState, appState: AppState) {
        let s = GameScene(gameState: gameState, appState: appState)
        s.scaleMode = .resizeFill
        self.scene  = s
    }
}
