import Foundation

public final class FoundationTimerCountdown: TimerCountdown {
    public var currentState: TimerCountDownState {
        return .init(state: state, currentTimerSet: currentSet)
    }

    private var state: TimerCountdownStateValues = .stop
    private var setA: TimerCountdownSet
    private var setB: TimerCountdownSet
    internal var currentSet: TimerCountdownSet
    private var timerDelivery: StartCoundownCompletion?
    
    public var currentTimerSet: TimerCountdownSet {
        currentSet
    }
    
    public var currentSetElapsedTime: TimeInterval {
        currentSet.elapsedSeconds
    }
    
    private let timer: TimerNativeCommands?
    
    internal init(startingSet: TimerCountdownSet,
                  nextSet: TimerCountdownSet,
                  timer: TimerNativeCommands) {
        self.setA = startingSet
        self.setB = nextSet
        self.currentSet = startingSet
        self.timer = timer
    }
    
    public func startCountdown(completion: @escaping StartCoundownCompletion) {
        guard hasNotHitThreshold() else { return }
        invalidateTimer()
        state = .running
        timerDelivery = completion
        createTimer()
        timerDelivery?(.success((currentTimerSet, state)))
    }
    
    public func stopCountdown() {
        currentSet = TimerCountdownSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
        state = .stop
        timerDelivery?(.success((currentTimerSet, state)))
        invalidateTimer()
    }
    
    public func pauseCountdown() {
        invalidateTimer()
        state = .pause
        timerDelivery?(.success((currentTimerSet, state)))
    }
    
    public func skipCountdown(completion: @escaping SkipCountdownCompletion) {
        timerDelivery = completion
        executeNextSet()
    }
    
    private func createTimer() {
        startTimer(completion: { [weak self] incrementing in
            self?.elapsedCompletion(incrementing)
        })
    }
    
    @objc
    private func elapsedCompletion(_ incrementing: TimeInterval) {
        currentSet = TimerCountdownSet(currentSet.elapsedSeconds + incrementing, startDate: currentSet.startDate, endDate: currentSet.endDate)
        guard hasNotHitThreshold() else {
            invalidateTimer()
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
        invalidateTimer()
        currentSet = TimerCountdownSet(0, startDate: currentSet.startDate, endDate: currentSet.endDate)
        state = .stop
        setA = currentSet
        currentSet = setB
        timerDelivery?(.success((setB, state)))
        setB = setA
    }

    /// Invalidates timer
    public func invalidateTimer() {
        timer?.invalidateTimer()
    }
    
    /// Creates and starts timer
    public func startTimer(completion: @escaping TimerNativeCommands.TimerPulse) {
        timer?.startTimer { incrementing in
            completion(incrementing)
        }
    }
    
    /// Suspends underlined currentTimer if set. a.k.a `DispatchSourceTimer`.
    public func suspend() {
        timer?.suspend()
    }
    
    /// Resumes underlined currentTimer if set. a.k.a `DispatchSourceTimer`.
    public func resume() {
        timer?.resume()
    }
}

public extension TimerCountdownSet {
    func adding(_ seconds: Double) -> TimerCountdownSet {
        TimerCountdownSet(elapsedSeconds + Double(seconds), startDate: startDate, endDate: endDate)
    }
}
