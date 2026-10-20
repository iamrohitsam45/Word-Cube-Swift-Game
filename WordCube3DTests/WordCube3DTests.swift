import XCTest
@testable import WordCube3D

final class WordCube3DTests: XCTestCase {
    
    func testCoordinate3DAdjacency() {
        let center = Coordinate3D(x: 1, y: 1, z: 1)
        
        // Face adjacent
        let top = Coordinate3D(x: 1, y: 2, z: 1)
        XCTAssertTrue(center.isAdjacent(to: top))
        
        // Edge adjacent
        let edge = Coordinate3D(x: 0, y: 2, z: 1)
        XCTAssertTrue(center.isAdjacent(to: edge))
        
        // Corner adjacent
        let corner = Coordinate3D(x: 0, y: 0, z: 0)
        XCTAssertTrue(center.isAdjacent(to: corner))
        
        // Same block is not adjacent
        XCTAssertFalse(center.isAdjacent(to: center))
        
        // Non-adjacent (distance 2)
        let far = Coordinate3D(x: 0, y: 0, z: 2)
        let otherFar = Coordinate3D(x: 2, y: 2, z: 0)
        XCTAssertFalse(far.isAdjacent(to: otherFar))
    }
    
    func testAllCoordinatesCount() {
        let coords = Coordinate3D.allCoordinates
        XCTAssertEqual(coords.count, 27)
    }
    
    func testLetterPoints() {
        XCTAssertEqual(CubeBlock.points(for: "A"), 1)
        XCTAssertEqual(CubeBlock.points(for: "Q"), 10)
        XCTAssertEqual(CubeBlock.points(for: "Z"), 10)
        XCTAssertEqual(CubeBlock.points(for: "D"), 2)
        XCTAssertEqual(CubeBlock.points(for: "B"), 3)
    }
    
    func testLengthMultipliers() {
        XCTAssertEqual(GameState.lengthMultiplier(for: 3), 1.0)
        XCTAssertEqual(GameState.lengthMultiplier(for: 4), 1.2)
        XCTAssertEqual(GameState.lengthMultiplier(for: 5), 1.5)
        XCTAssertEqual(GameState.lengthMultiplier(for: 6), 2.0)
        XCTAssertEqual(GameState.lengthMultiplier(for: 7), 2.5)
        XCTAssertEqual(GameState.lengthMultiplier(for: 8), 3.0)
    }
    
    func testDictionaryValidation() {
        let dict = DictionaryService()
        XCTAssertTrue(dict.isValidWord("cat"))
        XCTAssertTrue(dict.isValidWord("WORD"))
        XCTAssertTrue(dict.isValidWord("cube"))
        XCTAssertTrue(dict.isValidWord("GAME"))
        
        // Less than 3 letters should fail
        XCTAssertFalse(dict.isValidWord("a"))
        XCTAssertFalse(dict.isValidWord("to"))
        
        // Gibberish should fail
        XCTAssertFalse(dict.isValidWord("xyzqvwpt"))
    }
}
