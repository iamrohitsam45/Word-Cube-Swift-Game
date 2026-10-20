import Foundation

/// Dependency container passed into the Reducer, conforming to TCA architecture.
public struct GameEnvironment: Sendable {
    public var dictionary: DictionaryService
    public var haptics: HapticService
    public var sounds: SoundService
    public var persistence: PersistenceService
    
    public init(
        dictionary: DictionaryService = .shared,
        haptics: HapticService = .shared,
        sounds: SoundService = .shared,
        persistence: PersistenceService = .shared
    ) {
        self.dictionary = dictionary
        self.haptics = haptics
        self.sounds = sounds
        self.persistence = persistence
    }
}
