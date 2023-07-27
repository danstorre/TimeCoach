import Foundation

public final class FoundationTimerCountdown: TimerCoutdown {
    public typealias StartCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    public typealias SkipCoundownCompletion = (Result<LocalElapsedSeconds, Error>) -> Void
    
    public private(set) var state: TimerCoutdownState = .stop
    private var setA: LocalElapsedSeconds
    private var setB: LocalElapsedSeconds
    var currentSet: LocalElapsedSeconds
    var elapsedTimeInterval: TimeInterval = 0
    private let incrementing: Double
    var timerDelivery: StartCoundownCompletion?
    
    var currentTimer: Timer?
    var timeAtSave: CFTimeInterval? = nil
    
    public var currentSetElapsedTime: TimeInterval {
        elapsedTimeInterval
    }
    
    public init(startingSet: LocalElapsedSeconds, nextSet: LocalElapsedSeconds, incrementing: Double = 1.0) {
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
            let elapsed = currentSet.addingElapsedSeconds(elapsedTimeInterval)
            timerDelivery?(.success(elapsed))
            return
        }
        
        let elapsed = currentSet.addingElapsedSeconds(elapsedTimeInterval)
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

public extension LocalElapsedSeconds {
    func addingElapsedSeconds(_ seconds: Double) -> LocalElapsedSeconds {
        LocalElapsedSeconds(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}
