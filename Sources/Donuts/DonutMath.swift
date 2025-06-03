import SwiftUI

struct DonutMath {
    
    /// Calculates a point on a circle based on center, radius and angle
    /// - Parameters:
    ///   - center: Center point of the circle (default: .zero)
    ///   - radius: Radius of the circle
    ///   - angle: Angle from positive x-axis (0° = right, 90° = down in SwiftUI coordinate system)
    /// - Returns: Point on the circle at the specified angle
    static func pointOnCircle(
        center: CGPoint = .zero,
        radius: CGFloat,
        angle: Angle
    ) -> CGPoint {
        return CGPoint(
            x: center.x + radius * CGFloat(cos(angle.radians)),
            y: center.y + radius * CGFloat(sin(angle.radians))
        )
    }
}
