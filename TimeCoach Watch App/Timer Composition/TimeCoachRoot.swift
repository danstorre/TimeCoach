import Foundation
import LifeCoach
import Combine

class TimeCoachRoot {
    lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    lazy var timerPublisher: CurrentValueSubject<ElapsedSeconds, Error> = {
        CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: .now, endDate: .now))
    }()
    var skipHandler: (() -> Void)?
    var stopHandler: (() -> Void)?
    var togglePlayback: (() -> Void)?
    
    convenience init(timerCoundown: TimerCountdown?) {
        self.init()
        if let timerCoundown = timerCoundown {
            self.timerCoundown = timerCoundown
        }
        let adapter = AdapterTimerCountDownPublisher(timerCoundown: self.timerCoundown,
                                                     publisher: timerPublisher)
        self.skipHandler = adapter.skipHandler
        self.stopHandler = adapter.stopHandler
        self.togglePlayback = adapter.togglePlayback
    }
}
