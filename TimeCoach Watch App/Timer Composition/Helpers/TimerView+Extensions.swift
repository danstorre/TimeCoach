import LifeCoach
import SwiftUI

public struct TimerView: View {
    public var timer: TimerText
    public var controls: TimerControls
    
    public init(timerViewModel: TimerViewModel,
         togglePlayback: (() -> Void)? = nil,
         skipHandler: (() -> Void)? = nil,
         stopHandler: (() -> Void)? = nil,
         customFont: String? = nil
    ) {
        self.timer = TimerText(timerViewModel: timerViewModel, customFont: customFont)
        self.controls = TimerControls(togglePlayback: togglePlayback, skipHandler: skipHandler, stopHandler: stopHandler)
    }
    
    public var body: some View {
        VStack {
            timer
            controls
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerViewModel: TimerViewModel())
    }
}

extension TimerView {
    public static let timerLabelIdentifier = "timerLabelIdentifier"
    
    public static let togglePlaybackButtonIdentifier = "togglePlaybackButtonIdentifier"
    
    public static let skipButtonIdentifier = "skipButtonIdentifier"
    
    public static let stopButtonIdentifier = "stopButtonIdentifier"
}
