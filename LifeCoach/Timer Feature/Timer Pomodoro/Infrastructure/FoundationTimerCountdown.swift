import Foundation

public final class FoundationTimerCountdown: TimerCoutdown {
    public private(set) var state: TimerCoutdownState = .stop
    private var setA: LocalTimerSet
    private var setB: LocalTimerSet
    var currentSet: LocalTimerSet
    private let incrementing: Double
    var timerDelivery: StartCoundownCompletion?
    
    var currentTimer: Timer?
    var timeAtSave: CFTimeInterval? = nil
    
    public var currentTimerSet: LocalTimerSet {
        currentSet
    }
    
    public var currentSetElapsedTime: TimeInterval {
        currentSet.elapsedSeconds
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
        timerDelivery?(.success((currentTimerSet, state)))
    }
    
    public func stopCountdown() {
        currentSet = LocalTimerSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
        state = .stop
        timerDelivery?(.success((currentTimerSet, state)))
        invalidatesTimer()
    }
    
    public func pauseCountdown() {
        invalidatesTimer()
        state = .pause
        timerDelivery?(.success((currentTimerSet, state)))
    }
    
    public func skipCountdown(completion: @escaping SkipCountdownCompletion) {
        timerDelivery = completion
        executeNextSet()
    }
    
    private func createTimer() {
        currentTimer = Timer.init(timeInterval: incrementing, target: self, selector: #selector(elapsedCompletion), userInfo: nil, repeats: true)
        RunLoop.current.add(currentTimer!, forMode: .common)
    }
    
    @objc
    private func elapsedCompletion() {
        currentSet = LocalTimerSet(currentSet.elapsedSeconds + incrementing, startDate: currentSet.startDate, endDate: currentSet.endDate)
        guard hasNotHitThreshold() else {
            invalidatesTimer()
            state = .stop
            timerDelivery?(.success((currentTimerSet, state)))
            return
        }
        
        timerDelivery?(.success((currentTimerSet, state)))
    }
    
    private func hasNotHitThreshold() -> Bool {
        let endDate = currentSet.endDate.adding(seconds: -currentSet.elapsedSeconds)
        return endDate.timeIntervalSince(currentSet.startDate) > 0
    }
    
    private func executeNextSet() {
        invalidatesTimer()
        currentSet = LocalTimerSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
        state = .stop
        setA = currentSet
        currentSet = setB
        timerDelivery?(.success((setB, state)))
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
