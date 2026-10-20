import Foundation

private enum CancelId {
    static let timer = "GameTimerCancelId"
    static let comboTimer = "ComboTimerCancelId"
    static let banner = "BannerCancelId"
}

/// Pure reducer implementing unidirectional game logic and state transitions.
public func gameReducer(
    state: inout GameState,
    action: GameAction,
    environment: GameEnvironment
) -> Effect<GameAction> {
    switch action {
    case .onAppear:
        return .merge(
            // 1-second interval game timer
            .run { send in
                while true {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    if Task.isCancelled { break }
                    send(.timerTicked)
                    send(.comboTimerTicked)
                }
            }.cancellable(id: CancelId.timer)
        )
        
    case .blockTapped(let coordinate):
        guard !state.isGameOver, !state.isPaused else { return .none }
        guard let block = state.grid[coordinate], block.status.isAvailable else { return .none }
        
        // Scenario 1: First block in chain
        if state.selectedChain.isEmpty {
            state.selectedChain.append(coordinate)
            state.grid[coordinate]?.status = .selected(order: 0)
            environment.haptics.letterSelected(enabled: state.hapticsEnabled)
            environment.sounds.playLetterTap(enabled: state.soundEnabled)
            return .none
        }
        
        // Scenario 2: Tapped the last selected block -> backtrack / undo
        if state.selectedChain.last == coordinate {
            return gameReducer(state: &state, action: .backtrackLastBlock, environment: environment)
        }
        
        // Scenario 3: Tapped a block already earlier in the chain -> truncate back to it
        if let existingIndex = state.selectedChain.firstIndex(of: coordinate) {
            let removedCoords = state.selectedChain.suffix(from: existingIndex + 1)
            for coord in removedCoords {
                state.grid[coord]?.status = .idle
            }
            state.selectedChain = Array(state.selectedChain.prefix(upTo: existingIndex + 1))
            environment.haptics.letterDeselected(enabled: state.hapticsEnabled)
            return .none
        }
        
        // Scenario 4: New block tapped -> check 3D adjacency with previous block
        guard let lastCoordinate = state.selectedChain.last else { return .none }
        if coordinate.isAdjacent(to: lastCoordinate) {
            let order = state.selectedChain.count
            state.selectedChain.append(coordinate)
            state.grid[coordinate]?.status = .selected(order: order)
            environment.haptics.letterSelected(enabled: state.hapticsEnabled)
            environment.sounds.playLetterTap(enabled: state.soundEnabled)
            return .none
        } else {
            // Not adjacent
            environment.haptics.invalidSelection(enabled: state.hapticsEnabled)
            state.banner = BannerMessage(text: "Must be adjacent", type: .error)
            return .run { send in
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                send(.dismissBanner)
            }.cancellable(id: CancelId.banner)
        }
        
    case .submitWord:
        guard !state.isGameOver, !state.isPaused else { return .none }
        
        // Rule: Minimum 3 letters
        if state.selectedChain.count < 3 {
            state.banner = BannerMessage(text: "Minimum 3 Letters", type: .error)
            environment.haptics.invalidSelection(enabled: state.hapticsEnabled)
            environment.sounds.playWordFail(enabled: state.soundEnabled)
            return .run { send in
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                send(.dismissBanner)
            }.cancellable(id: CancelId.banner)
        }
        
        let word = state.currentWord.uppercased()
        
        // Rule: No duplicate words in same game
        if state.wordsFound.contains(where: { $0.word.uppercased() == word }) {
            state.banner = BannerMessage(text: "\(word) Already Found", type: .error)
            environment.haptics.wordRejected(enabled: state.hapticsEnabled)
            environment.sounds.playWordFail(enabled: state.soundEnabled)
            return .run { send in
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                send(.dismissBanner)
            }.cancellable(id: CancelId.banner)
        }
        
        // Rule: Dictionary validation
        let isValid = environment.dictionary.isValidWord(word)
        if isValid {
            let points = state.currentWordPotentialScore
            state.score += points
            
            // Check High Score
            if state.score > state.highScore {
                state.highScore = state.score
                environment.persistence.highScore = state.score
            }
            
            // Update Combo Multiplier
            state.comboStreak += 1
            state.comboMultiplier = min(5.0, 1.0 + Double(state.comboStreak) * 0.25)
            state.comboTimeRemaining = 12.0
            
            // Record Found Word
            let found = FoundWord(
                word: word,
                points: points,
                multiplier: state.comboMultiplier,
                coordinates: state.selectedChain
            )
            state.wordsFound.insert(found, at: 0)
            
            // Trigger feedback
            environment.haptics.wordValidated(enabled: state.hapticsEnabled)
            environment.sounds.playWordSuccess(enabled: state.soundEnabled)
            state.banner = BannerMessage(text: "\(word) +\(points)pts!", type: .success)
            
            // Start smooth block removal animation
            let chainToRemove = state.selectedChain
            state.removingCoordinates = Set(chainToRemove)
            for coord in chainToRemove {
                state.grid[coord]?.status = .removing
            }
            
            return .merge(
                .run { send in
                    // 0.45s animation duration
                    try? await Task.sleep(nanoseconds: 450_000_000)
                    send(.blockRemovalCompleted(Set(chainToRemove)))
                },
                .run { send in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    send(.dismissBanner)
                }.cancellable(id: CancelId.banner)
            )
        } else {
            // Not a valid English word
            state.banner = BannerMessage(text: "\"\(word)\" Not In Dictionary", type: .error)
            environment.haptics.wordRejected(enabled: state.hapticsEnabled)
            environment.sounds.playWordFail(enabled: state.soundEnabled)
            return .run { send in
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                send(.dismissBanner)
            }.cancellable(id: CancelId.banner)
        }
        
    case .backtrackLastBlock:
        if let last = state.selectedChain.popLast() {
            state.grid[last]?.status = .idle
            environment.haptics.letterDeselected(enabled: state.hapticsEnabled)
        }
        return .none
        
    case .clearChain:
        for coord in state.selectedChain {
            state.grid[coord]?.status = .idle
        }
        state.selectedChain.removeAll()
        environment.haptics.letterDeselected(enabled: state.hapticsEnabled)
        return .none
        
    case .blockRemovalCompleted(let coords):
        for coord in coords {
            state.grid[coord]?.status = .cleared
        }
        state.selectedChain.removeAll()
        state.removingCoordinates.subtract(coords)
        
        // Auto-replenish if active blocks fall below 6 to keep gameplay fluid
        if state.activeBlockCount < 6 {
            return gameReducer(state: &state, action: .replenishCube, environment: environment)
        }
        return .none
        
    case .replenishCube:
        for coord in Coordinate3D.allCoordinates {
            if state.grid[coord]?.status == .cleared || state.grid[coord] == nil {
                state.grid[coord] = CubeBlock(coordinate: coord, letter: CubeBlock.randomLetter())
            }
        }
        state.banner = BannerMessage(text: "Cube Replenished!", type: .info)
        return .run { send in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            send(.dismissBanner)
        }.cancellable(id: CancelId.banner)
        
    case .shuffleCube:
        guard !state.isGameOver else { return .none }
        // Shuffle letters among active blocks
        let activeCoords = state.grid.keys.filter { state.grid[$0]?.status.isAvailable == true }
        var letters = activeCoords.compactMap { state.grid[$0]?.letter }.shuffled()
        for coord in activeCoords {
            if let letter = letters.popLast() {
                state.grid[coord]?.letter = letter
                state.grid[coord]?.points = CubeBlock.points(for: letter)
                state.grid[coord]?.status = .idle
            }
        }
        state.selectedChain.removeAll()
        state.banner = BannerMessage(text: "Cube Shuffled", type: .info)
        return .run { send in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            send(.dismissBanner)
        }.cancellable(id: CancelId.banner)
        
    case .timerTicked:
        guard state.isTimerRunning, !state.isPaused, !state.isGameOver else { return .none }
        state.timeRemaining -= 1
        
        if state.timeRemaining <= 10 && state.timeRemaining > 0 {
            environment.haptics.timerWarning(enabled: state.hapticsEnabled)
        }
        
        if state.timeRemaining <= 0 {
            state.timeRemaining = 0
            state.isGameOver = true
            state.isTimerRunning = false
            environment.persistence.recordGameCompletion(score: state.score, words: state.wordsFound)
            environment.haptics.gameOver(enabled: state.hapticsEnabled)
            environment.sounds.playGameOver(enabled: state.soundEnabled)
        }
        return .none
        
    case .comboTimerTicked:
        guard state.isTimerRunning, !state.isPaused, !state.isGameOver else { return .none }
        if state.comboMultiplier > 1.0 {
            state.comboTimeRemaining -= 1
            if state.comboTimeRemaining <= 0 {
                state.comboMultiplier = 1.0
                state.comboStreak = 0
            }
        }
        return .none
        
    case .startNewGame(let duration):
        state = GameState(
            grid: GameState.generateInitialGrid(),
            selectedChain: [],
            removingCoordinates: [],
            score: 0,
            highScore: environment.persistence.highScore,
            comboMultiplier: 1.0,
            comboStreak: 0,
            comboTimeRemaining: 0,
            timeRemaining: duration,
            totalDuration: duration,
            isTimerRunning: true,
            isGameOver: false,
            isPaused: false,
            wordsFound: [],
            banner: nil,
            theme: state.theme,
            hapticsEnabled: state.hapticsEnabled,
            soundEnabled: state.soundEnabled
        )
        return .send(.onAppear)
        
    case .togglePause:
        state.isPaused.toggle()
        return .none
        
    case .dismissBanner:
        state.banner = nil
        return .none
        
    case .setTheme(let theme):
        state.theme = theme
        environment.persistence.theme = theme
        return .none
        
    case .toggleHaptics:
        state.hapticsEnabled.toggle()
        environment.persistence.hapticsEnabled = state.hapticsEnabled
        return .none
        
    case .toggleSound:
        state.soundEnabled.toggle()
        environment.persistence.soundEnabled = state.soundEnabled
        return .none
        
    case .setHistoryPresented(let presented):
        state.isHistoryPresented = presented
        return .none
        
    case .setSettingsPresented(let presented):
        state.isSettingsPresented = presented
        return .none
    }
}
