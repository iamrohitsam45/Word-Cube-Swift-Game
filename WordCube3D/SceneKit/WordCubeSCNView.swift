import SwiftUI
import SceneKit

/// SwiftUI wrapper for SCNView supporting single-finger orbit rotation, pinch zoom, and block tap selection.
public struct WordCubeSCNView: UIViewRepresentable {
    public let state: GameState
    public let onBlockTapped: (Coordinate3D) -> Void
    
    public init(
        state: GameState,
        onBlockTapped: @escaping (Coordinate3D) -> Void
    ) {
        self.state = state
        self.onBlockTapped = onBlockTapped
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        let renderer = context.coordinator.renderer
        
        scnView.scene = renderer.scene
        scnView.pointOfView = renderer.cameraNode
        scnView.backgroundColor = state.theme.sceneBackgroundColor
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        scnView.autoenablesDefaultLighting = false
        scnView.allowsCameraControl = false // We implement custom orbit & inertia
        
        // Single finger pan for smooth orbit rotation
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = context.coordinator
        scnView.addGestureRecognizer(panGesture)
        
        // Pinch to zoom
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )
        scnView.addGestureRecognizer(pinchGesture)
        
        // Tap to select block
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        tapGesture.delegate = context.coordinator
        scnView.addGestureRecognizer(tapGesture)
        
        context.coordinator.scnView = scnView
        renderer.syncWithState(state)
        
        return scnView
    }
    
    public func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.renderer.syncWithState(state)
    }
    
    // MARK: - Coordinator
    
    public final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: WordCubeSCNView
        let renderer = CubeSceneRenderer()
        weak var scnView: SCNView?
        
        private var lastPanPoint: CGPoint = .zero
        private var initialZoomDistance: Float = 6.2
        
        init(_ parent: WordCubeSCNView) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = scnView else { return }
            let location = gesture.location(in: view)
            
            switch gesture.state {
            case .began:
                lastPanPoint = location
            case .changed:
                let deltaX = Float(location.x - lastPanPoint.x)
                let deltaY = Float(location.y - lastPanPoint.y)
                renderer.handleOrbitPan(deltaX: deltaX, deltaY: deltaY)
                lastPanPoint = location
            case .ended, .cancelled:
                renderer.handleOrbitPanEnded()
            default:
                break
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                initialZoomDistance = renderer.cameraDistance
            case .changed:
                let scale = Float(gesture.scale)
                let newDistance = initialZoomDistance / scale
                // Clamp zoom distance between 4.2 and 9.5
                renderer.cameraDistance = max(4.2, min(9.5, newDistance))
            default:
                break
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = scnView else { return }
            let point = gesture.location(in: view)
            
            let hitResults = view.hitTest(point, options: [
                .searchMode: SCNHitTestSearchMode.closest.rawValue,
                .ignoreHiddenNodes: true
            ])
            
            if let firstHit = hitResults.first,
               let cubeNode = renderer.findCubeNode(from: firstHit.node) {
                parent.onBlockTapped(cubeNode.coordinate)
            }
        }
        
        public func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            // Allow pan and pinch to work smoothly together
            if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer {
                return true
            }
            return false
        }
    }
}
