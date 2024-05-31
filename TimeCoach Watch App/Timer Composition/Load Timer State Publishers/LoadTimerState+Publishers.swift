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
    func setTimerValues(using currenDate: @escaping () -> Date, _ timeAtSave: Date, _ setabletimer: SetableTimer?) -> AnyPublisher<TimerSet, Failure> {
        handleEvents(receiveOutput: { timerSet in
                let elapsedTime: TimeInterval = currenDate().timeIntervalSince(timeAtSave)
                let elapsedSecondsLoaded = timerSet.elapsedSeconds
                try? setabletimer?.set(startDate: timerSet.startDate,
                                       endDate: timerSet.endDate)
                setabletimer?.setElapsedSeconds(elapsedSecondsLoaded + elapsedTime)
        }).eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerState, Failure == Never {
    func filterPauseOrStopTimerState() -> AnyPublisher<TimerState, Never> {
        self.filter({ timerState in timerState.state != .stop && timerState.state != .pause })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerState, Failure == Never {
    func getTimerStatePublisher(using localTimer: LoadTimerState) -> AnyPublisher<TimerSet, Error> {
        self.flatMap { _ in
            localTimer.getTimerSetPublisher()
        }
        .eraseToAnyPublisher()
    }
}
