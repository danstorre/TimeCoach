import SwiftUI
import LifeCoachWatchOS
import LifeCoach

struct PreviewTimer_Previews: PreviewProvider {
    static func pomodoroTimer() -> TimerView {
        TimerView(
            controlsViewModel: ControlsViewModel(),
            timerViewModel: TimerViewModel(),
            customFont: CustomFont.timer.font,
            breakColor: .blueTimer
        )
    }
    
    static func breakTimer() -> TimerView {
        let timerVm = TimerViewModel()
        timerVm.isBreak = true
        
        return TimerView(
            controlsViewModel: ControlsViewModel(),
            timerViewModel: timerVm,
            customFont: CustomFont.timer.font,
            breakColor: .blueTimer
        )
    }
    
    static var previews: some View {
        Group {
            pomodoroTimer()
            breakTimer()
        }
    }
}
