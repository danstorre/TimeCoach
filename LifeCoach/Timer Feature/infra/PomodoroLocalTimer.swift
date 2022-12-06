import Foundation

public protocol TimerSave {
    func saveTime(completion: @escaping (TimeInterval) -> Void)
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
    private var timeAtSave: CFTimeInterval? = nil
    
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
    public func saveTime(completion: @escaping (TimeInterval) -> Void) {
        guard let timer = timer, timer.isValid else { return }
        pauseCountdown(completion: { _ in })
        timeAtSave = CFAbsoluteTimeGetCurrent()
        let elapsedDate = startDate.adding(seconds: elapsedTimeInterval)
        
        let remainingSeconds = finishDate.timeIntervalSince(elapsedDate)
        completion(remainingSeconds)
    }
}

extension PomodoroLocalTimer: TimerLoad {
    public func loadTime() {
        guard let timeAtSave = timeAtSave else { return }
        let elapsed = CFAbsoluteTimeGetCurrent() - timeAtSave
        elapsedTimeInterval += elapsed.rounded()
        handler?(LocalElapsedSeconds(elapsedTimeInterval, startDate: startDate, endDate: finishDate))
        startCountdown(completion: handler ?? { _ in })
        self.timeAtSave = nil
    }
}
