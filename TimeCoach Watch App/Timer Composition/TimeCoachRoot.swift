import Foundation
import LifeCoach
import Combine

class TimeCoachRoot {
    lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    lazy var skipPublisher: CurrentValueSubject<ElapsedSeconds, Error> = {
        CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: .now, endDate: .now))
    }()
    lazy var startPublisher: AnyPublisher<ElapsedSeconds, Error> = {
        Self.makeStartTimerPublisher(timerCoundown: timerCoundown)
    }()
    lazy var stopPublisher: CurrentValueSubject<ElapsedSeconds, Error> = {
        CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: .now, endDate: .now))
    }()
    var skipHandler: (() -> Void)?
    var stopHandler: (() -> Void)?
    
    init() {
        self.skipPublisher = skipPublisher
        self.skipHandler = AdapterTimerCountDown(timerCoundown: timerCoundown, skipPublisher: skipPublisher).skipHandler
        self.stopHandler = AdapterStopTimerCountDown(timerCoundown: timerCoundown, stopPublisher: stopPublisher).stopHandler
    }
    
    convenience init(timerCoundown: TimerCountdown) {
        self.init()
        self.skipHandler = AdapterTimerCountDown(timerCoundown: timerCoundown, skipPublisher: skipPublisher).skipHandler
        self.stopHandler = AdapterStopTimerCountDown(timerCoundown: timerCoundown, stopPublisher: stopPublisher).stopHandler
        self.timerCoundown = timerCoundown
        self.startPublisher = Self.makeStartTimerPublisher(timerCoundown: timerCoundown)
    }
    
    static func makeStartTimerPublisher(timerCoundown: TimerCountdown) -> AnyPublisher<ElapsedSeconds, Error> {
        return timerCoundown
            .getStartTimerPublisher()
            .map({ $0.timeElapsed })
            .eraseToAnyPublisher()
    }
}
