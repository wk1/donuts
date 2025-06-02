import SwiftUI

extension CGPoint {
    static func onArc(center: CGPoint = .zero, radius: CGFloat, angle: Angle) -> CGPoint {
        return CGPoint(
            x: center.x + radius * Foundation.cos(angle.radians),
            y: center.y + radius * Foundation.sin(angle.radians)
        )
    }
}
