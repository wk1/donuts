import Testing
@testable import Donuts
import Foundation
import SwiftUI

// Helper extension for floating point comparisons
extension CGFloat {
    func isApproximately(_ other: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        abs(self - other) < tolerance
    }
}

extension Double {
    func isApproximately(_ other: CGFloat, tolerance: CGFloat = 0.001) -> Bool {
        abs(self - other) < tolerance
    }
}

extension CGPoint {
    func isApproximately(_ other: CGPoint, tolerance: CGFloat = 0.001) -> Bool {
        x.isApproximately(other.x, tolerance: tolerance) &&
        y.isApproximately(other.y, tolerance: tolerance)
    }
}

// MARK: - Point on Circle Tests

@Test("Point on circle - basic angles")
func pointOnCircleBasicAngles() {
    // Point at 0° (right)
    let rightPoint = DonutMath.pointOnCircle(radius: 10, angle: .degrees(0))
    #expect(rightPoint.x.isApproximately(10))
    #expect(rightPoint.y.isApproximately(0))
    
    // Point at 90° (down in SwiftUI)
    let bottomPoint = DonutMath.pointOnCircle(radius: 5, angle: .degrees(90))
    #expect(bottomPoint.x.isApproximately(0))
    #expect(bottomPoint.y.isApproximately(5))
    
    // Point at 180° (left)
    let leftPoint = DonutMath.pointOnCircle(radius: 10, angle: .degrees(180))
    #expect(leftPoint.x.isApproximately(-10))
    #expect(leftPoint.y.isApproximately(0))
    
    // Point at 270° (up in SwiftUI)
    let topPoint = DonutMath.pointOnCircle(radius: 8, angle: .degrees(270))
    #expect(topPoint.x.isApproximately(0))
    #expect(topPoint.y.isApproximately(-8))
}

@Test("Point on circle - with offset center")
func pointOnCircleWithOffset() {
    let center = CGPoint(x: 10, y: 15)
    let point = DonutMath.pointOnCircle(center: center, radius: 5, angle: .degrees(0))
    #expect(point.x.isApproximately(15)) // 10 + 5
    #expect(point.y.isApproximately(15)) // 15 + 0
    
    let point180 = DonutMath.pointOnCircle(center: center, radius: 5, angle: .degrees(180))
    #expect(point180.x.isApproximately(5)) // 10 - 5
    #expect(point180.y.isApproximately(15)) // 15 + 0
}

@Test("Point on circle - edge cases")
func pointOnCircleEdgeCases() {
    // Zero radius
    let zeroRadius = DonutMath.pointOnCircle(radius: 0, angle: .degrees(45))
    #expect(zeroRadius == .zero)
    
    // Negative radius
    let negativeRadius = DonutMath.pointOnCircle(radius: -5, angle: .degrees(0))
    #expect(negativeRadius.x.isApproximately(-5))
    #expect(negativeRadius.y.isApproximately(0))
}

// MARK: - Insetted Angle Tests

@Test("Insetted angle - outer rim leading edge")
func insettedAngleOuterRimLeading() {
    let angle = Angle.degrees(90)
    let radius: CGFloat = 10
    let cornerRadius: CGFloat = 2
    
    let result = DonutMath.insettedAngle(
        for: angle,
        radius: radius,
        cornerRadius: cornerRadius,
        rim: .outer,
        edge: .leading
    )
    
    // Expected inset calculation: asin(2 / (10 - 2)) = asin(2/8) = asin(0.25)
    let expectedInset = asin(cornerRadius / (radius - cornerRadius))
    let expectedAngle = angle.radians + expectedInset
    
    #expect(result.radians.isApproximately(expectedAngle))
}

