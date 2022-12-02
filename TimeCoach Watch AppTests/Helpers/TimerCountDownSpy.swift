import Foundation
import Combine
import LifeCoach
import LifeCoachWatchOS

func pomodoroResponse(_ seconds: TimeInterval) -> LocalElapsedSeconds {
    let start = Date.now
    return LocalElapsedSeconds(seconds, startDate: start, endDate: start.adding(seconds: .pomodoroInSeconds))
}

class TimerCountdownSpy: TimerCountdown {
    private var stubs: [() -> LocalElapsedSeconds] = []
    private(set) var receivedStartCompletions = [TimerCompletion]()
    
    init(stubs: [() -> LocalElapsedSeconds]) {
        self.stubs = stubs
    }
    
    func pauseCountdown(completion: @escaping TimerCompletion) {
        
    }
    
    func skipCountdown(completion: @escaping TimerCompletion) {
        
    }
    
    func startCountdown(completion: @escaping TimerCompletion) {
        receivedStartCompletions.append(completion)
    }
    
    func stopCountdown(completion: @escaping TimerCompletion) {
        
    }
    
    func completeSuccessfullyAfterFirstStart() {
        stubs.forEach { stub in
            receivedStartCompletions[0](stub())
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
}
