import AudioToolbox
import Foundation

/// Audio effects service using iOS AudioToolbox system audio chimes.
public final class SoundService: @unchecked Sendable {
    public static let shared = SoundService()
    
    public init() {}
    
    public func playLetterTap(enabled: Bool = true) {
        guard enabled else { return }
        // System tap sound
        AudioServicesPlaySystemSound(1104)
    }
    
    public func playWordSuccess(enabled: Bool = true) {
        guard enabled else { return }
        // Positive chime
        AudioServicesPlaySystemSound(1025)
    }
    
    public func playWordFail(enabled: Bool = true) {
        guard enabled else { return }
        // Negative buzz / reject
        AudioServicesPlaySystemSound(1073)
    }
    
    public func playGameOver(enabled: Bool = true) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1006)
    }
}
