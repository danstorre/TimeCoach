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
    func mapsTimerSetAndState(timerCountdown: TimerCountdown) -> AnyPublisher<(TimerSet, TimerState.State), Failure> {
        self.map({ _ in (timerSet: timerCountdown.currentState.currentTimerSet.toModel, state: timerCountdown.currentState.state.toModel) })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Void {
    func mapsTimerSetAndState(timerCountdown: TimerCountdown, currentIsBreakMode: IsBreakMode) -> AnyPublisher<TimerState, Failure> {
        self.map({ _ in (timerSet: timerCountdown.currentState.currentTimerSet.toModel, state: timerCountdown.currentState.state.toModel) })
            .map({ TimerState(timerSet: $0.0, state: $0.1, isBreak: currentIsBreakMode)})
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

extension Publisher {
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
    func scheduleTimerNotfication(scheduler: TimerNotificationScheduler, isBreak: Bool) -> AnyPublisher<TimerState, Failure> {
        handleEvents(receiveOutput: { timerState in
            try? scheduler.scheduleNotification(from: timerState.timerSet, isBreak: isBreak)
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

extension TimerCountdownStateValues {
    var toModel: TimerState.State {
        switch self {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}

extension Publisher {
    func processFirstValue(_ process: @escaping (Output) -> Void) -> AnyPublisher<Output, Failure> {
        var isFirstValue = true
        
        return self
            .map { value in
                if isFirstValue {
                    process(value)
                    isFirstValue = false
                }
                return value
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Publisher Main DispatchQueue
extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Combine.Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

extension AnyDispatchQueueScheduler {
    static var immediateOnMainQueue: Self {
        DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
    }
}

extension Combine.Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}

struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Combine.Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    private let _now: () -> SchedulerTimeType
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable

    init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType, SchedulerOptions == S.SchedulerOptions, S: Combine.Scheduler {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = scheduler.schedule(options:_:)
        _scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
        _scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
    }
    
    var now: SchedulerTimeType { _now() }
    
    var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }
    
    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _schedule(options, action)
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfter(date, tolerance, options, action)
    }

    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterInterval(date, interval, tolerance, options, action)
    }
}
