import SwiftUI
import Donuts

struct MultiSegmentPlayground: View {
    // Configuration state
    @State private var segmentCount = 1
    @State private var useFixedSegmentWidth = true
    @State private var fixedSegmentSize: CGFloat = 0.115 // 4% of full circle
    @State private var useFixedGapWidth = true
    @State private var fixedGapSize: CGFloat = 0.01 // 1% of full circle
    @State private var startAngle: Double = 0
    @State private var innerRadiusRatio: CGFloat = 0.8
    @State private var cornerRadius: CGFloat = 8
    
    @State private var showReflection: Bool = false
    @State private var reflectionOpacity: Double = 0.3
    @State private var reflectionBlur: Double = 0.0
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<segmentCount, id: \.self) { index in
                    let color = Color.randomColor(for: index)
                    let segmentStart = startAngle + Double(index) * (pieceAngle + gapAngle)
                    
                    Donut(
                        start: .degrees(segmentStart),
                        ratio: innerRadiusRatio,
                        sweep: pieceSize,
                        desiredCornerRadius: cornerRadius
                    )
                    .fill(color)
                    
                    if showReflection {
                        Donut(
                            start: .degrees(segmentStart),
                            ratio: innerRadiusRatio - 0.2,
                            sweep: pieceSize,
                            desiredCornerRadius: cornerRadius
                        )
                        .fill(color)
                        .blur(radius: reflectionBlur)
                        .opacity(reflectionOpacity)
                    }
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Segment Count: \(segmentCount)")
                        Slider(value: Binding(
                            get: { Double(segmentCount) },
                            set: { segmentCount = max(1, Int($0)) }
                        ), in: 1...40, step: 1)
                        
                        Divider()
                        
                        Text("Corner Radius: \(Int(cornerRadius))°")
                        Slider(value: $cornerRadius, in: 0...35)
                        
                        Divider()
                        
                        Text("Start Angle: \(Int(startAngle))°")
                        Slider(value: $startAngle, in: 0...359)
                        
                        Divider()
                        
                        Text("Inner Radius Ratio: \(innerRadiusRatio, specifier: "%.2f")")
                        Slider(value: $innerRadiusRatio, in: 0.1...0.9)
                        
                        Divider()
                        //reflection
                        Toggle("Show Reflection", isOn: $showReflection)
                            .tint(.accentColor)
                        Group {
                            Text("Reflection Opacity: \(reflectionOpacity, specifier: "%.2f")")
                            Slider(value: $reflectionOpacity, in: 0.0...1.0)
                            Text("Reflection Blur: \(reflectionBlur, specifier: "%.2f")")
                            Slider(value: $reflectionBlur, in: 0.0...35.0)
                        }.disabled(!showReflection)
                        
                        Divider()
                    }
                    
                    Group {
                        Toggle("Fixed Segment Width", isOn: $useFixedSegmentWidth)
                            .tint(.accentColor)
                        
                        if useFixedSegmentWidth {
                            HStack {
                                Text("Segment Size: \(fixedSegmentSize, specifier: "%.3f")")
                                Slider(value: $fixedSegmentSize, in: 0.000...0.2)
                            }
                        }
                        
                        Divider()
                        
                        Toggle("Fixed Gap Width", isOn: $useFixedGapWidth)
                            .tint(.accentColor)
                        
                        if useFixedGapWidth {
                            HStack {
                                Text("Gap Size: \(fixedGapSize, specifier: "%.3f")")
                                Slider(value: $fixedGapSize, in: 0.000...0.1)
                            }
                        }
                    }
                    
                    if spaceUtilization < 1.0 {
                        Text("Only using \(spaceUtilization * 100, specifier: "%.1f")% of the circle")
                            .foregroundColor(.orange)
                    } else if spaceUtilization > 1.0 {
                        Text("Space exceeded by \((spaceUtilization - 1.0) * 100, specifier: "%.1f")% - auto-adjusted")
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .frame(maxHeight: 300)
        }
    }
    
    // Sizing calculations
    private var adjustedSegmentSize: CGFloat {
        guard useFixedSegmentWidth else {
            return dynamicSegmentSize
        }
        
        if spaceUtilization > 1.0 {
            // Scale down if we exceed available space
            return fixedSegmentSize / CGFloat(spaceUtilization)
        }
        
        return fixedSegmentSize
    }
    
    private var adjustedGapSize: CGFloat {
        guard useFixedGapWidth else {
            return dynamicGapSize
        }
        
        if spaceUtilization > 1.0 {
            // Scale down if we exceed available space
            return fixedGapSize / CGFloat(spaceUtilization)
        }
        
        return fixedGapSize
    }
    
    private var dynamicSegmentSize: CGFloat {
        if useFixedGapWidth {
            let totalGapSpace = CGFloat(segmentCount) * fixedGapSize
            let availableSpace = max(0, 1.0 - totalGapSpace)
            return segmentCount > 0 ? availableSpace / CGFloat(segmentCount) : 0
        } else {
            // When both are dynamic, allocate a proportion to segments
            // Default: 80% to segments, 20% to gaps
            return 0.8 / CGFloat(max(1, segmentCount))
        }
    }
    
    private var dynamicGapSize: CGFloat {
        if useFixedSegmentWidth {
            let totalSegmentSpace = CGFloat(segmentCount) * fixedSegmentSize
            let availableSpace = max(0, 1.0 - totalSegmentSpace)
            return segmentCount > 0 ? availableSpace / CGFloat(segmentCount) : 0
        } else {
            // When both are dynamic, allocate a proportion to gaps
            // Default: 80% to segments, 20% to gaps
            return 0.2 / CGFloat(max(1, segmentCount))
        }
    }
    
    private var pieceSize: CGFloat {
        adjustedSegmentSize
    }
    
    private var gapSize: CGFloat {
        adjustedGapSize
    }
    
    private var spaceUtilization: CGFloat {
        let requiredSpace: CGFloat
        
        if useFixedSegmentWidth && useFixedGapWidth {
            requiredSpace = CGFloat(segmentCount) * (fixedSegmentSize + fixedGapSize)
        } else if useFixedSegmentWidth {
            requiredSpace = CGFloat(segmentCount) * fixedSegmentSize + CGFloat(segmentCount) * dynamicGapSize
        } else if useFixedGapWidth {
            requiredSpace = CGFloat(segmentCount) * dynamicSegmentSize + CGFloat(segmentCount) * fixedGapSize
        } else {
            // Both dynamic means we'll use exactly 100% of the space
            requiredSpace = 1.0
        }
        
        return requiredSpace
    }
    
    private var pieceAngle: Double {
        360.0 * Double(pieceSize)
    }
    
    private var gapAngle: Double {
        360.0 * Double(gapSize)
    }
}

extension Color {
    static func randomColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .cyan, .mint, .indigo]
        return colors[index % colors.count]
    }
}
