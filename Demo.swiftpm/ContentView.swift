import SwiftUI

struct ContentView: View {
    @State var debug = true
    
    var body: some View {
        DonutPlayground(debug: $debug)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
