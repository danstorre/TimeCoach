import SwiftUI

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
