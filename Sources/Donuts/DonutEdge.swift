import SwiftUI

enum DonutEdge {
    case leading
    case trailing
    
    func calcInsettedAngle(for angle: Angle, radius: CGFloat, cornerRadius: CGFloat, rim: DonutRim) -> Angle {
        
        let inset = rim == .outer ? asin(cornerRadius / (radius - cornerRadius)) : asin(cornerRadius / (radius + cornerRadius))
        
        switch self {
        case .leading:
            return Angle(radians: angle.radians + inset)
        case .trailing:
            return Angle(radians: angle.radians - inset)
        }
    }
    
    func calcTangentAngle(for angle: Angle) -> Angle {
        let tangentOffset = Angle(radians: .pi / 2)
        switch self {
        case .leading:
            return angle - tangentOffset
        case .trailing:
            return angle + tangentOffset
        }
    }
}
