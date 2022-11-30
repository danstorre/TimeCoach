import SwiftUI

public struct TimerView: View {
    private let playHandler: (() -> Void)?
    private let skipHandler: (() -> Void)?
    
    public init(playHandler: (() -> Void)? = nil,
                skipHandler: (() -> Void)? = nil) {
        self.playHandler = playHandler
        self.skipHandler = skipHandler
    }
    
    public var body: some View {
        VStack {
            Text("25:00")
                .accessibilityIdentifier("b")
            
            Button.init(action: playHandler ?? {}) {
            }.accessibilityIdentifier(Self.playButtonIdentifier)
            
            Button.init(action: skipHandler ?? {}) {
            }.accessibilityIdentifier(Self.skipButtonIdentifier)
        }
    }
}

extension TimerView {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
    
    public static let playButtonIdentifier = "playButtonIdentifier"
    
    public static let skipButtonIdentifier = "skipButtonIdentifier"
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
