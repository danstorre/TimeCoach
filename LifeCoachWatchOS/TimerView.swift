import SwiftUI

public struct TimerView: View {
    
    public init() {}
    public var body: some View {
            Text("25:00")
                .accessibilityIdentifier("b")
    }
}

extension TimerView {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
