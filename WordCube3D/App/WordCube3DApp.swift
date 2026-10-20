import SwiftUI

@main
struct WordCube3DApp: App {
    @StateObject private var store = Store(
        initialState: GameState(),
        reducer: gameReducer,
        environment: GameEnvironment()
    )
    
    var body: some Scene {
        WindowGroup {
            GameView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
