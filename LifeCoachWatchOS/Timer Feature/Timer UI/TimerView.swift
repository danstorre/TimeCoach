import SwiftUI
import Combine

public struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    
    init(timerViewModel: TimerViewModel,
         togglePlayback: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil
    ) {
        self.timerViewModel = timerViewModel
        self.togglePlayback = togglePlayback
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
    }
    
    public var body: some View {
        VStack {
            Text(timerViewModel.timerString)
                .accessibilityIdentifier(Self.timerLabelIdentifier)
            
            Button.init(action: togglePlayback ?? {}) {
            }.accessibilityIdentifier(Self.togglePlaybackButtonIdentifier)
            
            Button.init(action: skipHandler ?? {}) {
            }.accessibilityIdentifier(Self.skipButtonIdentifier)
            
            Button.init(action: stopHandler ?? {}) {
            }.accessibilityIdentifier(Self.stopButtonIdentifier)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerViewModel: TimerViewModel())
    }
}
