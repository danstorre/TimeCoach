import SwiftUI
import Combine
import LifeCoach

public struct TimerText: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @ObservedObject var timerViewModel: TimerViewModel
    public var customFont: String?
    
    public init(timerViewModel: TimerViewModel, customFont: String? = nil) {
        self.timerViewModel = timerViewModel
        self.customFont = customFont
    }
    
    public var body: some View {
        Label(title: { Text(timerViewModel.timerString) }, icon: {})
            .labelStyle(TimerLabelStyle(isLuminanceReduced: isLuminanceReduced,
                                        customFont: customFont))
            .accessibilityIdentifier(Self.timerLabelIdentifier)
    }
}

extension TimerText {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
}

public struct TimerControls: View {
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    
    private var togglePlayback: (() -> Void)?
    private var skipHandler: (() -> Void)?
    private var stopHandler: (() -> Void)?
    
    public init(
         togglePlayback: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil,
         customFont: String? = nil
    ) {
        self.togglePlayback = togglePlayback
        self.skipHandler = skipHandler
        self.stopHandler = stopHandler
    }
    
    public var body: some View {
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
}

extension TimerControls {
    public static let togglePlaybackButtonIdentifier = "togglePlaybackButtonIdentifier"
    
    public static let skipButtonIdentifier = "skipButtonIdentifier"
    
    public static let stopButtonIdentifier = "stopButtonIdentifier"
}
