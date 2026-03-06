import SwiftUI

@main
struct TowerDefenseApp: App {
    @StateObject private var appState   = AppState()
    @StateObject private var gameState  = GameState()
    @StateObject private var shopState  = ShopState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(gameState)
                .environmentObject(shopState)
                .preferredColorScheme(.dark)
        }
    }
}
