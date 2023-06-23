import Foundation
import LifeCoach
import TimeCoachVisionOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private var timerCoundown: TimerCountdown
    private var timerSave: TimerSave
    private var timerLoad: TimerLoad
    
    init() {
        let pomodoro = PomodoroLocalTimer(startDate: .now,
                                          primaryInterval: .pomodoroInSeconds,
                                          secondaryTime: .breakInSeconds)
        self.timerSave = pomodoro
        self.timerCoundown = pomodoro
        self.timerLoad = pomodoro
    }
    
    convenience init(timerCoundown: TimerCountdown, timerState: TimerSave & TimerLoad) {
        self.init()
        self.timerCoundown = timerCoundown
        self.timerSave = timerState
        self.timerLoad = timerState
    }
    
    func createTimer(withTimeLine: Bool = true) -> TimerView {
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: timerCoundown.createStartTimer(),
            skipPublisher: timerCoundown.createSkipTimer(),
            stopPublisher: timerCoundown.createStopTimer(),
            pausePublisher: timerCoundown.createPauseTimer(),
            withTimeLine: withTimeLine
        )
    }
}
