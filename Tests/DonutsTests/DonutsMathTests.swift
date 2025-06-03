import Testing
@testable import Donuts
import Foundation

@Test("Point on circle - basic angles")
func pointOnCircleBasicAngles() {
    // Point at 0° (right)
    let rightPoint = DonutMath.pointOnCircle(radius: 10, angle: .degrees(0))
    #expect(abs(rightPoint.x - 10) < 0.001)
    #expect(abs(rightPoint.y - 0) < 0.001)
    
    // Point at 90° (down in SwiftUI)
    let bottomPoint = DonutMath.pointOnCircle(radius: 5, angle: .degrees(90))
    #expect(abs(bottomPoint.x - 0) < 0.001)
    #expect(abs(bottomPoint.y - 5) < 0.001)
    
    // Point at 180° (left)
    let leftPoint = DonutMath.pointOnCircle(radius: 10, angle: .degrees(180))
    #expect(abs(leftPoint.x - (-10)) < 0.001)
    #expect(abs(leftPoint.y - 0) < 0.001)
}

@Test("Point on circle - with offset center")
func pointOnCircleWithOffset() {
    let offsetPoint = DonutMath.pointOnCircle(
        center: CGPoint(x: 10, y: 10),
        radius: 5,
        angle: .degrees(180)
    )
    #expect(abs(offsetPoint.x - 5) < 0.001)
    #expect(abs(offsetPoint.y - 10) < 0.001)
}

@Test("Point on circle - edge cases")
func pointOnCircleEdgeCases() {
    // Zero radius
    let zeroRadius = DonutMath.pointOnCircle(radius: 0, angle: .degrees(45))
    #expect(zeroRadius == .zero)
    
    // Negative radius
    let negativeRadius = DonutMath.pointOnCircle(radius: -5, angle: .degrees(0))
    #expect(abs(negativeRadius.x - (-5)) < 0.001)
}
