//
//  DonutPlayground.swift
//  Demo
//
//  Created by Christian Hoock on 01.06.25.
//
import SwiftUI
import Donuts

struct DonutPlayground: View {
    @State private var innerRadiusRatio: CGFloat = 0.1
    @State private var sweep: CGFloat = 0.70
    @State private var cornerRadius: CGFloat = 42
    @State private var startAngle: Double = 0
    @Binding var debug: Bool
    
    public var body: some View {
        VStack {
            ZStack {
                if debug {
                    Donut(
                        innerRadiusRatio: innerRadiusRatio,
                        startAngle: startAngle,
                        sweep: sweep,
                        cornerRadius: 0,
                        debug: .constant(false)
                    )
                    .stroke(.green, lineWidth: 1)
                }
                Donut(
                    innerRadiusRatio: innerRadiusRatio,
                    startAngle: startAngle,
                    sweep: sweep,
                    cornerRadius: cornerRadius,
                    debug: $debug
                )
                .if(debug) { content in
                    content.stroke(lineWidth: 1)
                } else: { content in
                    content.fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.84, blue: 0.0),
                                Color(red: 1.0, green: 0.92, blue: 0.23),
                                Color(red: 1.0, green: 0.84, blue: 0.0)
                            ]),
                            center: .center,
                            angle: .degrees(90)
                        )
                    )
                    .overlay {
                        content.stroke(.white, lineWidth: 1)
                    }
                }
            }
            .frame(width: 300, height: 300)
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $debug) {
                    Text("Debug Mode")
                }
                .tint(.accentColor)
                HStack {
                    Text("Inner Radius Ratio: \(innerRadiusRatio, specifier: "%.2f")")
                    Slider(value: $innerRadiusRatio, in: 0...1.0)
                }
                
                HStack {
                    Text("Sweep: \(sweep, specifier: "%.2f")")
                    Slider(value: $sweep, in: 0.00...1.0)
                }
                
                HStack {
                    Text("Corner Radius: \(cornerRadius, specifier: "%.0f")")
                    Slider(value: $cornerRadius, in: 0...100)
                }
                
                HStack {
                    Text("Start Angle: \(startAngle * 180 / .pi, specifier: "%.0f")°")
                    Slider(value: $startAngle, in: 0...(2 * .pi))
                }
            }
            .padding()
        }
    }
}
