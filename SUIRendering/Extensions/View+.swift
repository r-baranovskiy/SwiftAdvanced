import SwiftUI

extension View
{
    func showGraph() -> Self {
        print(Mirror(reflecting: self))
        return self
    }
}