@Test("Insetted angle - outer rim trailing edge")
func insettedAngleOuterRimTrailing() {
    let angle = Angle.degrees(90)
    let radius: CGFloat = 10
    let cornerRadius: CGFloat = 2
    
    let result = DonutMath.insettedAngle(
        for: angle,
        radius: radius,
        cornerRadius: cornerRadius,
        rim: .outer,
        edge: .trailing
    )
    
    let expectedInset = asin(cornerRadius / (radius - cornerRadius))
    let expectedAngle = angle.radians - expectedInset
    
    #expect(result.radians.isApproximately(expectedAngle))
}

@Test("Insetted angle - inner rim leading edge")
func insettedAngleInnerRimLeading() {
    let angle = Angle.degrees(45)
    let radius: CGFloat = 6
    let cornerRadius: CGFloat = 1
    
    let result = DonutMath.insettedAngle(
        for: angle,
        radius: radius,
        cornerRadius: cornerRadius,
        rim: .inner,
        edge: .leading
    )
    
    // Expected inset: asin(1 / (6 + 1)) = asin(1/7)
    let expectedInset = asin(cornerRadius / (radius + cornerRadius))
    let expectedAngle = angle.radians + expectedInset
    
    #expect(result.radians.isApproximately(expectedAngle))
}

@Test("Insetted angle - inner rim trailing edge")
func insettedAngleInnerRimTrailing() {
    let angle = Angle.degrees(135)
    let radius: CGFloat = 8
    let cornerRadius: CGFloat = 1.5
    
    let result = DonutMath.insettedAngle(
        for: angle,
        radius: radius,
        cornerRadius: cornerRadius,
        rim: .inner,
        edge: .trailing
    )
    
    let expectedInset = asin(cornerRadius / (radius + cornerRadius))
    let expectedAngle = angle.radians - expectedInset
    
    #expect(result.radians.isApproximately(expectedAngle))
}

// MARK: - Tangent Angle Tests

@Test("Tangent angle - leading edge")
func tangentAngleLeading() {
    let angle = Angle.degrees(90)
    let result = DonutMath.tangentAngle(for: angle, edge: .leading)
    
    // Leading edge subtracts π/2, so 90° - 90° = 0°
    #expect(result.degrees.isApproximately(0))
}

@Test("Tangent angle - trailing edge")
func tangentAngleTrailing() {
    let angle = Angle.degrees(0)
    let result = DonutMath.tangentAngle(for: angle, edge: .trailing)
    
    // Trailing edge adds π/2, so 0° + 90° = 90°
    #expect(result.degrees.isApproximately(90))
}

@Test("Tangent angle - various angles")
func tangentAngleVarious() {
    // Test 45° leading
    let angle45Leading = DonutMath.tangentAngle(for: .degrees(45), edge: .leading)
    #expect(angle45Leading.degrees.isApproximately(-45))
    
    // Test 180° trailing
    let angle180Trailing = DonutMath.tangentAngle(for: .degrees(180), edge: .trailing)
    #expect(angle180Trailing.degrees.isApproximately(270))
}

// MARK: - Corner Center Tests

@Test("Corner center - outer rim")
func cornerCenterOuterRim() {
    let center = CGPoint.zero
    let radius: CGFloat = 10
    let cornerRadius: CGFloat = 2
    let insettedAngle = Angle.degrees(0)
    
    let result = DonutMath.cornerCenter(
        center: center,
        radius: radius,
        cornerRadius: cornerRadius,
        insettedAngle: insettedAngle,
        rim: .outer
    )
    
    // For outer rim: distance = radius - cornerRadius = 10 - 2 = 8
    // At 0°: point should be at (8, 0)
    #expect(result.x.isApproximately(8))
    #expect(result.y.isApproximately(0))
}

