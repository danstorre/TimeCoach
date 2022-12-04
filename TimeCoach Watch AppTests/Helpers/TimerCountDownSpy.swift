import Foundation
import Combine
import LifeCoach
import LifeCoachWatchOS

func pomodoroResponse(_ seconds: TimeInterval) -> LocalElapsedSeconds {
    let start = Date.now
    return LocalElapsedSeconds(seconds, startDate: start, endDate: start.adding(seconds: .pomodoroInSeconds))
}

func breakResponse(_ seconds: TimeInterval) -> LocalElapsedSeconds {
    let start = Date.now
    return LocalElapsedSeconds(seconds, startDate: start, endDate: start.adding(seconds: .breakInSeconds))
}

class TimerCountdownSpy: TimerCountdown {
    private var stubs: [() -> LocalElapsedSeconds] = []
    private var pomodoroStubs: [() -> LocalElapsedSeconds] = []
    private var breakStubs: [() -> LocalElapsedSeconds] = []
    private(set) var receivedToggleCompletions = [TimerCompletion]()
    private(set) var receivedSkipCompletions = [TimerCompletion]()
    private(set) var receivedStopCompletions = [TimerCompletion]()
    
    init(stubs: [() -> LocalElapsedSeconds]) {
        self.stubs = stubs
    }
    
    init(pomodoroStub: [() -> LocalElapsedSeconds], breakStub: [() -> LocalElapsedSeconds]) {
        self.pomodoroStubs = pomodoroStub
        self.breakStubs = breakStub
    }
    
    func pauseCountdown(completion: @escaping TimerCompletion) {
        receivedToggleCompletions.append(completion)
    }
    
    func skipCountdown(completion: @escaping TimerCompletion) {
        receivedSkipCompletions.append(completion)
    }
    
    func startCountdown(completion: @escaping TimerCompletion) {
        receivedToggleCompletions.append(completion)
    }
    
    func stopCountdown(completion: @escaping TimerCompletion) {
        receivedStopCompletions.append(completion)
    }
    
    func completeSuccessfullyAfterFirstStart() {
        stubs.forEach { stub in
            receivedToggleCompletions[0](stub())
        }
    }
    
    func flushPomodoroTimes(at index: Int) {
        pomodoroStubs.forEach { stub in
            receivedToggleCompletions[index](stub())
        }
    }
    
    func flushBreakTimes(at index: Int) {
        breakStubs.forEach { stub in
            receivedToggleCompletions[index](stub())
        }
    }
    
    func completeSuccessfullyOnSkip(at index: Int = 0) {
        receivedSkipCompletions[index](breakResponse(0))
    }
    
    func completeSuccessfullyOnPomodoroStop(at index: Int = 0) {
        receivedStopCompletions[index](pomodoroResponse(0))
    }
    
    func completeSuccessfullyOnPomodoroToggle(at index: Int = 0) {
        if let lastGivenPomodoro = pomodoroStubs.last {
            receivedToggleCompletions[index](lastGivenPomodoro())
        }
    }
    
    static func delivers(after seconds: ClosedRange<TimeInterval>,
                         _ stub: @escaping (TimeInterval) -> LocalElapsedSeconds) -> TimerCountdownSpy {
        let start: Int = Int(seconds.lowerBound)
        let end: Int = Int(seconds.upperBound)
        let array: [TimeInterval] = (start...end).map { TimeInterval($0) }
        let stubs = array.map { seconds in
            {
                return stub(seconds)
            }
        }
        return TimerCountdownSpy(stubs: stubs)
    }
    
    static func delivers(
        afterPomoroSeconds pomodoroSeconds: ClosedRange<TimeInterval>,
        pomodoroStub: @escaping (TimeInterval) -> LocalElapsedSeconds,
        afterBreakSeconds breakSeconds: ClosedRange<TimeInterval>,
        breakStub: @escaping (TimeInterval) -> LocalElapsedSeconds)
    -> TimerCountdownSpy {
        let pomodoroStart: Int = Int(pomodoroSeconds.lowerBound)
        let pomodoroEnd: Int = Int(pomodoroSeconds.upperBound)
        let pomoroSeconds: [TimeInterval] = (pomodoroStart...pomodoroEnd).map { TimeInterval($0) }
        let pomodoroStub = pomoroSeconds.map { seconds in
            {
                return pomodoroStub(seconds)
            }
        }
        
        let breakStart: Int = Int(breakSeconds.lowerBound)
        let breakEnd: Int = Int(breakSeconds.upperBound)
        let breakSeconds: [TimeInterval] = (breakStart...breakEnd).map { TimeInterval($0) }
        let breakStub = breakSeconds.map { seconds in
            {
                return breakStub(seconds)
            }
        }
        
        return TimerCountdownSpy(pomodoroStub: pomodoroStub, breakStub: breakStub)
    }
}
