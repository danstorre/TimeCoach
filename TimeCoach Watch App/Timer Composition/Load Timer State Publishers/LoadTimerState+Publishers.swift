import Foundation
import LifeCoach
import Combine

extension LoadTimerState {
    func getTimerSetPublisher(timerState: TimerState) -> AnyPublisher<TimerSet, Error> {
        return Deferred {
            Just(())
                .filter({ timerState.state != .stop && timerState.state != .pause })
                .tryMap { try load() }
                .compactMap { $0?.timerSet }
        }
        .eraseToAnyPublisher()
    }
}

