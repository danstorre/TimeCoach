import SwiftUI
import LifeCoachWatchOS
import LifeCoach

struct PreviewTimer_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerView {
        let timerWithTimeLine = TimerTextTimeLine(timerViewModel: TimerViewModel(),
                                                  breakColor: .blueTimer,
                                                  customFont: CustomFont.timer.font)
    
        return TimerView(timerWithTimeLine: timerWithTimeLine, controls: Self.defaultTimerControls())
    }
    
    static func breakTimer() -> TimerView {
        let timerVm = TimerViewModel()
        timerVm.isBreak = true
        
        let timerWithTimeLine = TimerTextTimeLine(timerViewModel: timerVm,
                                                  breakColor: .blueTimer,
                                                  customFont: CustomFont.timer.font)
        
        return TimerView(timerWithTimeLine: timerWithTimeLine, controls: Self.defaultTimerControls())
    }
    
    static var previews: some View {
        Group {
            pomodoroTimer()
            breakTimer()
        }
    }
}
