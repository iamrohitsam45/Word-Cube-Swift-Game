import SceneKit
import UIKit

/// SCNNode representing a single letter cube block in 3D space.
public final class CubeNode: SCNNode {
    public let coordinate: Coordinate3D
    public private(set) var currentLetter: Character = " "
    public private(set) var currentPoints: Int = 1
    public private(set) var currentStatus: BlockStatus = .idle
    public private(set) var currentTheme: GameTheme = .ceramic
    
    private let boxGeometry: SCNBox
    private var isAnimatingRemoval = false
    
    public init(coordinate: Coordinate3D) {
        self.coordinate = coordinate
        // Box with chamfered rounded edges
        self.boxGeometry = SCNBox(width: 0.88, height: 0.88, length: 0.88, chamferRadius: 0.08)
        super.init()
        
        self.geometry = boxGeometry
        self.position = coordinate.toScenePosition()
        self.name = "CubeBlock_\(coordinate.x)_\(coordinate.y)_\(coordinate.z)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Updates block appearance based on state, selection order, and theme.
    public func update(
        letter: Character,
        points: Int,
        status: BlockStatus,
        theme: GameTheme
    ) {
        let letterChanged = (letter != currentLetter || points != currentPoints || theme != currentTheme)
        let statusChanged = (status != currentStatus)
        
        guard letterChanged || statusChanged else { return }
        
        let oldStatus = currentStatus
        self.currentLetter = letter
        self.currentPoints = points
        self.currentStatus = status
        self.currentTheme = theme
        
        // Handle removal state
        if case .removing = status {
            if !isAnimatingRemoval {
                playRemovalAnimation()
            }
            return
        }
        
        // Update face textures
        let isSelected = status.isSelected
        var selectionOrder: Int? = nil
        if case .selected(let order) = status {
            selectionOrder = order
        }
        
        let texture = BlockTextureGenerator.shared.texture(
            for: letter,
            points: points,
            theme: theme,
            isSelected: isSelected,
            selectionOrder: selectionOrder
        )
        
        let material = SCNMaterial()
        material.diffuse.contents = texture
        material.roughness.contents = 0.35
        material.metalness.contents = 0.1
        
        if isSelected {
            material.emission.contents = theme.selectionHighlightColor.withAlphaComponent(0.3)
        } else {
            material.emission.contents = UIColor.black
        }
        
        // Apply material to all 6 faces of the cube
        self.geometry?.materials = Array(repeating: material, count: 6)
        
        // Selection animation
        if isSelected && !oldStatus.isSelected {
            playSelectionBounce()
        } else if !isSelected && oldStatus.isSelected {
            playDeselection()
        }
    }
    
    /// Punchy scale bounce when block is selected into word chain.
    public func playSelectionBounce() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.15
        self.scale = SCNVector3(1.08, 1.08, 1.08)
        SCNTransaction.commit()
    }
    
    /// Smooth scale return when block is unselected.
    public func playDeselection() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        self.scale = SCNVector3(1.0, 1.0, 1.0)
        SCNTransaction.commit()
    }
    
    /// Smooth block removal animation when a valid 3+ letter word is submitted.
    public func playRemovalAnimation(completion: (() -> Void)? = nil) {
        guard !isAnimatingRemoval else { return }
        isAnimatingRemoval = true
        
        // Sparkle burst particle system
        let particles = SCNParticleSystem()
        particles.birthRate = 350
        particles.loops = false
        particles.emissionDuration = 0.15
        particles.particleLifeSpan = 0.45
        particles.particleColor = currentTheme.selectionHighlightColor
        particles.particleSize = 0.04
        particles.blendMode = .additive
        particles.spreadingAngle = 180
        particles.particleVelocity = 1.8
        particles.particleVelocityVariation = 0.8
        
        // Circular soft glow particle texture
        let particleImage = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24)).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(x: 2, y: 2, width: 20, height: 20))
        }
        particles.particleImage = particleImage
        self.addParticleSystem(particles)
        
        // Shrink, spin, and fade
        let shrink = SCNAction.scale(to: 0.001, duration: 0.35)
        let rotate = SCNAction.rotateBy(x: 1.2, y: 1.5, z: 0.3, duration: 0.35)
        let fade = SCNAction.fadeOut(duration: 0.32)
        let group = SCNAction.group([shrink, rotate, fade])
        
        self.runAction(group) { [weak self] in
            self?.removeAllParticleSystems()
            self?.isHidden = true
            self?.isAnimatingRemoval = false
            completion?()
        }
    }
    
    /// Spawns block with an elastic drop-in bounce.
    public func playSpawnAnimation() {
        self.removeAllParticleSystems()
        self.isHidden = false
        self.rotation = SCNVector4(0, 0, 0, 0)
        self.scale = SCNVector3(0.001, 0.001, 0.001)
        self.opacity = 1.0
        
        let grow = SCNAction.scale(to: 1.0, duration: 0.35)
        grow.timingMode = .easeOut
        self.runAction(grow)
    }
}
