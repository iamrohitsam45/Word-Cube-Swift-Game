import SwiftUI

/// Floating notification pill overlay for word submission feedback and alerts.
public struct FloatingBannerView: View {
    public let banner: BannerMessage
    
    public init(banner: BannerMessage) {
        self.banner = banner
    }
    
    private var backgroundColor: Color {
        switch banner.type {
        case .success:
            return Color.green
        case .error:
            return Color.red
        case .info:
            return Color.blue
        }
    }
    
    private var iconName: String {
        switch banner.type {
        case .success:
            return "checkmark.seal.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .bold))
            
            Text(banner.text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(backgroundColor)
                .shadow(color: backgroundColor.opacity(0.4), radius: 8, x: 0, y: 4)
        )
        .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.85)))
    }
}
