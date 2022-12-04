import SwiftUI
import Combine

public struct TimerView: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    @ObservedObject var timerViewModel: TimerViewModel
    public let customFont: String?
    
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    private var onAppear: (() -> Void)?
    
    public init(timerViewModel: TimerViewModel,
         togglePlayback: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil,
         onAppear: (() -> Void)? = nil,
         customFont: String? = nil
    ) {
        self.timerViewModel = timerViewModel
        self.togglePlayback = togglePlayback
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
        self.customFont = customFont
        self.onAppear = onAppear
    }
    
    public var body: some View {
        VStack {
            Label(title: { Text(timerViewModel.timerString) }, icon: {})
                .labelStyle(TimerLabelStyle(isLuminanceReduced: isLuminanceReduced,
                                            customFont: customFont))
                .accessibilityIdentifier(Self.timerLabelIdentifier)
            
            HStack {
                Button.init(action: stopHandler ?? {}) {
                    Image(systemName: "stop.fill")
                }.accessibilityIdentifier(Self.stopButtonIdentifier)
                
                Button.init(action: skipHandler ?? {}) {
                    Image(systemName: "forward.end.fill")
                }.accessibilityIdentifier(Self.skipButtonIdentifier)
                
                Button.init(action: togglePlayback ?? {}) {
                    Image(systemName: "playpause.fill")
                }.accessibilityIdentifier(Self.togglePlaybackButtonIdentifier)
            }
            .opacity(isLuminanceReduced ? 0.0 : 1.0)
        }
        .onAppear(perform: onAppear)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerViewModel: TimerViewModel(), onAppear: {})
    }
}
