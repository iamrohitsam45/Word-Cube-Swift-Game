import SwiftUI

/// Tactile letter tile displayed in the HUD word chain tray.
public struct LetterTileView: View {
    public let letter: Character
    public let points: Int
    public let index: Int
    public let theme: GameTheme
    
    public init(
        letter: Character,
        points: Int,
        index: Int,
        theme: GameTheme
    ) {
        self.letter = letter
        self.points = points
        self.index = index
        self.theme = theme
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(theme.blockColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(theme.accentColor.opacity(0.8), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            
            // Centered letter
            Text(String(letter).uppercased())
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundColor(Color(theme.letterColor))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Point badge
            Text("\(points)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(theme.letterColor).opacity(0.85))
                .padding(.trailing, 4)
                .padding(.bottom, 2)
        }
        .frame(width: 44, height: 48)
        .transition(.scale.combined(with: .opacity))
    }
}
