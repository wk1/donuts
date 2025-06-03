import SwiftUI

public struct Donut: Shape {
    let start: Angle
    let ratio: CGFloat
    let sweep: CGFloat
    let desiredCornerRadius: CGFloat
    let limitRadiusWidthOnClose: Bool
    
    @Binding var debug: Bool
    
    public init(
        start: Angle = .zero,
        ratio: CGFloat = 0.5,
        sweep: CGFloat = 1.0,
        desiredCornerRadius: CGFloat = 0,
        limitRadiusWidthOnClose: Bool = true,
        debug: Binding<Bool> = .constant(false)
    ) {
        self.start = start
        self.ratio = ratio
        self.sweep = sweep
        self.desiredCornerRadius = desiredCornerRadius
        self.limitRadiusWidthOnClose = limitRadiusWidthOnClose
        
        self._debug = debug
    }
    
    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * ratio
        
        guard sweep < 1.0 else {
            return createFullDonut(center: center, radius: radius, innerRadius: innerRadius)
        }
        
        guard sweep > 0 else { return Path() }
        
        return createDonut(center: center, radius: radius, innerRadius: innerRadius)
    }
    
    private func createFullDonut(center: CGPoint, radius: CGFloat, innerRadius: CGFloat) -> Path {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: true
        )
        return path
    }
    
    private func createDonut(center: CGPoint, radius: CGFloat, innerRadius: CGFloat) -> Path {
        var path = Path()
        
        let geometry = DonutGeometry(
            center: center,
            radius: radius,
            innerRadius: innerRadius,
            cornerRadius: desiredCornerRadius,
            limitRadiusWidthOnClose: limitRadiusWidthOnClose,
            start: start,
            sweep: sweep
        )
        
        if debug {
            geometry.addDebugVisualization(to: &path)
        }
        
        /// Draw the path
        drawRoundedPath(to: &path, geometry: geometry)
        
        return path
    }
    
    private func drawRoundedPath(to path: inout Path, geometry g: DonutGeometry) {

        path.addArc(
            center: g.center,
            radius: g.radius,
            startAngle: g.leadingEdgeOuterRim.insettedAngle,
            endAngle: g.trailingEdgeOuterRim.insettedAngle,
            clockwise: false
        )
        
        g.trailingEdgeOuterRim.addCornerArc(to: &path)
        
        if ratio > 0 {
            g.trailingEdgeInnerRim.addCornerArc(to: &path)
            
            path.addArc(
                center: g.center,
                radius: g.innerRadius,
                startAngle: g.trailingEdgeInnerRim.insettedAngle,
                endAngle: g.leadingEdgeInnerRim.insettedAngle,
                clockwise: true
            )
            
            g.leadingEdgeInnerRim.addCornerArc(to: &path)
        } else {
            path.addLine(to: g.center)
            path.addLine(to: g.leadingEdgeOuterRim.trailingTangent)
        }
        
        g.leadingEdgeOuterRim.addCornerArc(to: &path)
    }
}
