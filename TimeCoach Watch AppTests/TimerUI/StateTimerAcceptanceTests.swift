import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class StateTimerAcceptanceTests: XCTestCase {
    typealias TimerStore = TimerLoad & TimerSave
    
    func test_onLaunch_onInactiveAppStateShouldSaveOnlyOnUserInteraction() {
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    func test_onLaunch_onToggleUserInteraction_whenGoingToInactiveAppStateTwiceShouldOnlySaveTimerStateOnce() {
        let (sut, spy) = makeSUT()
        let expected = makeAnyState(seconds: spy.currentTimerSet.elapsedSeconds,
                                    startDate: spy.currentTimerSet.startDate,
                                    endDate: spy.currentTimerSet.endDate, state: .running).local
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onToggleAfterSkipUserInteraction_whenGoingToInactiveAppStateTwiceShouldOnlySaveTimerStateOnce() {
        let (sut, spy) = makeSUT()
        let expected = makeAnyState(seconds: spy.currentTimerSet.elapsedSeconds,
                                    startDate: spy.currentTimerSet.startDate,
                                    endDate: spy.currentTimerSet.endDate,
                                    isBreak: true,
                                    state: .running).local
        sut.timerView.simulateSkipTimerUserInteraction()
        spy.resetMessages()
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: true),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: true),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: true),
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onStopUserInteraction_whenGoingToInactiveAppStateTwiceShouldOnlySaveTimerStateOnce() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let expected = makeAnyState(seconds: 0,
                                    startDate: currentDate,
                                    endDate: currentDate.adding(seconds: .pomodoroInSeconds), state: .stop).local
        
        sut.timerView.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onPauseUserInteraction_whenGoingToInactiveAppStateTwiceShouldOnlySaveTimerStateOnce() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let expected = makeAnyState(seconds: 1,
                                    startDate: currentDate,
                                    endDate: currentDate.adding(seconds: .pomodoroInSeconds), state: .pause).local
        
        sut.timerView.simulateToggleTimerUserInteraction()
        spy.deliversSetAfterStart((timerSet: expected.localTimerSet, state: .running))
        spy.resetMessages()
        
        sut.timerView.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ])
    }
    
    func test_onLaunch_onSkipUserInteraction_whenGoingToInactiveAppStateTwiceShouldOnlySaveTimerStateOnce() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let expected = makeAnyState(seconds: 0,
                                    startDate: currentDate,
                                    endDate: currentDate.adding(seconds: .pomodoroInSeconds),
                                    isBreak: true,
                                    state: .stop).local
        
        sut.timerView.simulateSkipTimerUserInteraction()
        spy.deliversSetAfterSkip((timerSet: expected.localTimerSet, state: .stop))
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ], "on user skip interaction should save timer state and notify saved timer")
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ], "on user skip interaction after going to inactive app state, should save timer state with isBreak: true")
        
        sut.simulateGoToInactive()
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification,
            .saveStateTimer(value: expected),
            .notifySavedTimer
        ], "on user skip interaction after going to inactive app state, should save timer state with isBreak: true")
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
    
    private class Spy: TimerCountdown, TimerStore, LocalTimerStore, Scheduler {
        enum AnyMessage: Equatable, CustomStringConvertible {
            case startTimer
            case stopTimer
            case pauseTimer
            case skipTimer
            case saveStateTimer(value: LifeCoach.LocalTimerState)
            case scheduleTimerNotification(isBreak: Bool)
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
                isBreak: \(localTimerState.isBreak)
                """
                case let .scheduleTimerNotification(isBreak):
                    return "scheduleTimerNotification isBreak \(isBreak)"
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
        var state: LifeCoach.TimerCountdownState = .stop
        
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
            state = .running
            receivedMessages.append(.startTimer)
            receivedStartCompletions.append(completion)
            receivedStartCompletions.last?(.success((currentSet, state)))
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
        
        func deliversSetAfterSkip(_ timerState: (timerSet: LocalTimerSet, state: TimerCountdownState), index: Int = 0) {
            receivedSkipCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func deliversSetAfterStart(_ timerState: (timerSet: LocalTimerSet, state: TimerCountdownState), index: Int = 0) {
            setsCurrentTimer(timerState.timerSet, state: timerState.state)
            receivedStartCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func setsCurrentTimer(_ timerSet: LocalTimerSet, state: TimerCountdownState) {
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
        func setSchedule(at scheduledDate: Date, isBreak: Bool) throws {
            receivedMessages.append(.scheduleTimerNotification(isBreak: isBreak))
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
