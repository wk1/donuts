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
        // Ecken-Winkel berechnen
        self.insettedAngle = edge.calcInsettedAngle(for: angle, radius: radius, cornerRadius: cornerRadius, rim: rim)
        
        // Ecken-Zentrum
        self.cornerCenter = DonutMath.cornerCenter(
            center: center,
            radius: radius,
            cornerRadius: cornerRadius,
            insettedAngle: insettedAngle,
            rim: rim
        )
        
        // Punkte auf Bögen
        self.leadingTangent = DonutMath.pointOnCircle(center: center, radius: radius, angle: insettedAngle)
        
        // Berührungspunkt mit Kante
        let tangentAngle = edge.calcTangentAngle(for: angle)
        self.trailingTangent = DonutMath.pointOnCircle(center: cornerCenter, radius: cornerRadius, angle: tangentAngle)
        
        cornerStartAngle = atan2(leadingTangent.y - cornerCenter.y, leadingTangent.x - cornerCenter.x)
        cornerEndAngle = atan2(trailingTangent.y - cornerCenter.y, trailingTangent.x - cornerCenter.x)
        
        if rim == .inner && edge == .trailing || rim == .outer && edge == .leading {
            swap(&cornerStartAngle, &cornerEndAngle)
        }
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
