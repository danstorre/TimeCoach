import Foundation
import LifeCoach
import TimeCoachVisionOS
import Combine
import UserNotifications

class TimeCoachRoot {
    private lazy var timerCoundown: TimerCountdown = PomodoroLocalTimer(startDate: .now,
                                                                        primaryInterval: .pomodoroInSeconds,
                                                                        secondaryTime: .breakInSeconds)
    
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
