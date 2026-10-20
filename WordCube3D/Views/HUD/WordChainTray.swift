import SwiftUI

/// Bottom floating tray displaying the active letter chain, point estimates, and action buttons.
public struct WordChainTray: View {
    public let state: GameState
    public let onSubmit: () -> Void
    public let onBacktrack: () -> Void
    public let onClear: () -> Void
    
    public init(
        state: GameState,
        onSubmit: @escaping () -> Void,
        onBacktrack: @escaping () -> Void,
        onClear: @escaping () -> Void
    ) {
        self.state = state
        self.onSubmit = onSubmit
        self.onBacktrack = onBacktrack
        self.onClear = onClear
    }
    
    private var isChainValidLength: Bool {
        state.selectedChain.count >= 3
    }
    
    public var body: some View {
        GlassCard(cornerRadius: 24) {
            VStack(spacing: 12) {
                // Word tiles row or empty hint
                if state.selectedChain.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        Text("Tap adjacent cube letters to spell words")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 52)
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        // Scrollable chain of letter tiles
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(state.selectedChain.enumerated()), id: \.offset) { index, coord in
                                    if let block = state.grid[coord] {
                                        LetterTileView(
                                            letter: block.letter,
                                            points: block.points,
                                            index: index,
                                            theme: state.theme
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // Potential Points Badge
                        if isChainValidLength {
                            VStack(spacing: 1) {
                                Text("+\(state.currentWordPotentialScore)")
                                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                                    .foregroundColor(.green)
                                Text("PTS")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 52)
                }
                
                // Bottom control buttons
                HStack(spacing: 10) {
                    // Clear all button
                    Button(action: onClear) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(state.selectedChain.isEmpty)
                    .opacity(state.selectedChain.isEmpty ? 0.35 : 1.0)
                    
                    // Backspace button (undo last)
                    Button(action: onBacktrack) {
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44)
                            .background(Color.primary.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(state.selectedChain.isEmpty)
                    .opacity(state.selectedChain.isEmpty ? 0.35 : 1.0)
                    
                    // Submit Word button
                    Button(action: onSubmit) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text(isChainValidLength ? "SUBMIT WORD" : "SPELL (MIN 3)")
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                        }
                        .foregroundColor(isChainValidLength ? .black : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            isChainValidLength
                            ? state.theme.accentColor
                            : Color.primary.opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(
                            color: isChainValidLength ? state.theme.accentColor.opacity(0.4) : .clear,
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isChainValidLength)
                    .scaleEffect(isChainValidLength ? 1.02 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isChainValidLength)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
