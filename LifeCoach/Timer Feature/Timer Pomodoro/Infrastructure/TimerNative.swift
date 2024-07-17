import Foundation

public class TimerNative: TimerNativeCommands {
    private let dispatchQueue: DispatchQueue
    private var currentTimer: DispatchSourceTimer?
    private let incrementing: Double
    
    public init(dispatchQueue: DispatchQueue = .main,
                incrementing: Double = 1.0) {
        self.dispatchQueue = dispatchQueue
        self.incrementing = incrementing
    }
    
    deinit {
        invalidateTimer()
    }
    
    // MARK: - Timer properties.
    private enum UnderlinedTimerState {
        case stopped
        case running
        case suspended
    }
    private var timerState = UnderlinedTimerState.stopped
    
    /// Invalidates timer
    public func invalidateTimer() {
        if case timerState = .suspended {
            currentTimer?.resume()
        }
        currentTimer?.setEventHandler {}
        currentTimer?.cancel()
        currentTimer = nil
    }
    
    /// Creates and starts timer
    public func startTimer(completion: @escaping (TimeInterval) -> Void) {
        timerState = .running
        currentTimer = DispatchSource.makeTimerSource(queue: dispatchQueue)
        currentTimer?.schedule(deadline: .now(), repeating: incrementing)
        currentTimer?.setEventHandler(handler: { [incrementing] in
            completion(incrementing)
        })
        currentTimer?.activate()
    }
    
    /// Suspends underlined currentTimer if set. a.k.a `DispatchSourceTimer`.
    public func suspend() {
        timerState = .suspended
        currentTimer?.suspend()
    }
    
    /// Resumes underlined currentTimer if set. a.k.a `DispatchSourceTimer`.
    public func resume() {
        if case timerState = .stopped {
            currentTimer?.resume()
        }
        
        if case timerState = .suspended {
            currentTimer?.resume()
        }
        
        timerState = .running
    }
}
