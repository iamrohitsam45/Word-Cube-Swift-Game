import SwiftUI
import UIKit

/// Aesthetic visual themes for the 3D cube and UI.
public enum GameTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case ceramic = "Ceramic"
    case obsidian = "Obsidian"
    case cyberpunk = "Cyberpunk"
    case sunset = "Sunset"
    
    public var id: String { rawValue }
    
    // SceneKit block face background color
    public var blockColor: UIColor {
        switch self {
        case .ceramic:
            return UIColor(red: 0.94, green: 0.93, blue: 0.90, alpha: 1.0)
        case .obsidian:
            return UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0)
        case .cyberpunk:
            return UIColor(red: 0.15, green: 0.08, blue: 0.22, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.98, green: 0.90, blue: 0.85, alpha: 1.0)
        }
    }
    
    // Letter typography color
    public var letterColor: UIColor {
        switch self {
        case .ceramic:
            return UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1.0)
        case .obsidian:
            return UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
        case .cyberpunk:
            return UIColor(red: 0.98, green: 0.92, blue: 0.30, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.25, green: 0.12, blue: 0.20, alpha: 1.0)
        }
    }
    
    // Selection highlight color (emission / glow)
    public var selectionHighlightColor: UIColor {
        switch self {
        case .ceramic:
            return UIColor(red: 1.0, green: 0.65, blue: 0.15, alpha: 1.0) // Warm amber
        case .obsidian:
            return UIColor(red: 0.0, green: 0.85, blue: 1.0, alpha: 1.0) // Electric cyan
        case .cyberpunk:
            return UIColor(red: 1.0, green: 0.15, blue: 0.65, alpha: 1.0) // Neon magenta
        case .sunset:
            return UIColor(red: 1.0, green: 0.40, blue: 0.20, alpha: 1.0) // Coral flame
        }
    }
    
    // Scene background color
    public var sceneBackgroundColor: UIColor {
        switch self {
        case .ceramic:
            return UIColor(red: 0.88, green: 0.89, blue: 0.87, alpha: 1.0)
        case .obsidian:
            return UIColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1.0)
        case .cyberpunk:
            return UIColor(red: 0.07, green: 0.04, blue: 0.12, alpha: 1.0)
        case .sunset:
            return UIColor(red: 0.18, green: 0.12, blue: 0.18, alpha: 1.0)
        }
    }
    
    // SwiftUI accent color
    public var accentColor: Color {
        Color(selectionHighlightColor)
    }
}
