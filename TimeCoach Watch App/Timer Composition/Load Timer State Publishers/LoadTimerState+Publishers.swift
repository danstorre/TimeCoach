import Foundation
import LifeCoach
import Combine

extension LoadTimerState {
    func getTimerSetPublisher() -> AnyPublisher<TimerSet, Error> {
        return Deferred {
            Just(())
                .tryMap { try load() }
                .compactMap { $0?.timerSet }
        }
        .eraseToAnyPublisher()
    }
}

