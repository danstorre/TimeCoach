import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class StateTimerAcceptanceTests: XCTestCase {
    typealias TimerStore = TimerLoad & TimerSave
    
    func test_onLaunch_onToggleUserInteractionShouldStartNotificationAndSaveStateProcess() {
        let (sut, spy) = makeSUT()
        let anySet = createAnyTimerSet(startingFrom: .init())
        let expected = createAnyTimerState(using: anySet, on: .running)
        spy.deliversSetOnToggle(anySet)
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .saveStateTimer(value: expected),
            .scheduleTimerNotification
        ])
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: TimeCoach_Watch_AppApp, spy: Spy) {
        let spy = Spy()
        let sut = TimeCoach_Watch_AppApp(pomodoroTimer: spy, timerState: spy, stateTimerStore: spy, scheduler: spy)
        
        return (sut, spy)
    }
    
    private func createAnyTimerState(using anySet: LocalTimerSet, on state: LocalTimerState.State) -> LocalTimerState {
        LocalTimerState(localTimerSet: anySet, state: state)
    }
    
    private func createAnyTimerSet(startingFrom startDate: Date = Date()) -> LocalTimerSet {
        createTimerSet(0, startDate: startDate, endDate: startDate.adding(seconds: 1))
    }
    
    private func createTimerSet(_ elapsedSeconds: TimeInterval, startDate: Date, endDate: Date) -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
    
    private class Spy: TimerCoutdown, TimerStore, LocalTimerStore, Scheduler {
        enum AnyMessage: Equatable, CustomStringConvertible {
            case startTimer
            case saveStateTimer(value: LifeCoach.LocalTimerState)
            case scheduleTimerNotification
            
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
                }
            }
        }
        
        var currentSetElapsedTime: TimeInterval = 0.0
        var state: LifeCoach.TimerCoutdownState = .pause
        
        private(set) var receivedCompletions = [StartCoundownCompletion]()
        private(set) var receivedMessages = [AnyMessage]()
        
        private var setOnStart: Result<LocalTimerSet, Error>?
        
        // MARK: - Timer
        func startCountdown(completion: @escaping StartCoundownCompletion) {
            receivedMessages.append(.startTimer)
            guard let setOnStart = setOnStart else { return }
            completion(setOnStart)
        }
        
        func stopCountdown() {}
        
        func pauseCountdown() {}
        
        func skipCountdown(completion: @escaping SkipCountdownCompletion) {}
        
        func deliversSetOnToggle(_ set: LocalTimerSet) {
            setOnStart = .success(set)
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
    }
}

extension LocalTimerState.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pause: return "pause"
        case .stop: return "stop"
        case .running: return "running"
        }
    }
}


private extension TimeCoach_Watch_AppApp {
    func simulateToggleTimerUserInteraction() {
        timerView.simulateToggleTimerUserInteraction()
    }
}
