import SwiftUI

public struct Donut: Shape {
    /// Inner radius in relation to outer radius defined by the frame (0.0...1.0)
    var innerRadiusRatio: CGFloat = 0.5
    
    /// start angle - NOT SUPPORTED YET
    var startAngle: Double = 0
    
    /// Add a sweep value to define the end angle (0.0...1.0)
    var sweep: CGFloat = 1.0
    
    /// Desired corner radius - the actual corner radius may be smaller if the shape doesn’t allow for a larger radius
    var cornerRadius: CGFloat = 0
    
    /// Debug mode to visualize the important points and arcs
    @Binding var debug: Bool
    
    public init(innerRadiusRatio: CGFloat = 0.5, startAngle: Double = 0, sweep: CGFloat = 1.0, cornerRadius: CGFloat = 0, debug: Binding<Bool> = .constant(false)) {
        self.innerRadiusRatio = innerRadiusRatio
        self.startAngle = startAngle
        self.sweep = sweep
        self.cornerRadius = cornerRadius
        self._debug = debug
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        /// Calc center and radii
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRadiusRatio
        
        /// Calc end angle based on start angle and sweep
        let endAngle = startAngle + (sweep * 2 * .pi)

        /// Draw the path
        drawArcWithCornerRadius(path: &path, center: center, outerRadius: outerRadius,
                                innerRadius: innerRadius, startAngle: startAngle,
                                endAngle: endAngle, cornerRadius: cornerRadius)
        
        return path
    }
    
    /// Helper functions to calculate corner radius angles and centers
    private func calcCornerRadiusAngle(radius R: CGFloat, cornerRadius r: CGFloat, sweep s: CGFloat, clockwise: Bool = false) -> Angle {
        let α: CGFloat = s * 2 * .pi
        let β: CGFloat = !clockwise ? α - asin(r/(R-r)) : α + asin(r/(R-r))
        return Angle.radians(β)
    }
    
    private func calcCornerRadiusCenter(radius R: CGFloat, cornerRadius r: CGFloat, sweep s: CGFloat, center: CGPoint, clockwise: Bool = false) -> CGPoint {
        let β = calcCornerRadiusAngle(radius: R, cornerRadius: r, sweep: s, clockwise: clockwise)
        let xm: CGFloat = (R-r) * Foundation.cos(β.radians)
        let ym: CGFloat = (R-r) * Foundation.sin(β.radians)
        return CGPoint(x: center.x + xm, y: center.y + ym)
    }
    
    func calcLineTouchPoint(cornerRadius r: CGFloat, cornerCenter: CGPoint, sweep s: CGFloat, clockwise: Bool = false) -> CGPoint {
        let currentAngle = s * 2 * .pi
        let tangentAngle = !clockwise ? currentAngle + .pi/2 : currentAngle - .pi/2
        let touchX = cornerCenter.x + r * cos(tangentAngle)
        let touchY = cornerCenter.y + r * sin(tangentAngle)
        
        return CGPoint(x: touchX, y: touchY)
    }
    
    private func calcInnerCornerRadiusAngle(radius R: CGFloat, cornerRadius r: CGFloat, sweep s: CGFloat, clockwise: Bool = false) -> Angle {
        let α: CGFloat = s * 2 * .pi
        let β: CGFloat = !clockwise ? α - asin(r/(R+r)) : α + asin(r/(R+r))
        return Angle.radians(β)
    }
    
    private func calcInnerCornerRadiusCenter(radius R: CGFloat, cornerRadius r: CGFloat, sweep s: CGFloat, center: CGPoint, clockwise: Bool = false) -> CGPoint {
        let β = calcInnerCornerRadiusAngle(radius: R, cornerRadius: r, sweep: s, clockwise: clockwise)
        let xm: CGFloat = (R+r) * Foundation.cos(β.radians)
        let ym: CGFloat = (R+r) * Foundation.sin(β.radians)
        return CGPoint(x: center.x + xm, y: center.y + ym)
    }
    
