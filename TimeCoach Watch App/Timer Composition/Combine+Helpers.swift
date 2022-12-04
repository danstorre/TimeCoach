import Foundation
import Combine
import LifeCoach
import LifeCoachWatchOS

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

extension TimerCountdown {
    func createPauseTimer() -> AnyPublisher<ElapsedSeconds, Error> {
        return Deferred {
            let currentValue = CurrentValueSubject<ElapsedSeconds, Error>(
                ElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            pauseCountdown { time in
                currentValue.send(time.timeElapsed)
            }

            return currentValue
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}
