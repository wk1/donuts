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
        cornerRadius: CGFloat,
        limitRadiusWidthOnClose: Bool,
        start: Angle,
        sweep: CGFloat
    ) {
        
        self.center = center
        self.radius = radius
        self.innerRadius = innerRadius
        
        let sweepAngle = Angle.degrees(sweep * 360)
        let end = start + sweepAngle
        
        let maxInnerCornerRadius = DonutMath.maxCornerRadius(
            desired: cornerRadius,
            sweep: sweep,
            outerRadius: radius,
            innerRadius: innerRadius,
            for: .inner,
            limitRadiusWidthOnClose: limitRadiusWidthOnClose
        )
        let maxOuterCornerRadius = DonutMath.maxCornerRadius(
            desired: cornerRadius,
            sweep: sweep,
            outerRadius: radius,
            innerRadius: innerRadius,
            for: .outer,
            limitRadiusWidthOnClose: limitRadiusWidthOnClose
        )
        
        self.leadingEdgeOuterRim = DonutCorner(
            center: center,
            radius: radius,
            cornerRadius: maxOuterCornerRadius,
            angle: start,
            edge: .leading,
            rim: .outer
        )
        self.leadingEdgeInnerRim = DonutCorner(
            center: center,
            radius: innerRadius,
            cornerRadius: maxInnerCornerRadius,
            angle: start,
            edge: .leading,
            rim: .inner
        )
        self.trailingEdgeOuterRim = DonutCorner(
            center: center,
            radius: radius,
            cornerRadius: maxOuterCornerRadius,
            angle: end,
            edge: .trailing,
            rim: .outer
        )
        self.trailingEdgeInnerRim = DonutCorner(
            center: center,
            radius: innerRadius,
            cornerRadius: maxInnerCornerRadius,
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
