import SwiftUI

public class TimerViewModel: ObservableObject {
    @Published public var timerString: String = .defaultPomodoroTimerString
    public var mode: TimePresentation = .full
    
    public enum TimePresentation {
        case full
        case minutes
    }
    
    public init() {}
    
    public func errorOnTimer(with: Error) {
        
    }
    
    public func delivered(elapsedTime: ElapsedSeconds) {
        let startDate = elapsedTime.startDate
        let endDate = elapsedTime.endDate.adding(seconds: -elapsedTime.elapsedSeconds)
        
        guard endDate.timeIntervalSince(startDate) > 0 else {
            timerString = "00:00"
            return
        }
        
        timerString = makeStringFrom(startDate: startDate, endDate: endDate, elapsedTime: elapsedTime)
    }
    
    private func makeStringFrom(startDate: Date, endDate: Date, elapsedTime: ElapsedSeconds) -> String {
        let formatter = makeTimerFrom(mode: mode)
    
        switch mode {
        case .minutes:
            return formatter.string(from: startDate, to: endDate)! + ":--"
        case .full:
            return formatter.string(from: startDate, to: endDate)!
        }
    }
    
    private func makeTimerFrom(mode: TimePresentation) -> DateComponentsFormatter {
        switch mode {
        case .minutes:
            return makeMinuteTimerFormatter()
        case .full:
            return makeTimerFormatter()
        }
    }
}
