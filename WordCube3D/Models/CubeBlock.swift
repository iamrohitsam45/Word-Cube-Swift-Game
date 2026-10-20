import Foundation

/// Status of a block in the 3D cube.
public enum BlockStatus: Equatable, Codable, Sendable {
    case idle
    case selected(order: Int)
    case removing
    case cleared
    
    public var isSelected: Bool {
        if case .selected = self { return true }
        return false
    }
    
    public var isAvailable: Bool {
        switch self {
        case .idle, .selected:
            return true
        case .removing, .cleared:
            return false
        }
    }
}

/// Represents a single letter block in the 3x3x3 cube.
public struct CubeBlock: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let coordinate: Coordinate3D
    public var letter: Character
    public var points: Int
    public var status: BlockStatus
    
    public init(
        id: UUID = UUID(),
        coordinate: Coordinate3D,
        letter: Character,
        points: Int? = nil,
        status: BlockStatus = .idle
    ) {
        self.id = id
        self.coordinate = coordinate
        self.letter = letter
        self.points = points ?? CubeBlock.points(for: letter)
        self.status = status
    }
    
    enum CodingKeys: String, CodingKey {
        case id, coordinate, letter, points, status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        coordinate = try container.decode(Coordinate3D.self, forKey: .coordinate)
        let letterStr = try container.decode(String.self, forKey: .letter)
        letter = letterStr.first ?? " "
        points = try container.decode(Int.self, forKey: .points)
        status = try container.decode(BlockStatus.self, forKey: .status)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinate, forKey: .coordinate)
        try container.encode(String(letter), forKey: .letter)
        try container.encode(points, forKey: .points)
        try container.encode(status, forKey: .status)
    }
    
    /// Scrabble-inspired letter point values.
    public static func points(for letter: Character) -> Int {
        let upper = Character(letter.uppercased())
        switch upper {
        case "A", "E", "I", "O", "U", "L", "N", "S", "T", "R":
            return 1
        case "D", "G":
            return 2
        case "B", "C", "M", "P":
            return 3
        case "F", "H", "V", "W", "Y":
            return 4
        case "K":
            return 5
        case "J", "X":
            return 8
        case "Q", "Z":
            return 10
        default:
            return 1
        }
    }
    
    /// Weighted English letter distribution generator for realistic word formation.
    public static func randomLetter() -> Character {
        // Weighted distribution based on standard English word corpus
        let letterBag: [(Character, Int)] = [
            ("E", 12), ("A", 9), ("I", 9), ("O", 8), ("N", 6), ("R", 6),
            ("T", 6), ("L", 4), ("S", 4), ("U", 4), ("D", 4), ("G", 3),
            ("B", 2), ("C", 2), ("M", 2), ("P", 2), ("F", 2), ("H", 2),
            ("V", 2), ("W", 2), ("Y", 2), ("K", 1), ("J", 1), ("X", 1),
            ("Q", 1), ("Z", 1)
        ]
        
        let totalWeight = letterBag.reduce(0) { $0 + $1.1 }
        let randomValue = Int.random(in: 0..<totalWeight)
        
        var cumulative = 0
        for (char, weight) in letterBag {
            cumulative += weight
            if randomValue < cumulative {
                return char
            }
        }
        return "E"
    }
}
