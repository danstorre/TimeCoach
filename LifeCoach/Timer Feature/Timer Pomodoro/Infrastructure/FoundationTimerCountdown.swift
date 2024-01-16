import Foundation

public final class FoundationTimerCountdown: TimerCountdown {
    public var currentState: TimerCountDownState {
        return .init(state: state, currentTimerSet: currentSet)
    }

    private var state: TimerCountdownStateValues = .stop
    private var setA: TimerCountdownSet
    private var setB: TimerCountdownSet
    var currentSet: TimerCountdownSet
    private let incrementing: Double
    var timerDelivery: StartCoundownCompletion?
    
    private let dispatchQueue: DispatchQueue
    
    var currentTimer: DispatchSourceTimer?
    var timeAtSave: CFTimeInterval? = nil
    
    public var currentTimerSet: TimerCountdownSet {
        currentSet
    }
    
    public var currentSetElapsedTime: TimeInterval {
        currentSet.elapsedSeconds
    }
    
    public init(startingSet: TimerCountdownSet,
                dispatchQueue: DispatchQueue = DispatchQueue.main,
                nextSet: TimerCountdownSet,
                incrementing: Double = 1.0) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
        self.incrementing = incrementing
        self.dispatchQueue = dispatchQueue
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
        currentSet = TimerCountdownSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
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
        currentTimer = DispatchSource.makeTimerSource(queue: dispatchQueue)
        currentTimer?.schedule(deadline: .now(), repeating: incrementing)
        currentTimer?.setEventHandler(handler: { [weak self] in
            guard self?.currentTimer != nil else { return }
            self?.elapsedCompletion()
        })
        currentTimer?.activate()
    }
    
    @objc
    private func elapsedCompletion() {
        currentSet = TimerCountdownSet(currentSet.elapsedSeconds + incrementing, startDate: currentSet.startDate, endDate: currentSet.endDate)
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
        currentSet = TimerCountdownSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
        state = .stop
        setA = currentSet
        currentSet = setB
        timerDelivery?(.success((setB, state)))
        setB = setA
    }
    
    public func invalidatesTimer() {
        currentTimer?.setEventHandler {}
        currentTimer?.cancel()
        currentTimer = nil
    }
    
    deinit {
        currentTimer?.setEventHandler {}
        currentTimer?.cancel()
        currentTimer?.resume()
        currentTimer = nil
    }
}

public extension TimerCountdownSet {
    func adding(_ seconds: Double) -> TimerCountdownSet {
        TimerCountdownSet(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}


// MARK: - Setable Timer Countdown
extension FoundationTimerCountdown {
    public func set(state: TimerCountdownStateValues) {
        pauseCountdown()
    }
    
    public func setElapsedSeconds(_ seconds: TimeInterval) {
        currentSet = TimerCountdownSet(seconds, startDate: currentSet.startDate, endDate: currentSet.endDate)
    }
    
    public func set(startDate: Date, endDate: Date) throws {
        guard try validate(startDate: startDate, endDate: endDate) else {
            return
        }
        
        currentSet = TimerCountdownSet(0, startDate: startDate, endDate: endDate)
    }
        
    private func validate(startDate: Date, endDate: Date) throws -> Bool {
        guard customDatesAreNotTheSame(startDate: startDate, endDate: endDate)
        else {
            throw TimerCountdownSetValueError.sameDatesNonPermitted
        }
        
        guard custom(endDate: endDate, isNotOlderThan: startDate) else {
            throw TimerCountdownSetValueError.endDateIsOlderThanStartDate
        }
        
        return true
    }
        
    private func custom(endDate: Date, isNotOlderThan starDate: Date) -> Bool{
        guard endDate.compare(starDate) == .orderedDescending else {
            return false
        }
        
        return true
    }
    
    private func customDatesAreNotTheSame(startDate: Date, endDate: Date) -> Bool{
        guard startDate.compare(endDate) != .orderedSame else {
            return false
        }
        
        return true
    }
}

public enum TimerCountdownSetValueError: Swift.Error {
    case sameDatesNonPermitted
    case endDateIsOlderThanStartDate
}
