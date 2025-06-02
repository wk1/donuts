import Foundation

struct DonutCornerRadius {
    let desiredRadius: CGFloat
    let sweep: CGFloat
    let radius: CGFloat
    let innerRadius: CGFloat
    
    func max(for rim: DonutRim) -> CGFloat {
        let halfSweep = sweep * .pi
        let sinHalfSweep = sin(halfSweep)
        
        let maxCornerHeight = (radius - innerRadius) / 2
        if rim == .inner {
            let maxInnerCornerWidth = innerRadius * sinHalfSweep / (1 - sinHalfSweep)
            return min(desiredRadius, maxCornerHeight, maxInnerCornerWidth)
        } else {
            let maxOuterCornerWidth = radius * sinHalfSweep / (1 + sinHalfSweep)
            return min(desiredRadius, maxCornerHeight, maxOuterCornerWidth)
        }
    }
}
