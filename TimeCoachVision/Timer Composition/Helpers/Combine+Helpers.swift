import Foundation
import Combine
import LifeCoach
import TimeCoachVisionOS

extension TimerCountdown {
    func createStartTimer() -> AnyPublisher<ElapsedSeconds, Error> {
        return Deferred {
            let currentValue = CurrentValueSubject<ElapsedSeconds, Error>(
                createElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            startCountdown { time in
                currentValue.send(time)
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
                createElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            stopCountdown { time in
                currentValue.send(time)
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
                createElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            skipCountdown { time in
                currentValue.send(time)
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
                createElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            
            pauseCountdown { time in
                currentValue.send(time)
            }

            return currentValue
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}


fileprivate func createElapsedSeconds(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> ElapsedSeconds {
    ElapsedSeconds(elapsedSeconds, startDate: startDate, endDate: endDate)
}
