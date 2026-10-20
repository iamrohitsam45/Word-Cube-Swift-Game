import SwiftUI

/// Modal sheet presented upon game countdown expiration.
public struct GameOverModal: View {
    public let state: GameState
    public let onPlayAgain: (TimeInterval) -> Void
    public let onViewWords: () -> Void
    
    @State private var selectedDuration: TimeInterval = 120
    
    public init(
        state: GameState,
        onPlayAgain: @escaping (TimeInterval) -> Void,
        onViewWords: @escaping () -> Void
    ) {
        self.state = state
        self.onPlayAgain = onPlayAgain
        self.onViewWords = onViewWords
    }
    
    private var isNewHighScore: Bool {
        state.score >= state.highScore && state.score > 0
    }
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
            
            GlassCard(cornerRadius: 28) {
                VStack(spacing: 20) {
                    // Header Trophy / Star Icon
                    ZStack {
                        Circle()
                            .fill(state.theme.accentColor.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isNewHighScore ? "crown.fill" : "flag.checkered")
                            .font(.system(size: 40))
                            .foregroundColor(state.theme.accentColor)
                    }
                    
                    VStack(spacing: 4) {
                        Text(isNewHighScore ? "NEW HIGH SCORE!" : "TIME'S UP!")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Awesome match!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Score Card
                    VStack(spacing: 8) {
                        Text("\(state.score)")
                            .font(.system(size: 54, weight: .black, design: .rounded))
                            .foregroundColor(state.theme.accentColor)
                        
                        Text("FINAL SCORE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    
                    // Statistics Grid
                    HStack(spacing: 16) {
                        StatBox(
                            title: "WORDS FOUND",
                            value: "\(state.wordsFound.count)",
                            icon: "text.word.spacing"
                        )
                        
                        StatBox(
                            title: "BEST WORD",
                            value: state.wordsFound.max(by: { $0.points < $1.points })?.word ?? "—",
                            icon: "star.fill"
                        )
                    }
                    
                    // Match Duration Picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NEXT GAME DURATION")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Picker("Duration", selection: $selectedDuration) {
                            Text("1 Min").tag(TimeInterval(60))
                            Text("2 Mins").tag(TimeInterval(120))
                            Text("3 Mins").tag(TimeInterval(180))
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.top, 4)
                    
                    // Action Buttons
                    VStack(spacing: 10) {
                        Button(action: {
                            onPlayAgain(selectedDuration)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("PLAY AGAIN")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(state.theme.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: state.theme.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        
                        if !state.wordsFound.isEmpty {
                            Button(action: onViewWords) {
                                Text("View Found Words (\(state.wordsFound.count))")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxWidth: 340)
            .padding(20)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

private struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
