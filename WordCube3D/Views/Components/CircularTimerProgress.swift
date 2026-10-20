import SwiftUI

/// Circular progress ring displaying game countdown timer with urgent color transition.
public struct CircularTimerProgress: View {
    public let timeRemaining: TimeInterval
    public let totalDuration: TimeInterval
    
    public init(timeRemaining: TimeInterval, totalDuration: TimeInterval) {
        self.timeRemaining = timeRemaining
        self.totalDuration = totalDuration
    }
    
    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return max(0.0, min(1.0, timeRemaining / totalDuration))
    }
    
    private var formattedTime: String {
        let seconds = Int(max(0, timeRemaining))
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private var ringColor: Color {
        if timeRemaining <= 15 {
            return .red
        } else if timeRemaining <= 35 {
            return .orange
        } else {
            return .green
        }
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: 4)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
            
            // Digital timer
            Text(formattedTime)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(timeRemaining <= 15 ? .red : .primary)
        }
        .frame(width: 54, height: 54)
    }
}
