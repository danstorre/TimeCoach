import LifeCoach
import LifeCoachWatchOS
import SwiftUI

public struct TimerView: View {
    public var timerWithTimeLine: TimerTextTimeLine?
    public var timerWithoutTimeLine: TimerText?
    public var controls: TimerControls
    var withTimeLine = true
    
    public init(
        controlsViewModel: ControlsViewModel,
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
        self.controls = TimerControls(viewModel: controlsViewModel,
                                      togglePlayback: togglePlayback,
                                      skipHandler: skipHandler,
                                      stopHandler: stopHandler)
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
        TimerView(controlsViewModel: ControlsViewModel(),
                  timerViewModel: TimerViewModel())
    }
}

extension TimerView {
    public static let togglePlaybackButtonIdentifier: Int = 2
    
    public static let skipButtonIdentifier: Int = 1
    
    public static let stopButtonIdentifier: Int = 0
}
