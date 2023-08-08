import XCTest
import LifeCoach
@testable import TimeCoach_Watch_App

final class StateTimerAcceptanceTests: XCTestCase {
    typealias TimerStore = TimerLoad & TimerSave
    
    func test_onLaunch_onToggleUserInteractionShouldSendMessageToTimerStateStore() {
        let spy = Spy()
        let sut = TimeCoach_Watch_AppApp(pomodoroTimer: spy, timerState: spy, stateTimerStore: spy).timerView
        let localTimerSet = LocalTimerSet.pomodoroSet(date: .init())
        let expectedTimerState = LocalTimerState(localTimerSet: localTimerSet, state: .running)
        spy.deliversSetOnStart(localTimerSet)
        
        sut.simulateToggleTimerUserInteraction()
        
        XCTAssertEqual(spy.receivedMessages, [
            .startTimer,
            .saveStateTimer(value: expectedTimerState)
        ])
    }
    
    private class Spy: TimerCoutdown, TimerStore, LocalTimerStore {
        enum AnyMessage: Equatable, CustomStringConvertible {
            case startTimer
            case saveStateTimer(value: LifeCoach.LocalTimerState)
            
            var description: String {
                switch self {
                case .startTimer:
                    return "startTimer"
                case let .saveStateTimer(value: localTimerState):
                    return """
                saveStateTimer: seconds: \(localTimerState.localTimerSet.elapsedSeconds), state: \(localTimerState.state)
                startDate: \(localTimerState.localTimerSet.startDate), endDate: \(localTimerState.localTimerSet.endDate)
                """
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
        
        func deliversSetOnStart(_ set: LocalTimerSet) {
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