    private func drawArcWithCornerRadius(path: inout Path, center: CGPoint, outerRadius: CGFloat,
                                         innerRadius: CGFloat, startAngle: Double, endAngle: Double,
                                         cornerRadius: CGFloat) {
        
        guard sweep > 0.0 else {
            // If Sweep <= 0.0, draw nothing
            return
        }
        
        guard sweep < 1.0 else {
            // If Sweep >= 1.0, draw a full donut
            path.addArc(
                center: center,
                radius: outerRadius,
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
            
            return
        }
        
        func swiftUIPoint(radius: CGFloat, angle: Double) -> CGPoint {
            return CGPoint(
                x: center.x + radius * Foundation.cos(angle),
                y: center.y + radius * Foundation.sin(angle)
            )
        }
        
        /// Calculate the max corner radius
        let arcHeight = outerRadius - innerRadius
        let maxCornerHeight = arcHeight / 2
        
        func maxCornerRadius(sweep s: CGFloat, outerRadius: CGFloat) -> CGFloat {
            let sweepAngle = s * 2 * .pi
            let halfSweep = sweepAngle / 2
            let sinHalfSweep = sin(halfSweep)
            let maxRadius = outerRadius * sinHalfSweep / (1 + sinHalfSweep)
            
            return maxRadius
        }
        
        func maxCornerRadiusInner(sweep s: CGFloat, outerRadius: CGFloat, innerRadius: CGFloat) -> CGFloat {
            let sweepAngle = s * 2 * .pi
            let halfSweep = sweepAngle / 2
            let sinHalfSweep = sin(halfSweep)
            let maxRadius = innerRadius * sinHalfSweep / (1 - sinHalfSweep)
            
            return maxRadius
        }
        
        let cornerRadiusOutside = min(cornerRadius, maxCornerHeight, maxCornerRadius(sweep: sweep, outerRadius: outerRadius))
        let cornerRadiusInside = min(cornerRadius, maxCornerHeight, maxCornerRadiusInner(sweep: sweep, outerRadius: outerRadius, innerRadius: innerRadius))
        
        // End Outer Corner
        let roundedOuterEndAngle = calcCornerRadiusAngle(radius: outerRadius, cornerRadius: cornerRadiusOutside, sweep: sweep)
        let roundedOuterEndCenter = calcCornerRadiusCenter(radius: outerRadius, cornerRadius: cornerRadiusOutside, sweep: sweep, center: center)
        let roundedOuterEnd = swiftUIPoint(radius: outerRadius, angle: roundedOuterEndAngle.radians)
        let roundedOuterEdgeEnd = calcLineTouchPoint(cornerRadius: cornerRadiusOutside, cornerCenter: roundedOuterEndCenter, sweep: sweep)
        
        
        // End Inner Corner
        let roundedInnerEndAngle = calcInnerCornerRadiusAngle(radius: innerRadius, cornerRadius: cornerRadiusInside, sweep: sweep)
        let roundedInnerEndCenter = calcInnerCornerRadiusCenter(radius: innerRadius, cornerRadius: cornerRadiusInside, sweep: sweep, center: center)
        let roundedInnerEnd = swiftUIPoint(radius: innerRadius, angle: roundedInnerEndAngle.radians)
        let roundedInnerEdgeEnd = calcLineTouchPoint(cornerRadius: cornerRadiusInside, cornerCenter: roundedInnerEndCenter, sweep: sweep)
        
        // Start Inner Corner
        let roundedInnerStartAngle = calcInnerCornerRadiusAngle(radius: innerRadius, cornerRadius: cornerRadiusInside, sweep: 0.0, clockwise: true)
        let roundedInnerStartCenter = calcInnerCornerRadiusCenter(radius: innerRadius, cornerRadius: cornerRadiusInside, sweep: 0.0, center: center, clockwise: true)
        let roundedInnerStart = swiftUIPoint(radius: innerRadius, angle: roundedInnerStartAngle.radians)
        let roundedInnerEdgeStart = calcLineTouchPoint(cornerRadius: cornerRadiusInside, cornerCenter: roundedInnerStartCenter, sweep: 0.0, clockwise: true)
        
        // Start Outer Corner
        let roundedOuterStartAngle = calcCornerRadiusAngle(radius: outerRadius, cornerRadius: cornerRadiusOutside, sweep: 0.0, clockwise: true)
        let roundedOuterStartCenter = calcCornerRadiusCenter(radius: outerRadius, cornerRadius: cornerRadiusOutside, sweep: 0.0, center: center, clockwise: true)
        let roundedOuterStart = swiftUIPoint(radius: outerRadius, angle: roundedOuterStartAngle.radians)
        let roundedOuterEdgeStart = calcLineTouchPoint(cornerRadius: cornerRadiusOutside, cornerCenter: roundedOuterStartCenter, sweep: 0.0, clockwise: true)
        
        if debug {
            
            addDebugDot(to: &path, at: roundedOuterEnd, radius: 1)
            addDebugDot(to: &path, at: roundedOuterEndCenter, radius: 1)
            addDebugDot(to: &path, at: roundedOuterEdgeEnd, radius: 1)
            
            addDebugDot(to: &path, at: roundedInnerEnd, radius: 1)
            addDebugDot(to: &path, at: roundedInnerEndCenter, radius: 1)
            addDebugDot(to: &path, at: roundedInnerEdgeEnd, radius: 1)
            
            addDebugDot(to: &path, at: roundedInnerStart, radius: 1)
            addDebugDot(to: &path, at: roundedInnerStartCenter, radius: 1)
            addDebugDot(to: &path, at: roundedInnerEdgeStart, radius: 1)
            
            addDebugDot(to: &path, at: roundedOuterStart, radius: 1)
            addDebugDot(to: &path, at: roundedOuterStartCenter, radius: 1)
            addDebugDot(to: &path, at: roundedOuterEdgeStart, radius: 1)
            
            addDebugDot(to: &path, at: roundedOuterEndCenter, radius: cornerRadiusOutside)
            addDebugDot(to: &path, at: roundedInnerEndCenter, radius: cornerRadiusInside)
            addDebugDot(to: &path, at: roundedOuterStartCenter, radius: cornerRadiusOutside)
            addDebugDot(to: &path, at: roundedInnerStartCenter, radius: cornerRadiusInside)
        }
        
        // Draw the outer arc
        path.addArc(center: center, radius: outerRadius,
                    startAngle: roundedOuterStartAngle,
                    endAngle: roundedOuterEndAngle,
                    clockwise: false)
        
        // Draw the trailing outer edge corner
        let angle1 = atan2(roundedOuterEnd.y - roundedOuterEndCenter.y, roundedOuterEnd.x - roundedOuterEndCenter.x)
        let angle2 = atan2(roundedOuterEdgeEnd.y - roundedOuterEndCenter.y, roundedOuterEdgeEnd.x - roundedOuterEndCenter.x)
        
        path.addArc(
            center: roundedOuterEndCenter,
            radius: cornerRadiusOutside,
            startAngle: .radians(angle1),
            endAngle:   .radians(angle2),
            clockwise:  false
        )
        
        // Draw the inner arc
        if innerRadiusRatio != 0 {
            // Draw the trailing inner edge corner
            let angle3 = atan2(roundedInnerEdgeEnd.y - roundedInnerEndCenter.y, roundedInnerEdgeEnd.x - roundedInnerEndCenter.x)
            let angle4 = atan2(roundedInnerEnd.y - roundedInnerEndCenter.y, roundedInnerEnd.x - roundedInnerEndCenter.x)
            
            path.addArc(
                center: roundedInnerEndCenter,
                radius: cornerRadiusInside,
                startAngle: .radians(angle3),
                endAngle:   .radians(angle4),
                clockwise:  false
            )
            
            // Draw the inner arc
            path.addArc(center: center, radius: innerRadius,
                        startAngle: roundedInnerEndAngle,
                        endAngle: roundedInnerStartAngle,
                        clockwise: true)
            
            // Draw the leading inner edge corner
            let angle5 = atan2(roundedInnerStart.y - roundedInnerStartCenter.y, roundedInnerStart.x - roundedInnerStartCenter.x)
            let angle6 = atan2(roundedInnerEdgeStart.y - roundedInnerStartCenter.y, roundedInnerEdgeStart.x - roundedInnerStartCenter.x)
            
            path.addArc(
                center: roundedInnerStartCenter,
                radius: cornerRadiusInside,
                startAngle: .radians(angle5),
                endAngle:   .radians(angle6),
                clockwise:  false
            )
        } else {
            path.addLine(to: center)
            path.addLine(to: roundedOuterEdgeStart)
        }
        
        // Draw the leading outer edge corner
        let angle7 = atan2(roundedOuterEdgeStart.y - roundedOuterStartCenter.y, roundedOuterEdgeStart.x - roundedOuterStartCenter.x)
        let angle8 = atan2(roundedOuterStart.y - roundedOuterStartCenter.y, roundedOuterStart.x - roundedOuterStartCenter.x)
        
        path.addArc(
            center: roundedOuterStartCenter,
            radius: cornerRadiusOutside,
            startAngle: .radians(angle7),
            endAngle:   .radians(angle8),
            clockwise:  false
        )
        
    }
    
    // Helper function to draw debug points
    func addDebugDot(to path: inout Path, at point: CGPoint, radius: CGFloat = 2) {
        let rect = CGRect(
            x: point.x - radius,
            y: point.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        path.addEllipse(in: rect)
    }
}
