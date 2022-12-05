import Foundation

public protocol TimerSave {
    func saveTime()
}

public protocol TimerLoad {
    func loadTime()
}

public class PomodoroLocalTimer: TimerCountdown {
    private var handler: ((LocalElapsedSeconds) -> Void)? = nil
    private var timer: Timer? = nil
    private var invalidationTimer: Timer? = nil
    
    private var elapsedTimeInterval: TimeInterval = 0
    private var startDate: Date
    private var finishDate: Date
    
    private var primaryInterval: TimeInterval
    private var secondaryTime: TimeInterval
    
    private var threshold: TimeInterval = 0
    
    private let currentDate: () -> Date
    private var timeAtSave: CFTimeInterval = 0
    
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
    
    public func startCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        handler = completion
        timer = createTimer()
    }
    
    public func pauseCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    public func skipCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
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
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        completion(elapsed)
    }
    
    public func stopCountdown(completion: @escaping (LocalElapsedSeconds) -> Void) {
        invalidateTimers()
        elapsedTimeInterval = 0
        
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
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
        let elapsed = LocalElapsedSeconds(elapsedTimeInterval,
                                          startDate: startDate,
                                          endDate: finishDate)
        handler?(elapsed)
    }
}

extension PomodoroLocalTimer: TimerSave {
    public func saveTime() {
        timeAtSave = CFAbsoluteTimeGetCurrent()
        pauseCountdown(completion: { _ in })
    }
}

extension PomodoroLocalTimer: TimerLoad {
    public func loadTime() {
        let elapsed = CFAbsoluteTimeGetCurrent() - timeAtSave
        elapsedTimeInterval += elapsed.rounded()
        handler?(LocalElapsedSeconds(elapsedTimeInterval, startDate: startDate, endDate: finishDate))
        startCountdown(completion: handler ?? { _ in })
    }
}
