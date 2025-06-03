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
    
    /// Calculates the center point of a corner arc
    /// - Parameters:
    ///   - center: Center of the main donut
    ///   - radius: Radius of the main arc (outer or inner)
    ///   - cornerRadius: Radius of the corner arc
    ///   - insettedAngle: The angle adjusted for the corner inset
    ///   - rim: Whether this is on the outer or inner rim
    /// - Returns: Center point of the corner arc
    static func cornerCenter(
        center: CGPoint,
        radius: CGFloat,
        cornerRadius: CGFloat,
        insettedAngle: Angle,
        rim: DonutRim
    ) -> CGPoint {
        let distance = rim == .outer ? radius - cornerRadius : radius + cornerRadius
        return pointOnCircle(center: center, radius: distance, angle: insettedAngle)
    }
}
