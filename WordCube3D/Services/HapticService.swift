import UIKit

/// Generates tactile haptic feedback for user interactions and game events.
public final class HapticService: @unchecked Sendable {
    public static let shared = HapticService()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    public init() {
        lightImpact.prepare()
        notificationFeedback.prepare()
    }
    
    public func letterSelected(enabled: Bool = true) {
        guard enabled else { return }
        lightImpact.impactOccurred()
    }
    
    public func letterDeselected(enabled: Bool = true) {
        guard enabled else { return }
        mediumImpact.impactOccurred()
    }
    
    public func invalidSelection(enabled: Bool = true) {
        guard enabled else { return }
        notificationFeedback.notificationOccurred(.warning)
    }
    
    public func wordValidated(enabled: Bool = true) {
        guard enabled else { return }
        notificationFeedback.notificationOccurred(.success)
        heavyImpact.impactOccurred(intensity: 1.0)
    }
    
    public func wordRejected(enabled: Bool = true) {
        guard enabled else { return }
        notificationFeedback.notificationOccurred(.error)
    }
    
    public func timerWarning(enabled: Bool = true) {
        guard enabled else { return }
        mediumImpact.impactOccurred()
    }
    
    public func gameOver(enabled: Bool = true) {
        guard enabled else { return }
        notificationFeedback.notificationOccurred(.warning)
    }
}
