import SwiftUI
import Donuts

struct MultiSegmentPlayground: View {

    let pieceCount = 20
    let gapSize: CGFloat = 0.02 // Gap als Anteil des vollen Kreises (2%)
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<pieceCount, id: \.self) { index in
                    let color = Color.randomColor(for: index)
                    
                    Donut(
                        start: .degrees(Double(index) * pieceAngle + Double(index) * gapAngle),
                        ratio: 0.8, // Innenradius (30% des Außenradius)
                        sweep: pieceSize,
                        desiredCornerRadius: 8
                    )
                    .fill(color)
                    
                    Donut(
                        start: .degrees(Double(index) * pieceAngle + Double(index) * gapAngle),
                        ratio: 0.6, // Innenradius (30% des Außenradius)
                        sweep: pieceSize,
                        desiredCornerRadius: 8
                    )
                    .fill(color)
                    .blur(radius: 2)
                    .opacity(0.3)
                }
            }
            .frame(width: 300, height: 300)
            .padding()            
        }
        
    }
    
    // Berechnung der Winkel
    private var totalGapSize: CGFloat {
        CGFloat(pieceCount) * gapSize
    }
    
    private var pieceSize: CGFloat {
        (1.0 - totalGapSize) / CGFloat(pieceCount)
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
