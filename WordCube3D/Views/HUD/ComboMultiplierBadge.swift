import SwiftUI

/// Badge displaying active combo score multiplier with decaying timer gauge.
public struct ComboMultiplierBadge: View {
    public let multiplier: Double
    public let streak: Int
    public let timeRemaining: TimeInterval
    public let theme: GameTheme
    
    public init(
        multiplier: Double,
        streak: Int,
        timeRemaining: TimeInterval,
        theme: GameTheme
    ) {
        self.multiplier = multiplier
        self.streak = streak
        self.timeRemaining = timeRemaining
        self.theme = theme
    }
    
    private var isComboActive: Bool {
        multiplier > 1.0
    }
    
    private var comboProgress: Double {
        max(0.0, min(1.0, timeRemaining / 12.0))
    }
    
    public var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                if isComboActive {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 12))
                }
                
                Text(String(format: "%.1fx", multiplier))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(isComboActive ? .orange : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(isComboActive ? Color.orange.opacity(0.18) : Color.primary.opacity(0.06))
                    .overlay(
                        Capsule()
                            .stroke(isComboActive ? Color.orange.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
            
            // Decaying combo bar
            if isComboActive {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.orange.opacity(0.2))
                        
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * CGFloat(comboProgress))
                    }
                }
                .frame(width: 44, height: 3)
                .animation(.linear(duration: 0.3), value: comboProgress)
            }
        }
    }
}
