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
