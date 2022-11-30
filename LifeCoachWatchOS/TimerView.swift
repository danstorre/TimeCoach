import SwiftUI

public struct TimerView: View {
    private let playHandler: (() -> Void)?
    
    public init(playHandler: (() -> Void)? = nil) {
        self.playHandler = playHandler
    }
    
    public var body: some View {
        VStack {
            Text("25:00")
                .accessibilityIdentifier("b")
            
            Button.init(action: playHandler ?? {}) {
            }.accessibilityIdentifier(Self.playButtonIdentifier)
        }
    }
}

extension TimerView {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
    
    public static let playButtonIdentifier = "playButtonIdentifier"
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
