import Foundation
import LifeCoach
import Combine

class TimeCoachRoot {
    lazy var timerCoundown: TimerCountdown = {
        return PomodoroLocalTimer(startDate: .now,
                                  primaryInterval: .pomodoroInSeconds,
                                  secondaryTime: .breakInSeconds)
    }()
    
    lazy var startPublisher: AnyPublisher<ElapsedSeconds, Error> = {
        Self.makeStartTimerPublisher(timerCoundown: timerCoundown)
    }()
    lazy var timerPublisher: CurrentValueSubject<ElapsedSeconds, Error> = {
        CurrentValueSubject<ElapsedSeconds, Error>(ElapsedSeconds(0, startDate: .now, endDate: .now))
    }()
    var skipHandler: (() -> Void)?
    var stopHandler: (() -> Void)?
    
    init() {
        let adapter = AdapterTimerCountDownPublisher(timerCoundown: timerCoundown, publisher: timerPublisher)
        self.skipHandler = adapter.skipHandler
        self.stopHandler = adapter.stopHandler
    }
    
    convenience init(timerCoundown: TimerCountdown) {
        self.init()
        let adapter = AdapterTimerCountDownPublisher(timerCoundown: timerCoundown, publisher: timerPublisher)
        self.skipHandler = adapter.skipHandler
        self.stopHandler = adapter.stopHandler
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
