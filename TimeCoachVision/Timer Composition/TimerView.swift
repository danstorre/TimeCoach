import LifeCoach
import TimeCoachVisionOS
import SwiftUI

public struct TimerView: View {
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
        self.timerWithoutTimeLine = TimerText(timerViewModel: timerViewModel, mode: .full, customFont: customFont)
        self.withTimeLine = withTimeLine
        self.controls = TimerControls(togglePlayback: togglePlayback, skipHandler: skipHandler, stopHandler: stopHandler)
    }
    
    public var body: some View {
        VStack {
            timerWithoutTimeLine
            controls
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(timerViewModel: TimerViewModel())
    }
}
