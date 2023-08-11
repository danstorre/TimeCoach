import Foundation
import Combine
import LifeCoach

extension Publisher where Output == TimerState {
    func saveTimerState(saver timerStateSaver: SaveTimerState) -> AnyPublisher<TimerState, Failure> {
        self.handleEvents(receiveOutput: { timerState in
            try? timerStateSaver.save(state: timerState)
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerSet {
    func mapsTimerSetAndState(timerCountdown: TimerCoutdown) -> AnyPublisher<(TimerSet, TimerState.State), Failure> {
        self.map({ _ in (timerSet: timerCountdown.currentTimerSet.toElapseSeconds, state: timerCountdown.state.toModel) })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func mapsTimerSetAndState(timerCountdown: TimerCoutdown) -> AnyPublisher<(TimerSet, TimerState.State), Failure> {
        self.map({ _ in (timerSet: timerCountdown.currentTimerSet.toElapseSeconds, state: timerCountdown.state.toModel) })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == (TimerSet, TimerState.State) {
    func saveTimerState(saver timerStateSaver: SaveTimerState) -> AnyPublisher<(TimerSet, TimerState.State), Failure> {
        self.handleEvents(receiveOutput: { timerState in
            try? timerStateSaver.save(state: TimerState(timerSet: timerState.0, state: timerState.1))
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func unregisterTimerNotifications(_ completion: @escaping () -> Void) -> AnyPublisher<Void, Failure> {
        self.handleEvents(receiveOutput: { _ in
            completion()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == (TimerSet, TimerState.State) {
    func flatsToVoid() -> AnyPublisher<Void, Failure> {
        self.flatMap({ _ in Just(()) })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func notifySavedTimer(notifier timerSavedNofitier: TimerStoreNotifier) -> AnyPublisher<Void, Failure> {
        self.handleEvents(receiveOutput: { _ in
            timerSavedNofitier.storeSaved()
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func flatsToTimerSetPublisher(_ currentSetPublisher: CurrentValueSubject<TimerState, Error>) -> AnyPublisher<TimerState, Failure> {
        self.flatMap({ _ in
            Just(currentSetPublisher.value)
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerState {
    func scheduleTimerNotfication(scheduler: TimerNotificationScheduler) -> AnyPublisher<TimerState, Failure> {
        handleEvents(receiveOutput: { timerState in
            try? scheduler.scheduleNotification(from: timerState.timerSet)
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == TimerState {
    func notifySavedTimer(notifier timerSavedNofitier: TimerStoreNotifier) -> AnyPublisher<TimerState, Failure> {
        handleEvents(receiveOutput: { _ in
            timerSavedNofitier.storeSaved()
        })
        .eraseToAnyPublisher()
    }
}

extension TimerCoutdownState {
    var toModel: TimerState.State {
        switch self {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}
