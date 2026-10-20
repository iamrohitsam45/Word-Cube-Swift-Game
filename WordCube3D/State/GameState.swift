import Foundation

public struct BannerMessage: Identifiable, Equatable, Sendable {
    public enum MessageType: Equatable, Sendable {
        case success
        case error
        case info
    }
    
    public let id: UUID
    public let text: String
    public let type: MessageType
    
    public init(id: UUID = UUID(), text: String, type: MessageType) {
        self.id = id
        self.text = text
        self.type = type
    }
}

public struct GameState: Equatable, Sendable {
    /// 3D grid mapping coordinates to active cube blocks.
    public var grid: [Coordinate3D: CubeBlock]
    
    /// Sequence of selected block coordinates forming current word chain.
    public var selectedChain: [Coordinate3D]
    
    /// Coordinates currently playing smooth removal animation.
    public var removingCoordinates: Set<Coordinate3D>
    
    /// Scoring and combo metrics.
    public var score: Int
    public var highScore: Int
    public var comboMultiplier: Double
    public var comboStreak: Int
    public var comboTimeRemaining: TimeInterval
    
    /// Timer and match state.
    public var timeRemaining: TimeInterval
    public var totalDuration: TimeInterval
    public var isTimerRunning: Bool
    public var isGameOver: Bool
    public var isPaused: Bool
    
    /// List of successfully validated words found in current match.
    public var wordsFound: [FoundWord]
    
    /// Dynamic notification banner on HUD.
    public var banner: BannerMessage?
    
    /// User preferences and aesthetics.
    public var theme: GameTheme
    public var hapticsEnabled: Bool
    public var soundEnabled: Bool
    
    /// Modals
    public var isHistoryPresented: Bool
    public var isSettingsPresented: Bool
    
    public init(
        grid: [Coordinate3D: CubeBlock] = GameState.generateInitialGrid(),
        selectedChain: [Coordinate3D] = [],
        removingCoordinates: Set<Coordinate3D> = [],
        score: Int = 0,
        highScore: Int = PersistenceService.shared.highScore,
        comboMultiplier: Double = 1.0,
        comboStreak: Int = 0,
        comboTimeRemaining: TimeInterval = 0.0,
        timeRemaining: TimeInterval = 120.0,
        totalDuration: TimeInterval = 120.0,
        isTimerRunning: Bool = true,
        isGameOver: Bool = false,
        isPaused: Bool = false,
        wordsFound: [FoundWord] = [],
        banner: BannerMessage? = nil,
        theme: GameTheme = PersistenceService.shared.theme,
        hapticsEnabled: Bool = PersistenceService.shared.hapticsEnabled,
        soundEnabled: Bool = PersistenceService.shared.soundEnabled,
        isHistoryPresented: Bool = false,
        isSettingsPresented: Bool = false
    ) {
        self.grid = grid
        self.selectedChain = selectedChain
        self.removingCoordinates = removingCoordinates
        self.score = score
        self.highScore = highScore
        self.comboMultiplier = comboMultiplier
        self.comboStreak = comboStreak
        self.comboTimeRemaining = comboTimeRemaining
        self.timeRemaining = timeRemaining
        self.totalDuration = totalDuration
        self.isTimerRunning = isTimerRunning
        self.isGameOver = isGameOver
        self.isPaused = isPaused
        self.wordsFound = wordsFound
        self.banner = banner
        self.theme = theme
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.isHistoryPresented = isHistoryPresented
        self.isSettingsPresented = isSettingsPresented
    }
    
    /// Constructs current word string from selected coordinates.
    public var currentWord: String {
        selectedChain.compactMap { grid[$0]?.letter }.map { String($0) }.joined()
    }
    
    /// Computes potential score for the currently selected chain.
    public var currentWordPotentialScore: Int {
        guard selectedChain.count >= 3 else { return 0 }
        let base = selectedChain.compactMap { grid[$0]?.points }.reduce(0, +)
        let bonus = GameState.lengthMultiplier(for: selectedChain.count)
        return Int((Double(base) * bonus * comboMultiplier).rounded())
    }
    
    /// Length bonus multiplier.
    public static func lengthMultiplier(for length: Int) -> Double {
        switch length {
        case 3: return 1.0
        case 4: return 1.2
        case 5: return 1.5
        case 6: return 2.0
        case 7: return 2.5
        default: return 3.0
        }
    }
    
    /// Generates full 3x3x3 cube of 27 letter blocks.
    public static func generateInitialGrid() -> [Coordinate3D: CubeBlock] {
        var newGrid: [Coordinate3D: CubeBlock] = [:]
        for coord in Coordinate3D.allCoordinates {
            let letter = CubeBlock.randomLetter()
            newGrid[coord] = CubeBlock(coordinate: coord, letter: letter)
        }
        return newGrid
    }
    
    /// Count of remaining active blocks.
    public var activeBlockCount: Int {
        grid.values.filter { $0.status.isAvailable }.count
    }
}
