import SwiftUI

struct DonutGeometry {
    let center: CGPoint
    let radius: CGFloat
    let innerRadius: CGFloat
    let leadingEdgeOuterRim, leadingEdgeInnerRim, trailingEdgeOuterRim, trailingEdgeInnerRim: DonutCorner
    
    init(
        center: CGPoint,
        radius: CGFloat,
        innerRadius: CGFloat,
        cornerRadius: DonutCornerRadius,
        start: Angle,
        sweep: CGFloat
    ) {
        
        self.center = center
        self.radius = radius
        self.innerRadius = innerRadius
        
        let sweepAngle = Angle.degrees(sweep * 360)
        let end = start + sweepAngle
        
        self.leadingEdgeOuterRim = DonutCorner(
            center: center,
            radius: radius,
            cornerRadius: cornerRadius.max(for: .outer),
            angle: start,
            edge: .leading,
            rim: .outer
        )
        self.leadingEdgeInnerRim = DonutCorner(
            center: center,
            radius: innerRadius,
            cornerRadius: cornerRadius.max(for: .inner),
            angle: start,
            edge: .leading,
            rim: .inner
        )
        self.trailingEdgeOuterRim = DonutCorner(
            center: center,
            radius: radius,
            cornerRadius: cornerRadius.max(for: .outer),
            angle: end,
            edge: .trailing,
            rim: .outer
        )
        self.trailingEdgeInnerRim = DonutCorner(
            center: center,
            radius: innerRadius,
            cornerRadius: cornerRadius.max(for: .inner),
            angle: end,
            edge: .trailing,
            rim: .inner
        )
    }
    
    func addDebugVisualization(to path: inout Path) {
        [leadingEdgeOuterRim, leadingEdgeInnerRim, trailingEdgeOuterRim, trailingEdgeInnerRim].forEach { corner in
            corner.addDebugDots(to: &path)
        }
    }
}
