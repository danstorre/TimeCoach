import Foundation

public class PomodoroLocalTimer: TimerCountdown {
    public var handler: ((ElapsedSeconds) -> Void)? = nil
    public var timer: Timer? = nil
    private var invalidationTimer: Timer? = nil
    
    public var elapsedTimeInterval: TimeInterval = 0
    public var startDate: Date
    public var finishDate: Date
    
    private var primaryInterval: TimeInterval
    private var secondaryTime: TimeInterval
    
    private var threshold: TimeInterval = 0
    
    private let currentDate: () -> Date
    public var timeAtSave: CFTimeInterval? = nil
    
    public init(currentDate: @escaping () -> Date = Date.init,
         startDate: Date,
         primaryInterval: TimeInterval,
         secondaryTime: TimeInterval) {
        self.startDate = startDate
        self.finishDate = startDate.adding(seconds: primaryInterval)
        self.threshold = primaryInterval
        self.primaryInterval = primaryInterval
        self.secondaryTime = secondaryTime
        self.currentDate = currentDate
    }
    
    public func startCountdown(completion: @escaping (ElapsedSeconds) -> Void) {
        invalidateTimers()
        handler = completion
        timer = createTimer()
    }
    
    public func pauseCountdown(completion: @escaping (ElapsedSeconds) -> Void) {
        invalidateTimers()
        let elapsed = ElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    public func skipCountdown(completion: @escaping (ElapsedSeconds) -> Void) {
        invalidateTimers()
        elapsedTimeInterval = 0
        
        if threshold == primaryInterval {
            threshold = secondaryTime
        } else {
            threshold = primaryInterval
        }
        
        let now = currentDate()
        startDate = now
        finishDate = now.adding(seconds: threshold)
        let elapsed = ElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    public func stopCountdown(completion: @escaping (ElapsedSeconds) -> Void) {
        invalidateTimers()
        elapsedTimeInterval = 0
        
        let elapsed = ElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    private func createTimer() -> Timer {
        Timer.scheduledTimer(timeInterval: 1.0,
                             target: self,
                             selector: #selector(elapsedCompletion),
                             userInfo: nil,
                             repeats: true)
    }
    
    public func invalidateTimers() {
        invalidationTimer?.invalidate()
        timer?.invalidate()
    }
    
    @objc
    func elapsedCompletion() {
        guard elapsedTimeInterval < threshold else {
            return
        }
        elapsedTimeInterval += 1
        let elapsed = ElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        handler?(elapsed)
    }
}

