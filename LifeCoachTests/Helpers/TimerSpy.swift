import LifeCoach

class TimerSpy: TimerCountdown {
    private(set) var startTimerCompletions = [TimerCompletion]()
    private(set) var pauseTimerCompletions = [TimerCompletion]()
    private(set) var skipTimerCompletions = [TimerCompletion]()
    private(set) var stopTimerCompletions = [TimerCompletion]()
    
    private(set) var pauseCountCallCount: Int = 0
    private(set) var skipCallCount: Int = 0
    private(set) var stopCallCount: Int = 0
    private(set) var callCount: Int = 0
    
    func startCountdown(completion: @escaping TimerCompletion) {
        callCount += 1
        startTimerCompletions.append(completion)
    }
    
    func deliversTime(with time: LocalElapsedSeconds, at index: Int = 0) {
        startTimerCompletions[index](time)
    }
    
    func pauseCountdown(completion: @escaping TimerCompletion) {
        pauseCountCallCount += 1
        
        pauseTimerCompletions.append(completion)
    }
    
    func finishPauseWith(date: LocalElapsedSeconds, at index: Int = 0) {
        pauseTimerCompletions[index](date)
    }
    
    func skipCountdown(completion: @escaping TimerCompletion) {
        skipCallCount += 1
        
        skipTimerCompletions.append(completion)
    }
    
    func finishSkipWith(date: LocalElapsedSeconds, at index: Int = 0) {
        skipTimerCompletions[index](date)
    }
    
    func stopCountdown(completion: @escaping TimerCompletion) {
        stopCallCount += 1
        
        stopTimerCompletions.append(completion)
    }
    
    func finishStopWith(date: LocalElapsedSeconds, at index: Int = 0) {
        stopTimerCompletions[index](date)
    }
}
