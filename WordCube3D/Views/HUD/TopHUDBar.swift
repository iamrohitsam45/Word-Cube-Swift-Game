import SwiftUI

/// Top HUD Bar displaying timer, score, high score, multiplier, and control buttons.
public struct TopHUDBar: View {
    public let state: GameState
    public let onPauseToggle: () -> Void
    public let onHistoryTap: () -> Void
    public let onSettingsTap: () -> Void
    
    public init(
        state: GameState,
        onPauseToggle: @escaping () -> Void,
        onHistoryTap: @escaping () -> Void,
        onSettingsTap: @escaping () -> Void
    ) {
        self.state = state
        self.onPauseToggle = onPauseToggle
        self.onHistoryTap = onHistoryTap
        self.onSettingsTap = onSettingsTap
    }
    
    public var body: some View {
        GlassCard(cornerRadius: 22) {
            HStack(alignment: .center, spacing: 14) {
                // 1. Timer
                CircularTimerProgress(
                    timeRemaining: state.timeRemaining,
                    totalDuration: state.totalDuration
                )
                
                // 2. Score & High Score
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("\(state.score)")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        
                        ComboMultiplierBadge(
                            multiplier: state.comboMultiplier,
                            streak: state.comboStreak,
                            timeRemaining: state.comboTimeRemaining,
                            theme: state.theme
                        )
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.yellow)
                        
                        Text("BEST: \(max(state.score, state.highScore))")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 3. Quick Action Buttons
                HStack(spacing: 8) {
                    // Found words count / history
                    Button(action: onHistoryTap) {
                        HStack(spacing: 3) {
                            Image(systemName: "book.pages")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(state.wordsFound.count)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    // Pause / Resume
                    Button(action: onPauseToggle) {
                        Image(systemName: state.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 13, weight: .bold))
                            .padding(8)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    // Settings
                    Button(action: onSettingsTap) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 13, weight: .bold))
                            .padding(8)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
