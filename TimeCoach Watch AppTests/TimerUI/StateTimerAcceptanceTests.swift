import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class StateTimerAcceptanceTests: XCTestCase {
    typealias TimerStore = TimerLoad & TimerSave
    
    func test_onLaunch_onToggleUserInteractionShouldStartNotificationAndSaveStateProcess() {
        let (sut, spy) = makeSUT()
        let expected = createAnyTimerState(using: spy.currentTimerSet, on: .running)
        
        sut.simulateToggleTimerUserInteraction()
        
        spy.deliversSetAfterStart((timerSet: expected.localTimerSet, state: expected.state.toInfra))
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .saveStateTimer(value: expected),
            .scheduleTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_afterTimerDeliversShouldNotStartNotificationAndSaveStateProcess() {
        let (sut, spy) = makeSUT()
        let expected = createAnyTimerState(using: spy.currentTimerSet, on: .running)
        
        sut.simulateToggleTimerUserInteraction()
        
        spy.deliversSetAfterStart((timerSet: expected.localTimerSet, state: expected.state.toInfra))
        
        spy.deliversSetAfterStart((timerSet: expected.localTimerSet.adding(1), state: expected.state.toInfra))
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .saveStateTimer(value: expected),
            .scheduleTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onStopUserInteractionShouldExecuteStopProcess() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let expected = createAnyTimerState(
            using: createAnyTimerSet(startingFrom: currentDate, endDate: currentDate.adding(seconds: .pomodoroInSeconds)),
            on: .stop
        )
        
        sut.timerView.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .saveStateTimer(value: expected),
            .unregisterTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onRunningState_onStopUserInteractionShouldExecuteStopProcess() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let anySet = createAnyTimerSet(startingFrom: currentDate, endDate: currentDate.adding(seconds: .pomodoroInSeconds))
        let expected = createAnyTimerState(
            using: anySet,
            on: .stop
        )
        sut.timerView.simulateToggleTimerUserInteraction()
        spy.deliversSetAfterStart((timerSet: anySet.adding(1), state: expected.state.toInfra))
        spy.resetMessages()
        
        sut.timerView.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .saveStateTimer(value: expected),
            .unregisterTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onRunningState_onPauseUserInteractionShouldExecutePauseProcess() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let anySet = createAnyTimerSet(startingFrom: currentDate, endDate: currentDate.adding(seconds: .pomodoroInSeconds))
        let runningSet = createAnyTimerState(using: anySet.adding(1), on: .running)
        let expected = createAnyTimerState(using: runningSet.localTimerSet, on: .pause)
        
        sut.timerView.simulateToggleTimerUserInteraction()
        spy.deliversSetAfterStart((timerSet: runningSet.localTimerSet, state: runningSet.state.toInfra))
        spy.resetMessages()
        
        sut.timerView.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .saveStateTimer(value: expected),
            .unregisterTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onSkipUserInteractionShouldExecuteSkipProcess() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let anySet = createAnyTimerSet(startingFrom: currentDate, endDate: currentDate.adding(seconds: .pomodoroInSeconds))
        let expected = createAnyTimerState(using: anySet, on: .stop)
        
        sut.timerView.simulateSkipTimerUserInteraction()
        spy.deliversSetAfterSkip((timerSet: anySet, state: expected.state.toInfra))
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .saveStateTimer(value: expected),
            .unregisterTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onSkipUserInteractionShouldStartNotificationAndSaveStateProcessOnce() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let anySet = createAnyTimerSet(startingFrom: currentDate, endDate: currentDate.adding(seconds: .pomodoroInSeconds))
        let expected = createAnyTimerState(using: anySet, on: .stop)
        
        sut.timerView.simulateSkipTimerUserInteraction()
        spy.deliversSetAfterSkip((timerSet: anySet, state: expected.state.toInfra))
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .saveStateTimer(value: expected),
            .unregisterTimerNotification,
            .notifySavedTimer
        ])
    }
    
    func test_onBackgroundEvent_shouldNotSendMessageToStartSaveStateProcess() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        sut.goToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: TimeCoach_Watch_AppApp, spy: Spy) {
        let spy = Spy(currenDate: currentDate())
        let infra = Infrastructure(
            timerCountdown: spy,
            timerState: spy,
            stateTimerStore: spy,
            scheduler: spy,
            notifySavedTimer: spy.notifySavedTimer,
            currentDate: currentDate,
            unregisterTimerNotification: spy.unregisterTimerNotification
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        return (sut, spy)
    }
    
    private func createAnyTimerState(using anySet: LocalTimerSet, on state: LocalTimerState.State) -> LocalTimerState {
        LocalTimerState(localTimerSet: anySet, state: state)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date(), endDate: Date? = nil) -> LocalTimerSet {
        createTimerSet(0, startDate: startDate, endDate: endDate ?? startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
    
    private class Spy: TimerCoutdown, TimerStore, LocalTimerStore, Scheduler {
        enum AnyMessage: Equatable, CustomStringConvertible {
            case startTimer
            case stopTimer
            case pauseTimer
            case skipTimer
            case saveStateTimer(value: LifeCoach.LocalTimerState)
            case scheduleTimerNotification
            case unregisterTimerNotification
            case notifySavedTimer
            
            var description: String {
                switch self {
                case .startTimer:
                    return "startTimer"
                case let .saveStateTimer(value: localTimerState):
                    return """
                saveStateTimer: seconds: \(localTimerState.localTimerSet.elapsedSeconds), state: \(localTimerState.state)
                startDate: \(localTimerState.localTimerSet.startDate), endDate: \(localTimerState.localTimerSet.endDate)
                """
                case .scheduleTimerNotification:
                    return "scheduleTimerNotification"
                case .notifySavedTimer:
                    return "notifySavedTimer"
                case .stopTimer:
                    return "stopTimer"
                case .unregisterTimerNotification:
                    return "unregisterTimerNotification"
                case .pauseTimer:
                    return "pauseTimer"
                case .skipTimer:
                    return "skipTimer"
                }
            }
        }
        private let currenDate: Date
        
        private var currentSet: LifeCoach.LocalTimerSet
        var currentTimerSet: LifeCoach.LocalTimerSet { currentSet }
        
        var currentSetElapsedTime: TimeInterval = 0.0
        var state: LifeCoach.TimerCoutdownState = .stop
        
        private(set) var receivedMessages = [AnyMessage]()
        private var receivedStartCompletions = [StartCoundownCompletion]()
        private var receivedSkipCompletions = [SkipCountdownCompletion]()
        
        init(currenDate: Date) {
            self.currenDate = currenDate
            self.currentSet = .pomodoroSet(date: currenDate)
        }
        
        func resetMessages() {
            receivedMessages = []
        }
        
        // MARK: - Timer
        func startCountdown(completion: @escaping StartCoundownCompletion) {
            receivedMessages.append(.startTimer)
            receivedStartCompletions.append(completion)
        }
        
        func stopCountdown() {
            state = .stop
            receivedMessages.append(.stopTimer)
            let startSet = LocalTimerSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
            receivedStartCompletions.last?(.success((startSet, state)))
        }
        
        func pauseCountdown() {
            state = .pause
            receivedMessages.append(.pauseTimer)
            receivedStartCompletions.last?(.success((currentSet, state)))
        }
        
        func skipCountdown(completion: @escaping SkipCountdownCompletion) {
            receivedMessages.append(.skipTimer)
            receivedSkipCompletions.append(completion)
        }
        
        func deliversSetAfterSkip(_ timerState: (timerSet: LocalTimerSet, state: TimerCoutdownState), index: Int = 0) {
            receivedSkipCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func deliversSetAfterStart(_ timerState: (timerSet: LocalTimerSet, state: TimerCoutdownState), index: Int = 0) {
            setsCurrentTimer(timerState.timerSet, state: timerState.state)
            receivedStartCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func setsCurrentTimer(_ timerSet: LocalTimerSet, state: TimerCoutdownState) {
            self.state = state
            self.currentSet = timerSet
        }
        
        // MARK: - Timer Store
        func loadTime() {}
        
        func saveTime(completion: @escaping (TimeInterval) -> Void) {}
        
        // MARK: - Local Timer State Store
        func retrieve() throws -> LifeCoach.LocalTimerState? {
            nil
        }
        
        func deleteState() throws {
            
        }
        
        func insert(state: LifeCoach.LocalTimerState) throws {
            receivedMessages.append(.saveStateTimer(value: state))
        }
        
        // MARK: - Scheduler
        func setSchedule(at scheduledDate: Date) throws {
            receivedMessages.append(.scheduleTimerNotification)
        }
        
        func unregisterTimerNotification() {
            receivedMessages.append(.unregisterTimerNotification)
        }
        
        // MARK: - Notify Saved Timer
        func notifySavedTimer() {
            receivedMessages.append(.notifySavedTimer)
        }
    }
}

private extension TimeCoach_Watch_AppApp {
    func simulateToggleTimerUserInteraction() {
        timerView.simulateToggleTimerUserInteraction()
    }
}

fileprivate extension LocalTimerState.State {
    var toInfra: TimerCoutdownState {
        switch self {
        case .pause: return .pause
        case .running: return .running
        case .stop: return .stop
        }
    }
}
