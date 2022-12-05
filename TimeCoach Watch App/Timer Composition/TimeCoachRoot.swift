import Foundation
import LifeCoach
import LifeCoachWatchOS
import Combine

class TimeCoachRoot {
    lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    convenience init(timerCoundown: TimerCountdown) {
        self.init()
        self.timerCoundown = timerCoundown
    }
    
    func createTimer() -> TimerView {
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: timerCoundown.createStartTimer(),
            skipPublisher: timerCoundown.createSkipTimer(),
            stopPublisher: timerCoundown.createStopTimer(),
            pausePublisher: timerCoundown.createPauseTimer()
        )
    }
}

public enum CustomFont {
    case timer
    
    public var font: String {
        "Digital dream Fat"
    }
}
