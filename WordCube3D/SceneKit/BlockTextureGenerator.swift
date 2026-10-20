import UIKit

/// Generates and caches high-resolution 2D textures for 3D cube block faces.
public final class BlockTextureGenerator: @unchecked Sendable {
    public static let shared = BlockTextureGenerator()
    
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "com.wordcube3d.texturecache")
    
    private init() {}
    
    /// Returns a high-res UIImage texture for a given letter, points, and theme.
    public func texture(
        for letter: Character,
        points: Int,
        theme: GameTheme,
        isSelected: Bool = false,
        selectionOrder: Int? = nil
    ) -> UIImage {
        let key = "\(letter)_\(points)_\(theme.rawValue)_\(isSelected)_\(selectionOrder ?? -1)"
        
        return queue.sync {
            if let cached = cache[key] {
                return cached
            }
            let image = renderTexture(
                letter: letter,
                points: points,
                theme: theme,
                isSelected: isSelected,
                selectionOrder: selectionOrder
            )
            cache[key] = image
            return image
        }
    }
    
    public func clearCache() {
        queue.sync {
            cache.removeAll()
        }
    }
    
    private func renderTexture(
        letter: Character,
        points: Int,
        theme: GameTheme,
        isSelected: Bool,
        selectionOrder: Int?
    ) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size)
            
            // 1. Background fill
            let bgColor = isSelected ? theme.blockColor.withAlphaComponent(0.92) : theme.blockColor
            cg.setFillColor(bgColor.cgColor)
            cg.fill(rect)
            
            // 2. Subtle beveled inner border
            let insetRect = rect.insetBy(dx: 18, dy: 18)
            let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 48)
            
            if isSelected {
                // Highlight border
                cg.setStrokeColor(theme.selectionHighlightColor.cgColor)
                cg.setLineWidth(16)
            } else {
                // Soft elegant border
                let borderColor = theme.letterColor.withAlphaComponent(0.12)
                cg.setStrokeColor(borderColor.cgColor)
                cg.setLineWidth(8)
            }
            path.stroke()
            
            // 3. Selection Order Badge (if selected)
            if let order = selectionOrder {
                let badgeRect = CGRect(x: 36, y: 36, width: 68, height: 68)
                let badgePath = UIBezierPath(ovalIn: badgeRect)
                cg.setFillColor(theme.selectionHighlightColor.cgColor)
                badgePath.fill()
                
                let orderStr = "\(order + 1)"
                let orderAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 40, weight: .heavy),
                    .foregroundColor: UIColor.black
                ]
                let orderSize = (orderStr as NSString).size(withAttributes: orderAttrs)
                let orderPoint = CGPoint(
                    x: badgeRect.midX - orderSize.width / 2,
                    y: badgeRect.midY - orderSize.height / 2
                )
                (orderStr as NSString).draw(at: orderPoint, withAttributes: orderAttrs)
            }
            
            // 4. Centered Letter
            let letterStr = String(letter).uppercased()
            let font = UIFont.systemFont(ofSize: 240, weight: .bold)
            let letterColor = isSelected ? theme.selectionHighlightColor : theme.letterColor
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: letterColor
            ]
            let letterSize = (letterStr as NSString).size(withAttributes: attrs)
            let letterPoint = CGPoint(
                x: (size.width - letterSize.width) / 2,
                y: (size.height - letterSize.height) / 2 - 15
            )
            (letterStr as NSString).draw(at: letterPoint, withAttributes: attrs)
            
            // 5. Point value subscript in bottom right corner
            let pointsStr = "\(points)"
            let pointsFont = UIFont.systemFont(ofSize: 76, weight: .bold)
            let pointsAttrs: [NSAttributedString.Key: Any] = [
                .font: pointsFont,
                .foregroundColor: letterColor.withAlphaComponent(0.85)
            ]
            let pointsSize = (pointsStr as NSString).size(withAttributes: pointsAttrs)
            let pointsPoint = CGPoint(
                x: size.width - pointsSize.width - 44,
                y: size.height - pointsSize.height - 36
            )
            (pointsStr as NSString).draw(at: pointsPoint, withAttributes: pointsAttrs)
        }
    }
}
