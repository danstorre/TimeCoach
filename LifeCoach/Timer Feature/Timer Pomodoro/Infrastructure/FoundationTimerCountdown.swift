import Foundation

public final class FoundationTimerCountdown: TimerCoutdown {
    public typealias StartCoundownCompletion = (Result<LocalTimerSet, Error>) -> Void
    public typealias SkipCoundownCompletion = (Result<LocalTimerSet, Error>) -> Void
    
    public private(set) var state: TimerCoutdownState = .stop
    private var setA: LocalTimerSet
    private var setB: LocalTimerSet
    var currentSet: LocalTimerSet
    var elapsedTimeInterval: TimeInterval = 0
    private let incrementing: Double
    var timerDelivery: StartCoundownCompletion?
    
    var currentTimer: Timer?
    var timeAtSave: CFTimeInterval? = nil
    
    public var currentTimerSet: LocalTimerSet {
        currentSet
    }
    
    public var currentSetElapsedTime: TimeInterval {
        elapsedTimeInterval
    }
    
    public init(startingSet: LocalTimerSet, nextSet: LocalTimerSet, incrementing: Double = 1.0) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
        self.incrementing = incrementing
    }
    
    public func startCountdown(completion: @escaping StartCoundownCompletion) {
        guard hasNotHitThreshold() else { return }
        invalidatesTimer()
        state = .running
        timerDelivery = completion
        createTimer()
    }
    
    public func stopCountdown() {
        timerDelivery?(.success(currentSet))
        invalidatesTimer()
        state = .stop
        elapsedTimeInterval = 0
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
        elapsedTimeInterval += incrementing
        guard hasNotHitThreshold() else {
            invalidatesTimer()
            state = .stop
            let elapsed = currentSet.adding(elapsedTimeInterval)
            timerDelivery?(.success(elapsed))
            return
        }
        
        let elapsed = currentSet.adding(elapsedTimeInterval)
        timerDelivery?(.success(elapsed))
    }
    
    private func hasNotHitThreshold() -> Bool {
        let endDate = currentSet.endDate.adding(seconds: -elapsedTimeInterval)
        return endDate.timeIntervalSince(currentSet.startDate) > 0
    }
    
    private func executeNextSet() {
        invalidatesTimer()
        elapsedTimeInterval = 0
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

public extension LocalTimerSet {
    func adding(_ seconds: Double) -> LocalTimerSet {
        LocalTimerSet(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}
