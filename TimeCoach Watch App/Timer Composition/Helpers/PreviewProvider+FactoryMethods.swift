import LifeCoach
import LifeCoachWatchOS
import SwiftUI

extension PreviewProvider {
    static func defaultTimerControls() -> TimerControls {
        TimerControls(viewModel: ControlsViewModel())
    }
    
    static func timerTextTimeLine(with viewModel: TimerViewModel = TimerViewModel()) -> TimerTextTimeLine {
        return TimerTextTimeLine(timerViewModel: viewModel,
                                 breakColor: .blueTimer,
                                 customFont: CustomFont.timer.font)
    }
}
