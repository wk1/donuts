import SwiftUI
import Donuts

struct DonutPlayground: View {
    public var body: some View {
        TabView {
            SingleSegmentPlayground()
                .tabItem {
                    Label("Single Segement", systemImage: "circle")
                }
            MultiSegmentPlayground()
                .tabItem {
                    Label("Multi Segment", systemImage: "chart.pie")
                }
        }
        
    }
}
