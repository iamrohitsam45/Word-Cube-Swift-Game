import SceneKit
import UIKit

/// Manages the SceneKit 3D world: camera, lighting, 3x3x3 blocks, orbit rotation, and animations.
public final class CubeSceneRenderer: NSObject {
    public let scene: SCNScene
    public let cameraNode: SCNNode
    public let cubeRootNode: SCNNode
    
    private let chainContainerNode: SCNNode
    private let chainRenderer: ChainConnectionRenderer
    private var blockNodes: [Coordinate3D: CubeNode] = [:]
    
    // Orbit rotation angles & momentum
    private var yaw: Float = -0.55
    private var pitch: Float = 0.45
    private var velocityYaw: Float = 0.0
    private var velocityPitch: Float = 0.0
    private var displayLink: CADisplayLink?
    
    // Zoom limits
    public var cameraDistance: Float = 6.2 {
        didSet {
            updateCameraPosition()
        }
    }
    
    public override init() {
        self.scene = SCNScene()
        self.cubeRootNode = SCNNode()
        self.cubeRootNode.name = "CubeRoot"
        self.cameraNode = SCNNode()
        self.chainContainerNode = SCNNode()
        self.chainRenderer = ChainConnectionRenderer(containerNode: chainContainerNode)
        
        super.init()
        
        setupScene()
        setupCamera()
        setupLighting()
        buildCubeGrid()
        startMomentumLoop()
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setupScene() {
        scene.rootNode.addChildNode(cubeRootNode)
        cubeRootNode.addChildNode(chainContainerNode)
        applyRotation()
    }
    
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 48
        cameraNode.camera?.automaticallyAdjustsZRange = true
        scene.rootNode.addChildNode(cameraNode)
        
        // Constraint to always look at the center of the cube
        let lookAtConstraint = SCNLookAtConstraint(target: cubeRootNode)
        lookAtConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAtConstraint]
        
        updateCameraPosition()
    }
    
    private func updateCameraPosition() {
        cameraNode.position = SCNVector3(0, 0, cameraDistance)
    }
    
    private func setupLighting() {
        // 1. Key directional light - Studio lighting without harsh shadow casting
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 1000
        keyLight.castsShadow = false // Clean studio lighting; eliminates shadow projection bugs
        
        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(4, 8, 6)
        keyLightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(keyLightNode)
        
        // 2. Fill directional light from opposite angle
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.intensity = 550
        fillLight.castsShadow = false
        
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-4, -2, -3)
        fillLightNode.eulerAngles = SCNVector3(Float.pi / 4, -Float.pi / 3, 0)
        scene.rootNode.addChildNode(fillLightNode)
        
        // 3. Ambient light for balanced uniform illumination
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500
        ambientLight.color = UIColor(white: 0.95, alpha: 1.0)
        
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // 4. Subtle top rim light for edge definition
        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.intensity = 350
        rimLight.castsShadow = false
        
        let rimNode = SCNNode()
        rimNode.light = rimLight
        rimNode.position = SCNVector3(0, 10, 0)
        rimNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        scene.rootNode.addChildNode(rimNode)
    }
    
    private func buildCubeGrid() {
        for coord in Coordinate3D.allCoordinates {
            let node = CubeNode(coordinate: coord)
            cubeRootNode.addChildNode(node)
            blockNodes[coord] = node
        }
    }
    
    // MARK: - Orbit Rotation & Momentum
    
    public func handleOrbitPan(deltaX: Float, deltaY: Float) {
        let sensitivity: Float = 0.006
        yaw += deltaX * sensitivity
        pitch += deltaY * sensitivity
        
        // Clamp pitch to avoid disorientation
        let maxPitch = Float.pi / 2.3
        pitch = max(-maxPitch, min(maxPitch, pitch))
        
        velocityYaw = deltaX * sensitivity
        velocityPitch = deltaY * sensitivity
        
        applyRotation()
    }
    
    public func handleOrbitPanEnded() {
        // Momentum loop takes over
    }
    
    private func startMomentumLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(momentumStep))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func momentumStep() {
        guard abs(velocityYaw) > 0.0001 || abs(velocityPitch) > 0.0001 else { return }
        
        yaw += velocityYaw
        pitch += velocityPitch
        
        let maxPitch = Float.pi / 2.3
        pitch = max(-maxPitch, min(maxPitch, pitch))
        
        // Damping friction
        let damping: Float = 0.92
        velocityYaw *= damping
        velocityPitch *= damping
        
        applyRotation()
    }
    
    private func applyRotation() {
        cubeRootNode.eulerAngles = SCNVector3(pitch, yaw, 0)
    }
    
    // MARK: - State Synchronization
    
    public func syncWithState(_ state: GameState) {
        // Scene background color
        scene.background.contents = state.theme.sceneBackgroundColor
        
        // Synchronize all 27 block nodes
        for coord in Coordinate3D.allCoordinates {
            guard let node = blockNodes[coord] else { continue }
            
            if let block = state.grid[coord] {
                switch block.status {
                case .cleared:
                    node.isHidden = true
                case .removing:
                    node.update(
                        letter: block.letter,
                        points: block.points,
                        status: .removing,
                        theme: state.theme
                    )
                case .idle, .selected:
                    if node.isHidden {
                        node.playSpawnAnimation()
                    }
                    node.update(
                        letter: block.letter,
                        points: block.points,
                        status: block.status,
                        theme: state.theme
                    )
                }
            } else {
                node.isHidden = true
            }
        }
        
        // Update 3D chain laser beam connections
        chainRenderer.updateConnections(chain: state.selectedChain, theme: state.theme)
    }
    
    /// Finds the CubeNode from a hit test result.
    public func findCubeNode(from hitNode: SCNNode) -> CubeNode? {
        var current: SCNNode? = hitNode
        while let node = current {
            if let cubeNode = node as? CubeNode {
                return cubeNode
            }
            current = node.parent
        }
        return nil
    }
}
