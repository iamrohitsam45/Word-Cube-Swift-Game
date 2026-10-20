import Foundation

/// Persistence service managing local records, high scores, and user preferences via UserDefaults.
public final class PersistenceService: @unchecked Sendable {
    public static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let highScore = "wordcube_high_score"
        static let bestWord = "wordcube_best_word"
        static let bestWordPoints = "wordcube_best_word_points"
        static let gamesPlayed = "wordcube_games_played"
        static let totalWordsFound = "wordcube_total_words_found"
        static let hapticsEnabled = "wordcube_haptics_enabled"
        static let soundEnabled = "wordcube_sound_enabled"
        static let savedTheme = "wordcube_saved_theme"
    }
    
    public init() {}
    
    public var highScore: Int {
        get { defaults.integer(forKey: Keys.highScore) }
        set { defaults.set(newValue, forKey: Keys.highScore) }
    }
    
    public var bestWord: String {
        get { defaults.string(forKey: Keys.bestWord) ?? "" }
        set { defaults.set(newValue, forKey: Keys.bestWord) }
    }
    
    public var bestWordPoints: Int {
        get { defaults.integer(forKey: Keys.bestWordPoints) }
        set { defaults.set(newValue, forKey: Keys.bestWordPoints) }
    }
    
    public var gamesPlayed: Int {
        get { defaults.integer(forKey: Keys.gamesPlayed) }
        set { defaults.set(newValue, forKey: Keys.gamesPlayed) }
    }
    
    public var totalWordsFound: Int {
        get { defaults.integer(forKey: Keys.totalWordsFound) }
        set { defaults.set(newValue, forKey: Keys.totalWordsFound) }
    }
    
    public var hapticsEnabled: Bool {
        get { defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.hapticsEnabled) }
    }
    
    public var soundEnabled: Bool {
        get { defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Keys.soundEnabled) }
    }
    
    public var theme: GameTheme {
        get {
            guard let raw = defaults.string(forKey: Keys.savedTheme),
                  let theme = GameTheme(rawValue: raw) else {
                return .ceramic
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.savedTheme)
        }
    }
    
    public func recordGameCompletion(score: Int, words: [FoundWord]) {
        gamesPlayed += 1
        totalWordsFound += words.count
        
        if score > highScore {
            highScore = score
        }
        
        for found in words {
            if found.points > bestWordPoints {
                bestWordPoints = found.points
                bestWord = found.word
            }
        }
    }
}
