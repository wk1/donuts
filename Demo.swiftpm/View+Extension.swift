import SwiftUI

public extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, @ViewBuilder transform: (Self) -> some View, @ViewBuilder else elseTransform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}
