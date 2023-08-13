import Foundation
import Combine
import LifeCoach
import LifeCoachWatchOS

func pomodoroResponse(_ seconds: TimeInterval) -> TimerSet {
    let start = Date.now
    return TimerSet(seconds, startDate: start, endDate: start.adding(seconds: .pomodoroInSeconds))
}

func breakResponse(_ seconds: TimeInterval) -> TimerSet {
    let start = Date.now
    return TimerSet(seconds, startDate: start, endDate: start.adding(seconds: .breakInSeconds))
}

class TimerCountdownSpy: TimerCountdown {
    var currentTimerSet: LifeCoach.LocalTimerSet { .init(0, startDate: Date(), endDate: Date())}
    var currentSetElapsedTime: TimeInterval { 0 }
    
    private(set) var receivedStartCountdownCompletions = [StartCoundownCompletion]()
    private(set) var receivedSkipCountdownCompletions = [SkipCountdownCompletion]()
    private(set) var stopCallCount = 0
    private(set) var pauseCallCount = 0
 
    var state: LifeCoach.TimerCountdownState = .pause
    
    func startCountdown(completion: @escaping StartCoundownCompletion) {
        state = .running
        receivedStartCountdownCompletions.append(completion)
    }
    
    func stopCountdown() {
        state = .stop
        stopCallCount += 1
    }
    
    func pauseCountdown() {
        state = .pause
        pauseCallCount += 1
    }
    
    func skipCountdown(completion: @escaping SkipCountdownCompletion) {
        state = .stop
        receivedSkipCountdownCompletions.append(completion)
    }
    
    private var stubs: [() -> TimerSet] = []
    private var pomodoroStubs: [() -> TimerSet] = []
    private var breakStubs: [() -> TimerSet] = []
    
    init(stubs: [() -> TimerSet]) {
        self.stubs = stubs
    }
    
    init(pomodoroStub: [() -> TimerSet], breakStub: [() -> TimerSet]) {
        self.pomodoroStubs = pomodoroStub
        self.breakStubs = breakStub
    }
    
    func flushPomodoroTimes(at index: Int) {
        pomodoroStubs.forEach { stub in
            receivedStartCountdownCompletions[index](.success((stub().toLocal(), .running)))
        }
    }
    
    func flushBreakTimes(at index: Int) {
        breakStubs.forEach { stub in
            receivedStartCountdownCompletions[index](.success((stub().toLocal(), .running)))
        }
    }
    
    func completeSuccessfullyOnSkip(at index: Int = 0) {
        receivedSkipCountdownCompletions[index](.success((breakResponse(0).toLocal(), .stop)))
    }
    
    func completeSuccessfullyOnPomodoroStop(at index: Int = 0) {
        receivedStartCountdownCompletions[index](.success((pomodoroResponse(0).toLocal(), .stop)))
    }
    
    static func delivers(after seconds: ClosedRange<TimeInterval>,
                         _ stub: @escaping (TimeInterval) -> TimerSet) -> TimerCountdownSpy {
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
        pomodoroStub: @escaping (TimeInterval) -> TimerSet,
        afterBreakSeconds breakSeconds: ClosedRange<TimeInterval>,
        breakStub: @escaping (TimeInterval) -> TimerSet)
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
    
    // MARK: Time Saver
    private(set) var saveTimeCallCount = 0
}


extension TimerSet {
    func toLocal() -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds, startDate: startDate, endDate: endDate)
    }
}
