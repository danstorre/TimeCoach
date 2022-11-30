import SwiftUI

public struct TimerView: View {
    private let playHandler: (() -> Void)?
    private let skipHandler: (() -> Void)?
    private let stopHandler: (() -> Void)?
    
    public init(playHandler: (() -> Void)? = nil,
                skipHandler: (() -> Void)? = nil,
                stopHandler: (() -> Void)? = nil) {
        self.playHandler = playHandler
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
    }
    
    public var body: some View {
        VStack {
            Text("25:00")
                .accessibilityIdentifier(Self.timerLabelIdentifier)
            
            Button.init(action: playHandler ?? {}) {
            }.accessibilityIdentifier(Self.playButtonIdentifier)
            
            Button.init(action: skipHandler ?? {}) {
            }.accessibilityIdentifier(Self.skipButtonIdentifier)
            
            Button.init(action: stopHandler ?? {}) {
            }.accessibilityIdentifier(Self.stopButtonIdentifier)
        }
    }
}

extension TimerView {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
    
    public static let playButtonIdentifier = "playButtonIdentifier"
    
    public static let skipButtonIdentifier = "skipButtonIdentifier"
    
    public static let stopButtonIdentifier = "stopButtonIdentifier"
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
