import SwiftUI

public class TimerViewModel: ObservableObject {
    @Published public var timerString: String = .defaultPomodoroTimerString
    public var mode: TimePresentation = .full {
        didSet {
            guard !hasFinished else { return }
            if case .none = mode {
                timerString = "--:--"
            }
        }
    }
    private var hasFinished = false
    
    public enum TimePresentation {
        case full
        case none
    }
    
    public init() {}
    
    public func errorOnTimer(with: Error) {
        
    }
    
    public func delivered(elapsedTime: ElapsedSeconds) {
        hasFinished = false
        let startDate = elapsedTime.startDate
        let endDate = elapsedTime.endDate.adding(seconds: -elapsedTime.elapsedSeconds)
        
        guard endDate.timeIntervalSince(startDate) > 0 else {
            timerString = "00:00"
            hasFinished = true
            return
        }
        
        timerString = makeStringFrom(startDate: startDate, endDate: endDate, elapsedTime: elapsedTime)
    }
    
    private func makeStringFrom(startDate: Date, endDate: Date, elapsedTime: ElapsedSeconds) -> String {
        switch mode {
        case .none:
            return "--:--"
        case .full:
            return makeTimerFormatter().string(from: startDate, to: endDate)!
        }
    }
    
    private func makeTimerFrom(mode: TimePresentation) -> DateComponentsFormatter {
        switch mode {
        case .none:
            return makeMinuteTimerFormatter()
        case .full:
            return makeTimerFormatter()
        }
    }
}
