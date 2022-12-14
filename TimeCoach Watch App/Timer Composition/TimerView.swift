import LifeCoach
import LifeCoachWatchOS
import SwiftUI

public struct TimerView: View {
    public var timerWithTimeLine: TimerTextTimeLine?
    public var timerWithoutTimeLine: TimerText?
    public var controls: TimerControls
    var withTimeLine = true
    
    public init(
        timerViewModel: TimerViewModel,
        togglePlayback: (() -> Void)? = nil,
        skipHandler: (() -> Void)? = nil,
        stopHandler: (() -> Void)? = nil,
        customFont: String? = nil,
        withTimeLine: Bool = false
    ) {
        if withTimeLine {
            self.timerWithTimeLine = TimerTextTimeLine(timerViewModel: timerViewModel, customFont: customFont)
        } else {
            self.timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel, mode: .full, customFont: customFont)
        }
        
        self.withTimeLine = withTimeLine
        self.controls = TimerControls(togglePlayback: togglePlayback, skipHandler: skipHandler, stopHandler: stopHandler)
    }
    
    public var body: some View {
        VStack {
            if withTimeLine {
                timerWithTimeLine
            } else {
                timerWithoutTimeLine
            }
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
