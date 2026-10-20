import Foundation
import SceneKit

/// Represents an integer 3D coordinate in the 3x3x3 cube grid.
public struct Coordinate3D: Hashable, Equatable, Codable, Sendable, CustomStringConvertible {
    public let x: Int
    public let y: Int
    public let z: Int
    
    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public var description: String {
        "(\(x), \(y), \(z))"
    }
    
    /// Checks if two coordinates are adjacent in 3D Moore neighborhood (sharing face, edge, or vertex).
    /// Two blocks are adjacent if the maximum difference along any axis is 1, and they are not identical.
    public func isAdjacent(to other: Coordinate3D) -> Bool {
        let dx = abs(x - other.x)
        let dy = abs(y - other.y)
        let dz = abs(z - other.z)
        
        let maxDelta = max(dx, max(dy, dz))
        return maxDelta == 1
    }
    
    /// Converts the grid index (0...2) to a centered 3D vector for SceneKit nodes.
    public func toScenePosition(spacing: Float = 1.08) -> SCNVector3 {
        // Grid indices: 0 -> -1, 1 -> 0, 2 -> +1
        let cx = Float(x - 1) * spacing
        let cy = Float(y - 1) * spacing
        let cz = Float(z - 1) * spacing
        return SCNVector3(cx, cy, cz)
    }
    
    /// All 27 coordinates in a 3x3x3 cube.
    public static var allCoordinates: [Coordinate3D] {
        var coords: [Coordinate3D] = []
        for x in 0..<3 {
            for y in 0..<3 {
                for z in 0..<3 {
                    coords.append(Coordinate3D(x: x, y: y, z: z))
                }
            }
        }
        return coords
    }
    
    /// Identifies whether this block is strictly internal (center block at 1,1,1).
    public var isCenter: Bool {
        x == 1 && y == 1 && z == 1
    }
}
