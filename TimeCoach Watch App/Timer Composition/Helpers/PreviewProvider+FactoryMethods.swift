import LifeCoach
import LifeCoachWatchOS
import SwiftUI

extension PreviewProvider {
    static func defaultTimerControls() -> TimerControls {
        TimerControls(viewModel: ControlsViewModel())
    }
    
    static func timerTextTimeLine(with viewModel: TimerViewModel = TimerViewModel(isBreak: false)) -> TimerTextTimeLine {
        return TimerTextTimeLine(timerViewModel: viewModel,
                                 breakColor: .blueTimer,
                                 customFont: CustomFont.timer.font)
    }
    
    static func timerText(with viewModel: TimerViewModel = TimerViewModel(isBreak: false)) -> TimerText {
        return TimerText(timerViewModel: viewModel,
                         mode: .full,
                         breakColor: .blueTimer)
    }
}
