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

extension Publisher where Output == TimerSet {
    func settingStartEndDate(setableTimer: SetableTimer) -> AnyPublisher<TimerSet, Failure> {
        self.handleEvents(receiveOutput: { timerSet in
            try? setableTimer.set(startDate: timerSet.startDate,
                                  endDate: timerSet.endDate)
        })
        .eraseToAnyPublisher()
    }
    
    func settingElapsedSeconds(setableTimer: SetableTimer) -> AnyPublisher<TimerSet, Failure> {
        self.handleEvents(receiveOutput: { timerSet in
            setableTimer.setElapsedSeconds(timerSet.elapsedSeconds)
        })
        .eraseToAnyPublisher()
    }
}
