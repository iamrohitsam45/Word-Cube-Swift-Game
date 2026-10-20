import SceneKit
import UIKit

/// Renders glowing 3D connector beams between consecutively selected blocks in the word chain.
public final class ChainConnectionRenderer {
    private let containerNode: SCNNode
    
    public init(containerNode: SCNNode) {
        self.containerNode = containerNode
    }
    
    /// Updates visible connection beams based on current chain and theme.
    public func updateConnections(chain: [Coordinate3D], theme: GameTheme) {
        // Clear previous lines
        containerNode.childNodes.forEach { $0.removeFromParentNode() }
        
        guard chain.count >= 2 else { return }
        
        for i in 0..<(chain.count - 1) {
            let startPos = chain[i].toScenePosition()
            let endPos = chain[i + 1].toScenePosition()
            
            let beam = makeCylinderBeam(
                from: startPos,
                to: endPos,
                radius: 0.035,
                color: theme.selectionHighlightColor
            )
            containerNode.addChildNode(beam)
        }
    }
    
    private func makeCylinderBeam(
        from v1: SCNVector3,
        to v2: SCNVector3,
        radius: CGFloat,
        color: UIColor
    ) -> SCNNode {
        let dx = v2.x - v1.x
        let dy = v2.y - v1.y
        let dz = v2.z - v1.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)
        
        guard distance > 0.001 else { return SCNNode() }
        
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(distance))
        let material = SCNMaterial()
        material.lightingModel = .constant
        material.diffuse.contents = color
        material.emission.contents = color
        cylinder.materials = [material]
        
        let node = SCNNode(geometry: cylinder)
        node.castsShadow = false
        node.position = SCNVector3((v1.x + v2.x) / 2, (v1.y + v2.y) / 2, (v1.z + v2.z) / 2)
        
        // Orient cylinder from default (0, 1, 0) towards target direction
        let dirNorm = SCNVector3(dx / distance, dy / distance, dz / distance)
        let axis = SCNVector3(dirNorm.z, 0, -dirNorm.x)
        let dot = dirNorm.y
        let angle = acos(max(-1.0, min(1.0, dot)))
        
        let axisLen = sqrt(axis.x * axis.x + axis.z * axis.z)
        if axisLen > 0.001 {
            node.rotation = SCNVector4(axis.x / axisLen, 0, axis.z / axisLen, angle)
        } else if dot < 0 {
            node.rotation = SCNVector4(1, 0, 0, Float.pi)
        }
        
        return node
    }
}
