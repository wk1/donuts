import SwiftUI
import Donuts

struct SingleSegmentPlayground: View {
    @State private var ratio: CGFloat = 0.1
    @State private var sweep: CGFloat = 0.70
    @State private var cornerRadius: CGFloat = 42
    @State private var start: Angle = .zero
    @State var debug: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                if debug {
                    Donut(
                        start: start,
                        ratio: ratio,
                        sweep: sweep,
                        desiredCornerRadius: 0,
                        debug: .constant(false)
                    )
                    .stroke(.green, lineWidth: 1)
                }
                Donut(
                    start: start,
                    ratio: ratio,
                    sweep: sweep,
                    desiredCornerRadius: cornerRadius,
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
                    Text("Sweep: \(sweep, specifier: "%.2f")")
                    Slider(
                        value: $sweep,
                        in: 0.00...1.0,
                        label: { Text("Sweep: \(sweep, specifier: "%.2f")") }
                    )
                }
                
                HStack {
                    Text("Ratio: \(ratio, specifier: "%.2f")")
                    Slider(
                        value: $ratio,
                        in: 0...1.0,
                        label: { Text("Ratio: \(ratio, specifier: "%.2f")") }
                    )
                }
                
                HStack {
                    Text("Corner Radius: \(cornerRadius, specifier: "%.0f")")
                    Slider(
                        value: $cornerRadius,
                        in: 0...100,
                        label: { Text("Corner Radius: \(cornerRadius, specifier: "%.0f")") }
                    )
                }
                
                HStack {
                    Text("Start Angle: \(start.degrees, specifier: "%.0f")°")
                    Slider(
                        value: Binding(
                            get: { start.degrees },
                            set: { newDegrees in start = .degrees(newDegrees) }
                        ),
                        in: 0...360,
                        label: { Text("Start Angle: \(start.degrees, specifier: "%.0f")°") }
                    )
                }
            }
            .padding()
        }
    }
}
