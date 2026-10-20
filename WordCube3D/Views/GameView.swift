import SwiftUI

/// Main Game Screen orchestrating 3D SceneKit rendering, HUD overlays, and modal dialogues.
public struct GameView: View {
    @ObservedObject public var store: Store<GameState, GameAction, GameEnvironment>
    
    public init(store: Store<GameState, GameAction, GameEnvironment>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // 1. Full-screen 3D SceneKit Viewport
            WordCubeSCNView(
                state: store.state,
                onBlockTapped: { coordinate in
                    store.send(.blockTapped(coordinate))
                }
            )
            .ignoresSafeArea()
            
            // 2. HUD Overlay
            VStack {
                // Top HUD Bar
                TopHUDBar(
                    state: store.state,
                    onPauseToggle: {
                        store.send(.togglePause)
                    },
                    onHistoryTap: {
                        store.send(.setHistoryPresented(true))
                    },
                    onSettingsTap: {
                        store.send(.setSettingsPresented(true))
                    }
                )
                .padding(.top, 8)
                
                // Floating status notification banner
                if let banner = store.state.banner {
                    FloatingBannerView(banner: banner)
                        .padding(.top, 12)
                }
                
                Spacer()
                
                // Bottom Word Chain Tray
                WordChainTray(
                    state: store.state,
                    onSubmit: {
                        store.send(.submitWord)
                    },
                    onBacktrack: {
                        store.send(.backtrackLastBlock)
                    },
                    onClear: {
                        store.send(.clearChain)
                    }
                )
                .padding(.bottom, 12)
            }
            
            // 3. Pause Overlay
            if store.state.isPaused {
                ZStack {
                    Color.black.opacity(0.55)
                        .ignoresSafeArea()
                    
                    GlassCard(cornerRadius: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(store.state.theme.accentColor)
                            
                            Text("GAME PAUSED")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Button(action: {
                                store.send(.togglePause)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                    Text("RESUME")
                                        .fontWeight(.heavy)
                                }
                                .foregroundColor(.black)
                                .frame(width: 160, height: 44)
                                .background(store.state.theme.accentColor)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                    }
                }
                .transition(.opacity)
            }
            
            // 4. Game Over Modal
            if store.state.isGameOver {
                GameOverModal(
                    state: store.state,
                    onPlayAgain: { duration in
                        store.send(.startNewGame(duration: duration))
                    },
                    onViewWords: {
                        store.send(.setHistoryPresented(true))
                    }
                )
            }
        }
        .sheet(isPresented: store.binding(
            get: { $0.isHistoryPresented },
            send: { .setHistoryPresented($0) }
        )) {
            WordHistorySheet(
                words: store.state.wordsFound,
                theme: store.state.theme,
                onDismiss: {
                    store.send(.setHistoryPresented(false))
                }
            )
        }
        .sheet(isPresented: store.binding(
            get: { $0.isSettingsPresented },
            send: { .setSettingsPresented($0) }
        )) {
            SettingsSheet(
                state: store.state,
                onThemeChange: { store.send(.setTheme($0)) },
                onHapticsToggle: { store.send(.toggleHaptics) },
                onSoundToggle: { store.send(.toggleSound) },
                onReplenish: { store.send(.replenishCube) },
                onShuffle: { store.send(.shuffleCube) },
                onDismiss: { store.send(.setSettingsPresented(false)) }
            )
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}
