import SwiftUI

struct DonutCorner {
    let radius: CGFloat
    let angle: Angle
    let insettedAngle: Angle
    let cornerCenter: CGPoint
    let leadingTangent: CGPoint
    let trailingTangent: CGPoint
    var cornerStartAngle: CGFloat
    var cornerEndAngle: CGFloat
    
    init(
        center: CGPoint,
        radius: CGFloat,
        cornerRadius: CGFloat,
        angle: Angle,
        edge: DonutEdge,
        rim: DonutRim
    ) {
        self.radius = cornerRadius
        self.angle = angle
        
        self.insettedAngle = DonutMath.insettedAngle(
            for: angle,
            radius: radius,
            cornerRadius: cornerRadius,
            rim: rim,
            edge: edge
        )
        
        self.cornerCenter = DonutMath.cornerCenter(
            center: center,
            radius: radius,
            cornerRadius: cornerRadius,
            insettedAngle: insettedAngle,
            rim: rim
        )

        self.leadingTangent = DonutMath.arcTangentPoint(
            center: center,
            radius: radius,
            insettedAngle: insettedAngle
        )
        
        // Berührungspunkt mit Kante
        let tangentAngle = DonutMath.tangentAngle(for: angle, edge: edge)
        self.trailingTangent = DonutMath.edgeTangentPoint(
            cornerCenter: cornerCenter,
            cornerRadius: cornerRadius,
            tangentAngle: tangentAngle
        )
        
        let angles = DonutMath.cornerArcAngles(
            cornerCenter: cornerCenter,
            leadingTangent: leadingTangent,
            trailingTangent: trailingTangent,
            edge: edge,
            rim: rim
        )
        
        self.cornerStartAngle = angles.start
        self.cornerEndAngle = angles.end
    }
    
    func addCornerArc(to path: inout Path) {
        path.addArc(
            center: cornerCenter,
            radius: radius,
            startAngle: .radians(cornerStartAngle),
            endAngle: .radians(cornerEndAngle),
            clockwise: false
        )
    }
    
    
    func addDebugDots(to path: inout Path) {
        addDebugDot(to: &path, at: leadingTangent, radius: 1)
        addDebugDot(to: &path, at: cornerCenter, radius: 1)
        addDebugDot(to: &path, at: trailingTangent, radius: 1)
        addDebugDot(to: &path, at: cornerCenter, radius: radius)
    }
    
    private func addDebugDot(to path: inout Path, at point: CGPoint, radius: CGFloat) {
        let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        path.addEllipse(in: rect)
    }
}