@Test("Corner center - inner rim")
func cornerCenterInnerRim() {
    let center = CGPoint.zero
    let radius: CGFloat = 6
    let cornerRadius: CGFloat = 1
    let insettedAngle = Angle.degrees(90)
    
    let result = DonutMath.cornerCenter(
        center: center,
        radius: radius,
        cornerRadius: cornerRadius,
        insettedAngle: insettedAngle,
        rim: .inner
    )
    
    // For inner rim: distance = radius + cornerRadius = 6 + 1 = 7
    // At 90°: point should be at (0, 7)
    #expect(result.x.isApproximately(0))
    #expect(result.y.isApproximately(7))
}

// MARK: - Arc Tangent Point Tests

@Test("Arc tangent point")
func arcTangentPoint() {
    let center = CGPoint(x: 5, y: 5)
    let radius: CGFloat = 8
    let insettedAngle = Angle.degrees(45)
    
    let result = DonutMath.arcTangentPoint(
        center: center,
        radius: radius,
        insettedAngle: insettedAngle
    )
    
    // At 45°: cos(45°) = sin(45°) ≈ 0.707
    let expected = CGPoint(
        x: 5 + 8 * cos(Angle.degrees(45).radians),
        y: 5 + 8 * sin(Angle.degrees(45).radians)
    )
    
    #expect(result.isApproximately(expected))
}

// MARK: - Edge Tangent Point Tests

@Test("Edge tangent point")
func edgeTangentPoint() {
    let cornerCenter = CGPoint(x: 3, y: 4)
    let cornerRadius: CGFloat = 2
    let tangentAngle = Angle.degrees(180)
    
    let result = DonutMath.edgeTangentPoint(
        cornerCenter: cornerCenter,
        cornerRadius: cornerRadius,
        tangentAngle: tangentAngle
    )
    
    // At 180°: point should be 2 units to the left of center
    #expect(result.x.isApproximately(1)) // 3 - 2
    #expect(result.y.isApproximately(4)) // 4 + 0
}

// MARK: - Corner Arc Angles Tests

@Test("Corner arc angles - outer rim leading edge")
func cornerArcAnglesOuterLeading() {
    let cornerCenter = CGPoint.zero
    let leadingTangent = CGPoint(x: 1, y: 0) // 0° from center
    let trailingTangent = CGPoint(x: 0, y: 1) // 90° from center
    
    let result = DonutMath.cornerArcAngles(
        cornerCenter: cornerCenter,
        leadingTangent: leadingTangent,
        trailingTangent: trailingTangent,
        edge: .leading,
        rim: .outer
    )
    
    // For outer rim + leading edge, angles should be swapped
    #expect(result.start.isApproximately(.pi / 2)) // 90°
    #expect(result.end.isApproximately(0)) // 0°
}

@Test("Corner arc angles - inner rim trailing edge")
func cornerArcAnglesInnerTrailing() {
    let cornerCenter = CGPoint.zero
    let leadingTangent = CGPoint(x: 1, y: 0) // 0°
    let trailingTangent = CGPoint(x: 0, y: 1) // 90°
    
    let result = DonutMath.cornerArcAngles(
        cornerCenter: cornerCenter,
        leadingTangent: leadingTangent,
        trailingTangent: trailingTangent,
        edge: .trailing,
        rim: .inner
    )
    
    // For inner rim + trailing edge, angles should be swapped
    #expect(result.start.isApproximately(.pi / 2)) // 90°
    #expect(result.end.isApproximately(0)) // 0°
}

@Test("Corner arc angles - no swap case")
func cornerArcAnglesNoSwap() {
    let cornerCenter = CGPoint.zero
    let leadingTangent = CGPoint(x: 1, y: 0) // 0°
    let trailingTangent = CGPoint(x: 0, y: 1) // 90°
    
    let result = DonutMath.cornerArcAngles(
        cornerCenter: cornerCenter,
        leadingTangent: leadingTangent,
        trailingTangent: trailingTangent,
        edge: .trailing,
        rim: .outer
    )
    
    // No swap condition met, angles should remain as calculated
    #expect(result.start.isApproximately(0)) // 0°
    #expect(result.end.isApproximately(.pi / 2)) // 90°
}

