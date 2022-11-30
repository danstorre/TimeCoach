import SwiftUI
import Combine

public struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    
    var playHandler: (() -> Void)?
    var skipHandler: (() -> Void)?
    var stopHandler: (() -> Void)?
    
    init(timerViewModel: TimerViewModel,
         playHandler: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil
    ) {
        self.timerViewModel = timerViewModel
        self.playHandler = playHandler
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
    }
    
    public var body: some View {
        VStack {
            Text(timerViewModel.timerString)
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
        TimerView(timerViewModel: TimerViewModel())
    }
}
