import Foundation

/// Record of a successfully validated word submitted during the game session.
public struct FoundWord: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public let word: String
    public let points: Int
    public let multiplier: Double
    public let timestamp: Date
    public let coordinates: [Coordinate3D]
    
    public init(
        id: UUID = UUID(),
        word: String,
        points: Int,
        multiplier: Double,
        timestamp: Date = Date(),
        coordinates: [Coordinate3D]
    ) {
        self.id = id
        self.word = word
        self.points = points
        self.multiplier = multiplier
        self.timestamp = timestamp
        self.coordinates = coordinates
    }
}