// MARK: - Edge Case Tests
@Test("Very small corner radius")
func verySmallCornerRadius() {
    let angle = Angle.degrees(45)
    let radius: CGFloat = 100
    let cornerRadius: CGFloat = 0.01
    
    let result = DonutMath.insettedAngle(
        for: angle,
        radius: radius,
        cornerRadius: cornerRadius,
        rim: .outer,
        edge: .leading
    )
    
    // With very small corner radius, inset should be very small
    let expectedInset = asin(cornerRadius / (radius - cornerRadius))
    #expect(expectedInset < 0.01) // Very small inset
    #expect(result.radians.isApproximately(angle.radians + expectedInset))
}

// MARK: - Corner Radius Tests
@Test("Max corner radius should not exceed desired radius")
    func maxCornerRadiusDoesNotExceedDesired() {
        let desiredRadius: CGFloat = 10
        let sweep: CGFloat = 0.25 // 90°
        let outerRadius: CGFloat = 100
        let innerRadius: CGFloat = 50
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        #expect(maxOuter <= desiredRadius)
        #expect(maxInner <= desiredRadius)
    }
    
    @Test("Max corner radius should not exceed donut thickness divided by 2")
    func maxCornerRadiusDoesNotExceedHalfThickness() {
        let desiredRadius: CGFloat = 100 // Sehr groß
        let sweep: CGFloat = 0.1 // Kleiner Winkel
        let outerRadius: CGFloat = 60
        let innerRadius: CGFloat = 40
        let expectedMaxThickness = (outerRadius - innerRadius) / 2 // 10
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        #expect(maxOuter <= expectedMaxThickness)
        #expect(maxInner <= expectedMaxThickness)
    }
    
    @Test("Max corner radius for narrow sweep angle")
    func maxCornerRadiusForNarrowSweep() {
        let desiredRadius: CGFloat = 20
        let sweep: CGFloat = 0.05 // Sehr schmaler Winkel (18°)
        let outerRadius: CGFloat = 100
        let innerRadius: CGFloat = 80
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        // Bei sehr schmalen Winkeln sollte der Corner-Radius stark begrenzt sein
        #expect(maxOuter < desiredRadius)
        #expect(maxInner < desiredRadius)
    }
    
    @Test("Max corner radius for wide sweep angle")
    func maxCornerRadiusForWideSweep() {
        let desiredRadius: CGFloat = 5
        let sweep: CGFloat = 0.4 // Breiter Winkel (144°)
        let outerRadius: CGFloat = 100
        let innerRadius: CGFloat = 80
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        // Bei breiten Winkeln sollte der gewünschte Radius erreichbar sein
        #expect(maxOuter == desiredRadius)
        #expect(maxInner == desiredRadius)
    }
    
    @Test("Max corner radius difference between inner and outer rim")
    func maxCornerRadiusDifferenceBetweenRims() {
        let desiredRadius: CGFloat = 15
        let sweep: CGFloat = 0.2 // 72°
        let outerRadius: CGFloat = 100
        let innerRadius: CGFloat = 50
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        // Inner rim hat normalerweise stärkere Beschränkungen bei gleichen Parametern
        #expect(maxInner <= maxOuter)
    }
    
    @Test("Max corner radius with zero sweep angle")
    func maxCornerRadiusWithZeroSweep() {
        let desiredRadius: CGFloat = 10
        let sweep: CGFloat = 0
        let outerRadius: CGFloat = 100
        let innerRadius: CGFloat = 50
        
        let maxOuter = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .outer
        )
        
        let maxInner = DonutMath.maxCornerRadius(
            desired: desiredRadius,
            sweep: sweep,
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            for: .inner
        )
        
        // Bei Sweep-Winkel 0 sollte der Corner-Radius 0 sein
        #expect(maxOuter == 0)
        #expect(maxInner == 0)
    }
