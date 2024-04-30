import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App
 
final class StateTimerAcceptanceTests: XCTestCase {
    func test_onLaunch_timerShouldStartWithStopState() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.timerState, .stop)
    }
    
    func test_onLaunch_onBackgroundAppStateShouldRequestExtendedTime() {
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.receivedMessages, [])
        
        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
    }
    
    func test_onTimeExtensionCompletionExpired_shouldNotSaveTimerState() {
        let (sut, spy) = makeSUT()
        sut.simulateGoToBackground()
        
        spy.extendedTimeFinished(expiring: true)
        
        XCTAssertEqual(spy.receivedMessages, [
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
    }
    
    func test_onTimeExtensionCompletionExpiredTheSecondTime_ShouldSaveTimerStateOnce() {
        let (sut, spy) = makeSUT()
        let expectedLocalTimerState = expectedTimerState(from: spy, state: .stop)
        sut.simulateGoToBackground()
        
        spy.extendedTimeFinished(expiring: false)
        spy.extendedTimeFinished(expiring: true)
        
        XCTAssertEqual(spy.receivedMessages, [
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess"),
            .insertStateTimer(value: expectedLocalTimerState),
            .notifySavedTimer
        ])
    }
    
    func test_onPlayTimerState_onBackgroundAppStateChange_shouldSaveTimerStateOnNonExpiredTimeExtensionCompletion() {
        let (sut, spy) = makeSUT()
        let expectedLocalTimerState = expectedTimerState(from: spy, state: .running)
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false)
        ])
        
        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false),
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
        
        spy.extendedTimeFinished(expiring: false)
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .scheduleTimerNotification(isBreak: false),
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess"),
            .insertStateTimer(value: expectedLocalTimerState),
            .notifySavedTimer
        ])
    }
    
    func test_onStopTimerState_onBackgroundAppStateChange_shouldSaveTimerStateOnNonExpiredTimeExtensionCompletion() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let expectedLocalTimerState = makeAnyState(seconds: 0,
                                                   startDate: currentDate,
                                                   endDate: currentDate.adding(seconds: .pomodoroInSeconds),
                                                   state: .stop).local
        
        sut.simulateStopTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
        ])
        
        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
        
        spy.extendedTimeFinished(expiring: false)
        
        XCTAssertEqual(spy.receivedMessages, [
            .stopTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess"),
            .insertStateTimer(value: expectedLocalTimerState),
            .notifySavedTimer
        ])
    }
    
    func test_onPauseTimerState_onBackgroundAppStateChange_shouldSaveTimerStateOnNonExpiredTimeExtensionCompletion() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let timerState = makeAnyState(seconds: 1,
                                    startDate: currentDate,
                                    endDate: currentDate.adding(seconds: .pomodoroInSeconds), state: .pause)
        sut.simulateToggleTimerUserInteraction()
        spy.deliversSetAfterStart((timerSet: timerState.timerCountDownState.currentTimerSet, state: .running))
        spy.resetMessages()
        sut.simulateToggleTimerUserInteraction()

        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification,
        ])

        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
        
        spy.extendedTimeFinished(expiring: false)
        
        XCTAssertEqual(spy.receivedMessages, [
            .pauseTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess"),
            .insertStateTimer(value: timerState.local),
            .notifySavedTimer
        ])
    }
    
    func test_onSkipUserInteraction_OnBackgroundAppStateChange_shouldSaveTimerStateOnNonExpiredTimeExtensionCompletion() {
        let currentDate = Date()
        let (sut, spy) = makeSUT(currentDate: { currentDate })
        let timerState = makeAnyState(seconds: 0,
                                    startDate: currentDate,
                                    endDate: currentDate.adding(seconds: .pomodoroInSeconds),
                                    isBreak: true,
                                    state: .stop)
        sut.simulateSkipUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification
        ], "on user skip interaction should unregister timer notification.")
        
        spy.deliversSetAfterSkip((timerSet: timerState.timerCountDownState.currentTimerSet, state: .stop))
        sut.simulateGoToBackground()
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess")
        ])
        
        spy.extendedTimeFinished(expiring: false)
        
        XCTAssertEqual(spy.receivedMessages, [
            .skipTimer,
            .unregisterTimerNotification,
            .requestExtendedBackgroundTime(reason: "TimerSaveStateProcess"),
            .insertStateTimer(value: timerState.local),
            .notifySavedTimer
        ])
    }
    
    func test_onInactiveAppStateChange_shouldNotSendMessageToStartSaveStateProcess() {
        let (sut, spy) = makeSUT(currentDate: { Date() })
        
        sut.gotoInactive()
        
        XCTAssertEqual(spy.receivedMessages, [])
    }
    
    // MARK: - Helpers
    private func expectedTimerState(from spy: Spy, state: TimerStateHelper) -> LocalTimerState {
        makeAnyState(seconds: spy.currentState.currentTimerSet.elapsedSeconds, startDate: spy.currentState.currentTimerSet.startDate, endDate: spy.currentState.currentTimerSet.endDate, state: state).local
    }
    
    private func makeAnyState(seconds: TimeInterval = 1,
                      startDate: Date = Date(),
                      endDate: Date = Date(),
                      isBreak: Bool = false,
                              state helperState: TimerStateHelper = .pause)
    -> (model: TimerState, local: LocalTimerState, timerCountDownState:  TimerCountDownState) {
        let timerSet = makeAnyTimerSet(seconds: seconds, startDate: startDate, endDate: endDate)
        
        let model = TimerState(timerSet: timerSet.model,
                               state: helperState.timerState,
                               isBreak: isBreak)
        let timerCountDownState = TimerCountDownState.init(
            state: StateMapper.state(from: helperState.timerState),
            currentTimerSet: timerSet.timerCountdownSet
        )
        
        let local = LocalTimerState(localTimerSet: timerSet.local,
                                    state: StateMapper.state(from: helperState.timerState),
                                    isBreak: isBreak)
        
        return (model, local, timerCountDownState)
    }
    
    private func makeAnyTimerSet(seconds: TimeInterval = 0,
                                 startDate: Date = Date(),
                                 endDate: Date = Date()) 
    -> (model: TimerSet, local: LocalTimerSet, timerCountdownSet: TimerCountdownSet) {
        let timerSet = TimerSet(seconds, startDate: startDate, endDate: endDate)
        let localTimerSet = LocalTimerSet(seconds, startDate: startDate, endDate: endDate)
        let timerCountdownSet = TimerCountdownSet(seconds, startDate: startDate, endDate: endDate)
        
        return (timerSet, localTimerSet, timerCountdownSet)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: TimeCoach_Watch_AppApp, spy: Spy) {
        let spy = Spy(currenDate: currentDate())
        let infra = Infrastructure(
            timerCountdown: spy,
            stateTimerStore: spy,
            scheduler: spy,
            notifySavedTimer: spy.notifySavedTimer,
            currentDate: currentDate,
            unregisterTimerNotification: spy.unregisterTimerNotification,
            backgroundTimeExtender: spy
        )
        
        let sut = TimeCoach_Watch_AppApp(infrastructure: infra)
        
        return (sut, spy)
    }
    
    private class Spy: TimerCountdown, LocalTimerStore, Scheduler, BackgroundExtendedTime {
        enum AnyMessage: Equatable, CustomStringConvertible {
            case startTimer
            case stopTimer
            case pauseTimer
            case skipTimer
            case insertStateTimer(value: LifeCoach.LocalTimerState)
            case scheduleTimerNotification(isBreak: Bool)
            case unregisterTimerNotification
            case notifySavedTimer
            case requestExtendedBackgroundTime(reason: String)
            
            var description: String {
                switch self {
                case .requestExtendedBackgroundTime(let reason):
                    return "requestedExtendedTime with reason: \(reason)"
                case .startTimer:
                    return "startTimer"
                case let .insertStateTimer(value: localTimerState):
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
        private var currentSet: LifeCoach.TimerCountdownSet
        private var state: LifeCoach.TimerCountdownStateValues = .stop
        
        var currentSetElapsedTime: TimeInterval = 0.0
        
        private(set) var receivedMessages = [AnyMessage]()
        private var receivedStartCompletions = [StartCoundownCompletion]()
        private var receivedSkipCompletions = [SkipCountdownCompletion]()
        
        var currentState: LifeCoach.TimerCountDownState {
            .init(state: state, currentTimerSet: currentSet)
        }
        
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
            let startSet = TimerCountdownSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
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
        
        func deliversSetAfterSkip(_ timerState: (timerSet: TimerCountdownSet, state: TimerCountdownStateValues), index: Int = 0) {
            receivedSkipCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func deliversSetAfterStart(_ timerState: (timerSet: TimerCountdownSet, state: TimerCountdownStateValues), index: Int = 0) {
            setsCurrentTimer(timerState.timerSet, state: timerState.state)
            receivedStartCompletions[index](.success((timerState.timerSet, timerState.state)))
        }
        
        func setsCurrentTimer(_ timerSet: TimerCountdownSet, state: TimerCountdownStateValues) {
            self.state = state
            self.currentSet = timerSet
        }
        
        // MARK: - Local Timer State Store
        func retrieve() throws -> LifeCoach.LocalTimerState? {
            nil
        }
        
        func deleteState() throws {
            
        }
        
        func insert(state: LifeCoach.LocalTimerState) throws {
            receivedMessages.append(.insertStateTimer(value: state))
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
        
        // MARK: - Background Extended Time
        private var requestExtendedBackgroundTimeCompletions = [ExtendedTimeCompletion]()
        
        func requestTime(reason: String, completion: @escaping ExtendedTimeCompletion) {
            receivedMessages.append(.requestExtendedBackgroundTime(reason: reason))
            requestExtendedBackgroundTimeCompletions.append(completion)
        }
        
        func extendedTimeFinished(expiring: Bool, at index: Int = 0) {
            requestExtendedBackgroundTimeCompletions[index](expiring)
        }
    }
}

private extension TimeCoach_Watch_AppApp {
    func simulateToggleTimerUserInteraction() {
        timerView.simulateToggleTimerUserInteraction()
    }
}

private extension TimeCoach_Watch_AppApp {
    var timerState: TimerState.State {
        root.currentSubject.value.state
    }
}
