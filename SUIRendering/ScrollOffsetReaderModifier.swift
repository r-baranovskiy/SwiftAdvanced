import SwiftUI

@available(iOS 17.0, *)
struct ScrollOffsetReaderModifier: ViewModifier
{
    let action: (CGFloat) -> Void
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .task(id: geo.frame(in: .scrollView)) {
                            action(geo.frame(in: .scrollView).minY)
                        }
                }
            )
    }
}

@available(iOS 17.0, *)
extension View
{
    func scrollOffset(action: @escaping (CGFloat) -> Void) -> some View {
        modifier(ScrollOffsetReaderModifier(action: action))
    }
}
