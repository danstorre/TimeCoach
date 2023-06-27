import Foundation

public final class FoundationTimerCountdown: TimerCoutdown {
    public typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    public typealias SkipCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    public private(set) var state: TimerState = .stop
    private var setA: LocalElapsedSeconds
    private var setB: LocalElapsedSeconds
    private var currentSet: LocalElapsedSeconds
    private var elapsedTimeInterval: TimeInterval = 0
    private let incrementing: Double
    private var timerDelivery: StartCoundownCompletion?
    
    private var currentTimer: Timer?
    
    public init(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds, incrementing: Double = 1.0) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
        self.incrementing = incrementing
    }
    
    public func startCountdown(completion: @escaping StartCoundownCompletion) {
        invalidatesTimer()
        state = .running
        timerDelivery = completion
        createTimer()
    }
    
    public func stopCountdown() {
        invalidatesTimer()
        state = .stop
        timerDelivery?(.success(currentSet))
    }
    
    public func pauseCountdown() {
        invalidatesTimer()
        state = .pause
    }
    
    public func skipCountdown(completion: @escaping SkipCoundownCompletion) {
        timerDelivery = completion
        executeNextSet()
    }
    
    private func createTimer() {
        currentTimer = Timer.init(timeInterval: incrementing, target: self, selector: #selector(elapsedCompletion), userInfo: nil, repeats: true)
        RunLoop.current.add(currentTimer!, forMode: .common)
    }
    
    @objc
    private func elapsedCompletion() {
        guard hasNotHitThreshold() else {
            executeNextSet()
            return
        }
        
        elapsedTimeInterval += incrementing
        
        let elapsed = currentSet.addingElapsedSeconds(elapsedTimeInterval)
        timerDelivery?(.success(elapsed))
    }
    
    private func hasNotHitThreshold() -> Bool {
        let endDate = currentSet.endDate.adding(seconds: -elapsedTimeInterval)
        return endDate.timeIntervalSince(currentSet.startDate) > 0
    }
    
    private func executeNextSet() {
        invalidatesTimer()
        state = .stop
        setA = currentSet
        currentSet = setB
        timerDelivery?(.success(setB))
        setB = setA
    }
    
    public func invalidatesTimer() {
        currentTimer?.invalidate()
    }
}

public extension LocalElapsedSeconds {
    func addingElapsedSeconds(_ seconds: Double) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}
