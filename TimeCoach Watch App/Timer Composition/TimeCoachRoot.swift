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
    
    convenience init(timerCoundown: TimerCountdown?) {
        self.init()
        if let timerCoundown = timerCoundown {
            self.timerCoundown = timerCoundown
        }
    }
    
    func createTimer() -> TimerView {
        return TimerViewComposer.createTimer(
            customFont: CustomFont.timer.font,
            playPublisher: timerCoundown.createStartTimer(),
            skipPublisher: timerCoundown.createSkipTimer(),
            stopPublisher: timerCoundown.createStopTimer()
        )
    }
}

extension TimerCountdown {
    func createStartTimer() -> AnyPublisher<ElapsedSeconds, Error> {
        return Deferred {
            let currentValue = CurrentValueSubject<ElapsedSeconds, Error>(
                ElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            startCountdown { time in
                currentValue.send(time.timeElapsed)
            }

            return currentValue
        }
        .dropFirst()
       .eraseToAnyPublisher()
    }
}

extension TimerCountdown {
    func createStopTimer() -> AnyPublisher<ElapsedSeconds, Error> {
        return Deferred {
            let currentValue = CurrentValueSubject<ElapsedSeconds, Error>(
                ElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            stopCountdown { time in
                currentValue.send(time.timeElapsed)
            }

            return currentValue
        }
        .eraseToAnyPublisher()
    }
}

extension TimerCountdown {
    func createSkipTimer() -> AnyPublisher<ElapsedSeconds, Error> {
        return Deferred {
            let currentValue = CurrentValueSubject<ElapsedSeconds, Error>(
                ElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            skipCountdown { time in
                currentValue.send(time.timeElapsed)
            }

            return currentValue
        }
        .eraseToAnyPublisher()
    }
}
