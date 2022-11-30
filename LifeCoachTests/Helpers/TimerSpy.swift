import LifeCoach

class TimerSpy: LocalTimer.TimerCountdown {
    private(set) var pauseTimerCompletions = [TimerCompletion]()
    private(set) var skipTimerCompletions = [TimerCompletion]()
    
    private(set) var pauseCountCallCount: Int = 0
    private(set) var skipCallCount: Int = 0
    private(set) var startDatesReceived = [Date]()
    private(set) var endDatesReceived = [Date]()
    var callCount: Int {
        startDatesReceived.count
    }
    
    func startCountdown(from date: Date, endDate: Date) {
        startDatesReceived.append(date)
        endDatesReceived.append(endDate)
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
}
