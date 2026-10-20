import XCTest
@testable import WordCube3D

@MainActor
final class ReducerTests: XCTestCase {
    
    var environment: GameEnvironment!
    
    override func setUp() {
        super.setUp()
        environment = GameEnvironment()
    }
    
    func testFirstBlockSelection() {
        var state = GameState()
        let coord = Coordinate3D(x: 0, y: 0, z: 0)
        
        let effect = gameReducer(state: &state, action: .blockTapped(coord), environment: environment)
        
        XCTAssertEqual(state.selectedChain, [coord])
        XCTAssertEqual(state.grid[coord]?.status, .selected(order: 0))
    }
    
    func testAdjacentBlockSelection() {
        var state = GameState()
        let coord1 = Coordinate3D(x: 0, y: 0, z: 0)
        let coord2 = Coordinate3D(x: 1, y: 0, z: 0) // adjacent
        
        _ = gameReducer(state: &state, action: .blockTapped(coord1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(coord2), environment: environment)
        
        XCTAssertEqual(state.selectedChain, [coord1, coord2])
        XCTAssertEqual(state.grid[coord2]?.status, .selected(order: 1))
    }
    
    func testNonAdjacentBlockSelectionRejected() {
        var state = GameState()
        let coord1 = Coordinate3D(x: 0, y: 0, z: 0)
        let farCoord = Coordinate3D(x: 2, y: 2, z: 2) // not adjacent
        
        _ = gameReducer(state: &state, action: .blockTapped(coord1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(farCoord), environment: environment)
        
        XCTAssertEqual(state.selectedChain, [coord1])
        XCTAssertNotNil(state.banner)
        XCTAssertEqual(state.banner?.type, .error)
    }
    
    func testBacktrackLastBlock() {
        var state = GameState()
        let coord1 = Coordinate3D(x: 0, y: 0, z: 0)
        let coord2 = Coordinate3D(x: 1, y: 0, z: 0)
        
        _ = gameReducer(state: &state, action: .blockTapped(coord1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(coord2), environment: environment)
        
        // Tapping last block backtracks
        _ = gameReducer(state: &state, action: .blockTapped(coord2), environment: environment)
        
        XCTAssertEqual(state.selectedChain, [coord1])
        XCTAssertEqual(state.grid[coord2]?.status, .idle)
    }
    
    func testWordTooShortRejected() {
        var state = GameState()
        let coord1 = Coordinate3D(x: 0, y: 0, z: 0)
        let coord2 = Coordinate3D(x: 1, y: 0, z: 0)
        
        _ = gameReducer(state: &state, action: .blockTapped(coord1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(coord2), environment: environment)
        
        _ = gameReducer(state: &state, action: .submitWord, environment: environment)
        
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.banner?.type, .error)
    }
    
    func testValidWordSubmissionAndCombo() {
        var state = GameState()
        let c1 = Coordinate3D(x: 0, y: 0, z: 0)
        let c2 = Coordinate3D(x: 1, y: 0, z: 0)
        let c3 = Coordinate3D(x: 2, y: 0, z: 0)
        
        state.grid[c1] = CubeBlock(coordinate: c1, letter: "C")
        state.grid[c2] = CubeBlock(coordinate: c2, letter: "A")
        state.grid[c3] = CubeBlock(coordinate: c3, letter: "T")
        
        _ = gameReducer(state: &state, action: .blockTapped(c1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(c2), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(c3), environment: environment)
        
        XCTAssertEqual(state.currentWord, "CAT")
        
        _ = gameReducer(state: &state, action: .submitWord, environment: environment)
        
        XCTAssertGreaterThan(state.score, 0)
        XCTAssertEqual(state.wordsFound.count, 1)
        XCTAssertEqual(state.wordsFound.first?.word, "CAT")
        XCTAssertEqual(state.comboStreak, 1)
        XCTAssertGreaterThan(state.comboMultiplier, 1.0)
        XCTAssertEqual(state.banner?.type, .success)
        XCTAssertEqual(state.removingCoordinates, [c1, c2, c3])
    }
    
    func testDuplicateWordRejected() {
        var state = GameState()
        let c1 = Coordinate3D(x: 0, y: 0, z: 0)
        let c2 = Coordinate3D(x: 1, y: 0, z: 0)
        let c3 = Coordinate3D(x: 2, y: 0, z: 0)
        
        state.grid[c1] = CubeBlock(coordinate: c1, letter: "C")
        state.grid[c2] = CubeBlock(coordinate: c2, letter: "A")
        state.grid[c3] = CubeBlock(coordinate: c3, letter: "T")
        
        // Pre-insert CAT in wordsFound
        state.wordsFound = [FoundWord(word: "CAT", points: 10, multiplier: 1.0, coordinates: [c1, c2, c3])]
        
        _ = gameReducer(state: &state, action: .blockTapped(c1), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(c2), environment: environment)
        _ = gameReducer(state: &state, action: .blockTapped(c3), environment: environment)
        
        _ = gameReducer(state: &state, action: .submitWord, environment: environment)
        
        XCTAssertEqual(state.score, 0)
        XCTAssertEqual(state.banner?.text, "CAT Already Found")
    }
    
    func testTimerExpirationTriggersGameOver() {
        var state = GameState()
        state.timeRemaining = 1.0
        
        _ = gameReducer(state: &state, action: .timerTicked, environment: environment)
        
        XCTAssertEqual(state.timeRemaining, 0)
        XCTAssertTrue(state.isGameOver)
        XCTAssertFalse(state.isTimerRunning)
    }
}
