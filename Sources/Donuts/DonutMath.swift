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
    
    /// Calculates the insetted angle for a corner based on the corner radius
    /// - Parameters:
    ///   - angle: Original angle on the arc
    ///   - radius: Main arc radius (outer or inner)
    ///   - cornerRadius: Radius of the corner arc
    ///   - rim: Whether this is on the outer or inner rim
    ///   - edge: Leading or trailing edge
    /// - Returns: Angle adjusted inward to accommodate the corner radius
    static func insettedAngle(
        for angle: Angle,
        radius: CGFloat,
        cornerRadius: CGFloat,
        rim: DonutRim,
        edge: DonutEdge
    ) -> Angle {
        let inset = rim == .outer
        ? asin(cornerRadius / (radius - cornerRadius))
        : asin(cornerRadius / (radius + cornerRadius))
        
        switch edge {
        case .leading:
            return Angle(radians: angle.radians + inset)
        case .trailing:
            return Angle(radians: angle.radians - inset)
        }
    }
    
    /// Calculates the tangent angle perpendicular to the given angle
    /// - Parameters:
    ///   - angle: Base angle
    ///   - edge: Leading or trailing edge determines direction
    /// - Returns: Angle perpendicular to the input angle
    static func tangentAngle(for angle: Angle, edge: DonutEdge) -> Angle {
        let tangentOffset = Angle(radians: .pi / 2)
        switch edge {
        case .leading:
            return angle - tangentOffset
        case .trailing:
            return angle + tangentOffset
        }
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
        let distance = rim == .outer
        ? radius - cornerRadius
        : radius + cornerRadius
        return pointOnCircle(center: center, radius: distance, angle: insettedAngle)
    }
    
    /// Calculates the tangent point where the corner arc meets the main arc
    /// - Parameters:
    ///   - center: Center of the main donut
    ///   - radius: Radius of the main arc
    ///   - insettedAngle: The angle adjusted for the corner inset
    /// - Returns: Point where corner arc touches the main arc
    static func arcTangentPoint(
        center: CGPoint,
        radius: CGFloat,
        insettedAngle: Angle
    ) -> CGPoint {
        return pointOnCircle(center: center, radius: radius, angle: insettedAngle)
    }
    
    /// Calculates the tangent point where the corner arc meets the edge
    /// - Parameters:
    ///   - cornerCenter: Center of the corner arc
    ///   - cornerRadius: Radius of the corner arc
    ///   - tangentAngle: Angle to the edge tangent point
    /// - Returns: Point where corner arc touches the edge
    static func edgeTangentPoint(
        cornerCenter: CGPoint,
        cornerRadius: CGFloat,
        tangentAngle: Angle
    ) -> CGPoint {
        return pointOnCircle(center: cornerCenter, radius: cornerRadius, angle: tangentAngle)
    }
    
    /// Calculates start and end angles for a corner arc
    /// - Parameters:
    ///   - cornerCenter: Center of the corner arc
    ///   - leadingTangent: Point where arc meets the main arc
    ///   - trailingTangent: Point where arc meets the edge
    ///   - edge: Leading or trailing edge
    ///   - rim: Outer or inner rim
    /// - Returns: Tuple of (startAngle, endAngle) in radians
    static func cornerArcAngles(
        cornerCenter: CGPoint,
        leadingTangent: CGPoint,
        trailingTangent: CGPoint,
        edge: DonutEdge,
        rim: DonutRim
    ) -> (start: CGFloat, end: CGFloat) {
        var startAngle = atan2(leadingTangent.y - cornerCenter.y, leadingTangent.x - cornerCenter.x)
        var endAngle = atan2(trailingTangent.y - cornerCenter.y, trailingTangent.x - cornerCenter.x)
        
        if (rim == .inner && edge == .trailing) || (rim == .outer && edge == .leading) {
            swap(&startAngle, &endAngle)
        }
        
        return (startAngle, endAngle)
    }
    
    /// Calculates the maximum allowed corner radius for a donut segment
    /// - Parameters:
    ///   - desiredRadius: The desired corner radius
    ///   - sweepAngle: The sweep angle of the donut segment (as fraction of full circle, e.g., 0.25 for 90°)
    ///   - outerRadius: The outer radius of the donut
    ///   - innerRadius: The inner radius of the donut
    ///   - rim: Whether to calculate for outer or inner rim
    /// - Returns: The maximum feasible corner radius
    static func maxCornerRadius(
        desired desiredRadius: CGFloat,
        sweep: CGFloat,
        outerRadius: CGFloat,
        innerRadius: CGFloat,
        for rim: DonutRim,
        limitRadiusWidthOnClose: Bool = true
    ) -> CGFloat {
        let halfSweepRadians = sweep * .pi
        let sinHalfSweep = sin(halfSweepRadians)
        
        // Maximum radius based on donut thickness
        let maxThicknessRadius = (outerRadius - innerRadius) / 2
        
        let maxWidthRadius: CGFloat
        if sweep > 0.5 && !limitRadiusWidthOnClose {
            maxWidthRadius = .infinity
        } else {
            if rim == .inner {
                // For inner rim: corner width is limited by inner circumference
                maxWidthRadius = innerRadius * sinHalfSweep / (1 - sinHalfSweep)
            } else {
                // For outer rim: corner width is limited by outer circumference
                maxWidthRadius = outerRadius * sinHalfSweep / (1 + sinHalfSweep)
            }
        }
        
        return min(desiredRadius, maxThicknessRadius, maxWidthRadius)
    }
}
