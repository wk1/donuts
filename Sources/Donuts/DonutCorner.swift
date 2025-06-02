import SwiftUI

struct DonutCorner {
    let radius: CGFloat
    let angle: Angle
    let insettedAngle: Angle
    let cornerCenter: CGPoint
    let leadingTangent: CGPoint
    let trailingTangent: CGPoint
    
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
        let distance =  rim == .outer ? radius - cornerRadius : radius + cornerRadius
        self.cornerCenter = .onArc(center: center, radius: distance, angle: insettedAngle)
        
        // Punkte auf Bögen
        self.leadingTangent = .onArc(center: center, radius: radius, angle: insettedAngle)
        
        // Berührungspunkt mit Kante
        let tangentAngle = edge.calcTangentAngle(for: angle)
        self.trailingTangent = .onArc(center: cornerCenter, radius: cornerRadius, angle: tangentAngle)
    }
    
    func addCornerArc(to path: inout Path, reverse: Bool = false) {
        let startAngle = atan2(leadingTangent.y - cornerCenter.y, leadingTangent.x - cornerCenter.x)
        let endAngle = atan2(trailingTangent.y - cornerCenter.y, trailingTangent.x - cornerCenter.x)
        path.addArc(center: cornerCenter, radius: radius,
                    startAngle: reverse ? .radians(endAngle) : .radians(startAngle), endAngle: reverse ? .radians(startAngle) : .radians(endAngle), clockwise: false)
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
