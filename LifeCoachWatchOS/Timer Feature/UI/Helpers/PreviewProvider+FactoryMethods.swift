import LifeCoach
import SwiftUI

extension PreviewProvider {
    public static func defaultTimerControls() -> TimerControls {
        TimerControls(viewModel: ControlsViewModel())
    }
    
    public static func timerTextTimeLine(with viewModel: TimerViewModel = TimerViewModel(isBreak: false)) -> TimerTextTimeLineWithLuminance {
        return TimerTextTimeLineWithLuminance(timerViewModel: viewModel,
                                              breakColor: .blueTimer,
                                              customFont: CustomFont.timer.font)
    }
    
    public static func timerText(with viewModel: TimerViewModel = TimerViewModel(isBreak: false)) -> TimerText {
        return TimerText(timerViewModel: viewModel,
                         mode: .full,
                         breakColor: .blueTimer,
                         customFont: CustomFont.timer.font)
    }
}
