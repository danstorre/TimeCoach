import SwiftUI
import LifeCoachWatchOS
import LifeCoach

struct PreviewTimer_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerView {
        return TimerView(timerWithTimeLine: Self.timerTextTimeLine(),
                         controls: Self.defaultTimerControls())
    }
    
    static func breakTimer() -> TimerView {
        let timerVm = TimerViewModel()
        timerVm.isBreak = true
        return TimerView(timerWithTimeLine: Self.timerTextTimeLine(with: timerVm),
                         controls: Self.defaultTimerControls())
    }
    
    static var previews: some View {
        Group {
            pomodoroTimer()
            breakTimer()
        }
    }
}
