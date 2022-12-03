import Foundation
import Combine
import LifeCoach

public extension TimerCountdown {
    typealias Publisher = AnyPublisher<LocalElapsedSeconds, Error>

    func getStartTimerPublisher() -> Publisher {
        return Deferred {
            let currentValue = CurrentValueSubject<LocalElapsedSeconds, Error>(
                LocalElapsedSeconds(0, startDate: .now, endDate: .now)
            )
            startCountdown(completion: { localElapsedSeconds in
                currentValue.send(localElapsedSeconds)
            })
            
            return currentValue
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}
